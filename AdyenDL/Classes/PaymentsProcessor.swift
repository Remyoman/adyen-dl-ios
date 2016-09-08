//
//  PaymentsProcessor.swift
//  AdyenDL
//
//  Created by Oleg Lutsenko on 7/1/16.
//  Copyright © 2015 Adyen. All rights reserved.
//

import Foundation

/**
 Error type.
 
 - invalidSignature: Invalid signature.
 - unexpectedData:   Unexpected data or data format.
 - networkError:     Network error.
 - unexpectedError:  Unexpected error.
 */
public enum Error: ErrorType {
    case invalidSignature
    case unexpectedData
    case networkError (NSError)
    case unexpectedError
}

public typealias PaymentMethodsCompletion = (methods: [PaymentMethod]?, error: Error?) -> ()
public typealias PayURLCompletion = (url: NSURL?, error: Error?) -> ()
public typealias PaymentResultCompletion = (result: PaymentResult?, error: Error?) -> ()

/// Payments processor.
public class PaymentsProcessor {
    
    /// Environment configuration.
    public let configuration: Configuration

    let session: NSURLSession
    
    /**
     Creates payments processor object and initialises it with provided configuration.
     
     - parameter configuration: Environment configuration.
     
     - returns: Initialised instance of payments processor.
     */
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    }

    /**
     Fetches list of available payment methods for a given payment object.
     
     After calling this method, mobile client will send a signature calculation request to the merchnat server specified in `Configuration`.
     
     - parameter payment:    Payment object.
     - parameter completion: Completion handler will be called when list of payment methods is avalible or an error occured.
     */
    public func fetchPaymentMethodsFor(payment: Payment, completion: PaymentMethodsCompletion) {
        fetchMerchantSignatureFor(payment) { (parameters, error) in
            if let error = error {
                completion(methods: nil, error: error)
                return
            }
            
            guard let parameters = parameters else {
                completion(methods: nil, error: .unexpectedData)
                return
            }
            
            self.fetchPaymentMethodsFor(parameters: parameters, completion: completion);
        }
    }
    
    /**
     Fetches payment URL for a given pair of paument object and payment method.
     
     After calling this method, mobile client will send a signature calculation request to the merchnat server specified in `Configuration`.
     
     Use payment URL provided in completion handler to continue payment flow. Open payment URL in a mobile browser.
     
     - parameter payment:    Payment object.
     - parameter method:     Payment method.
     - parameter completion: Completion handler will be called when payment URL is avalible or an error occured.
     */
    public func fetchPayURLFor(payment: Payment, payingWith method: PaymentMethod, completion: PayURLCompletion) {
        fetchMerchantSignatureFor(payment, payingWith: method) { (parameters, error) in
            if let error = error {
                completion(url: nil, error: error)
                return
            }
            
            guard let parameters = parameters else {
                completion(url: nil, error: .unexpectedData)
                return
            }
            
            self.fetchPayURLFor(parameters, completion: completion)
        }
    }
    
    /**
     Verifies received payment result.
     
     Pass received callback URL to this method to validate final result of the payment.
     
     After calling this method merchnat server will be asked to calculate signature for a given result.
     
     
     
     - parameter resultURL:  callback URL received by UIApplicationDelegate.
     - parameter payment:    Payment object.
     - parameter completion: Completion handler will be called when final result of the payment is known or an error occured.
     */
    public func verifyResult(resultURL: NSURL, forPayment payment: Payment, completion: PaymentResultCompletion) {
        fetchMerchnantSignatureFor(resultURL: resultURL) { (parameters, error) in
            if let error = error {
                completion(result: nil, error: error)
                return
            }
            
            guard let parameters = parameters else {
                completion(result: nil, error: .unexpectedData)
                return
            }
            
            let validSignature = self.signature(fromResultURL: resultURL, matchesSignatureFromParameters: parameters)
            if validSignature == false {
                completion(result: nil, error: .invalidSignature)
                return
            }
            
            self.fetchPaymentResultFor(payment, withResultURL: resultURL, completion: completion)
        }
    }
    
}

private typealias MerchnatSignature = PaymentsProcessor
extension MerchnatSignature {
    
    typealias MerchantSignatureCompletion = (parameters: [String: String]?, error: Error?) -> ()
    
    func fetchMerchantSignatureFor(payment: Payment, completion: MerchantSignatureCompletion) {
        fetchMerchantSignatureFor(parameters: payment.parameters(),
                                  fromURL: configuration.paymentSignatureURL,
                                  completion: completion)
    }
    
    func fetchMerchantSignatureFor(payment: Payment, payingWith paymentMethod: PaymentMethod, completion: MerchantSignatureCompletion) {
        var parameters = payment.parameters()
        parameters.formUnion(paymentMethod.parameters())
        fetchMerchantSignatureFor(parameters: parameters,
                                  fromURL: configuration.paymentSignatureURL,
                                  completion: completion)
    }

    func fetchMerchnantSignatureFor(resultURL url: NSURL, completion: MerchantSignatureCompletion) {
        var parameters = [String: String]()
        if let urlComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: true) {
            _ = urlComponents.queryItems?.map({parameters[$0.name] = ($0.value ?? "")})
        }
        fetchMerchantSignatureFor(parameters: parameters,
                                  fromURL: configuration.paymentResultSignatureURL,
                                  completion: completion)
    }

    func fetchMerchantSignatureFor(parameters parameters: [String: String], fromURL url: NSURL, completion: MerchantSignatureCompletion) {
        let url = url.urlByAppending(parameters)
        session.dataTaskWithURL(url) { (data, response, error) in
            if let error = error {
                completion(parameters: nil, error: .networkError(error))
                return
            }
            
            guard let data = data else {
                completion(parameters: nil, error: .unexpectedData)
                return
            }
            
            do {
                guard let parameters = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: String] else {
                    completion(parameters: nil, error: .unexpectedData)
                    return
                }
                
                completion(parameters: parameters, error: nil)
            } catch {
                completion(parameters: nil, error: .unexpectedData)
            }
        }.resume()
    }
    
}

private typealias PaymentMethods = PaymentsProcessor
extension PaymentMethods {
    
    func fetchPaymentMethodsFor(parameters parameters: [String: String], completion: PaymentMethodsCompletion) {
        let request = NSMutableURLRequest(URL: self.configuration.hppDirectoryURL())
        request.HTTPMethod = "POST"
        request.setHTTPBodyWith(parameters)
        self.session.dataTaskWithRequest(request) { (data, response, error) in
            if let error = error {
                completion(methods: nil, error: .networkError(error))
                return
            }
            
            guard let data = data else {
                completion(methods: nil, error: .unexpectedError)
                return
            }
            
            do {
                guard
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject],
                    let methods = json["paymentMethods"] as? [[String: AnyObject]]
                    else
                {
                    completion(methods: nil, error: .unexpectedError)
                    return
                }
                
                var results = [PaymentMethod]()
                for info in methods {
                    if let method = self.paymentMethod(withInfo: info) {
                        results.append(method)
                    }
                }
                
                //  Group card payment methods.
                let cardMethods = results.reduce([PaymentMethod]()) { (cardMethods, method) -> [PaymentMethod] in
                    var cardMethods = cardMethods
                    if method.type == .card {
                        cardMethods.append(method)
                    }
                    return cardMethods
                }
                results.removeObjects(cardMethods)
                results.append(PaymentMethod(cardPaymentMethodWith: cardMethods))
                
                completion(methods: results, error: nil)
            } catch {
                completion(methods: nil, error: .unexpectedError)
            }
            }.resume()
    }
    
    func paymentMethod(withInfo info: [String: AnyObject]) -> PaymentMethod? {
        guard
            let name = info["name"] as? String,
            let brandCode = info["brandCode"] as? String
            else
        {
            return nil
        }
        
        let issuerId = info["issuerId"] as? String
        
        var submethods: [PaymentMethod]?
        if let issuers = info["issuers"] as? [[String: String]] {
            submethods = [PaymentMethod]()
            for info in issuers {
                if let name = info["name"], let issuerId = info["issuerId"] {
                    submethods?.append(PaymentMethod(
                        type: .other,
                        name: name,
                        brandCode: brandCode,
                        issuerId: issuerId,
                        submethods: nil))
                }
            }
        }
        
        let isCard = CardBrandCode(rawValue: brandCode.lowercaseString) != nil
        let type: PaymentMethodType = isCard ? .card : .other
        
        return PaymentMethod(
            type: type,
            name: name,
            brandCode: brandCode,
            issuerId: issuerId,
            submethods: submethods
        )
    }
    
}

private typealias PaymentURL = PaymentsProcessor
extension PaymentURL {
    
    func fetchPayURLFor(parameters: [String: String], completion: PayURLCompletion) {
        let url = configuration.hppDetailsURL().urlByAppending(parameters)
        session.dataTaskWithURL(url) { (_, response, error) in
            if let error = error {
                completion(url: nil, error: .networkError(error))
            }
            completion(url: response?.URL, error: nil)
            }.resume()
    }
    
}

private typealias ResultVerification = PaymentsProcessor
extension ResultVerification {
    
    func signature(fromResultURL url: NSURL, matchesSignatureFromParameters parameters: [String: String]) -> Bool {
        let merchantSignatureKey = "merchantSig"
        guard
            let resultSignature = url.queryParameters()?[merchantSignatureKey],
            let merchantSignature = parameters[merchantSignatureKey]
            else
        {
            return false
        }
        
        return resultSignature == merchantSignature
    }
    
    func paymentStatus(fromResultURL url: NSURL) -> PaymentStatus? {
        let authResultKey = "authResult"
        guard let authResult = url.queryParameters()?[authResultKey]?.lowercaseString else {
            return nil
        }
        
        return PaymentStatus(rawValue: authResult)
    }
    
    var fetchResultFor: (payment: Payment, retryCount: Int, completion: PaymentResultCompletion) -> Void {
        return { payment, retryCount, completion in
            
            let retryCount = retryCount - 1
            
            let merchantReferenceKey = "merchantReference"
            let parameters = [merchantReferenceKey: payment.merchantReference]
            let url = self.configuration.paymentStatusURL.urlByAppending(parameters)
            
            self.session.dataTaskWithURL(url) {(data, response, error) in
                if let error = error {
                    completion(result: nil, error: .networkError(error))
                    return
                }
                
                guard let data = data else {
                    completion(result: nil, error: .unexpectedData)
                    return
                }
                
                do {
                    guard let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject] else {
                        completion(result: nil, error: .unexpectedData)
                        return
                    }
                    
                    //  Check if status is determined.
                    let eventCodeKey = "eventCode"
                    let successKey = "success"
                    if let eventCode = json[eventCodeKey] as? String, let success = json[successKey] as? String where eventCode == "AUTHORISATION" {
                        let status: PaymentStatus = (success == "true") ? .authorised : .refused
                        let result = PaymentResult(payment: payment, status: status)
                        completion(result: result, error: nil)
                        return
                    }
                    
                    if retryCount > 0 {
                        //  Retry.
                        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(self.configuration.paymentStatusRetryInterval * Double(NSEC_PER_SEC)))
                        dispatch_after(delayTime, dispatch_get_main_queue()) {
                            self.fetchResultFor(payment: payment, retryCount: retryCount, completion: completion)
                        }
                    } else {
                        //  Give up on retrying.
                        let finalResult = PaymentResult(payment: payment, status: .pending)
                        completion(result: finalResult, error: nil)
                    }
                } catch {
                    completion(result: nil, error: .unexpectedData)
                }
            }.resume()
        }
    }
    
    func fetchPaymentResultFor(payment: Payment, withResultURL url: NSURL, completion: PaymentResultCompletion) {
        guard let status = self.paymentStatus(fromResultURL: url) else {
            completion(result: nil, error: .unexpectedData)
            return
        }
        
        if status != .pending {
            let result = PaymentResult(payment: payment, status: status)
            completion(result: result, error: nil)
            return
        }
        
        fetchResultFor(payment: payment,
                       retryCount: self.configuration.paymentStatusRetryCount,
                       completion: completion)
    }
    
}

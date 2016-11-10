//
//  PaymentsProcessor.swift
//  AdyenDL
//
//  Created by Oleg Lutsenko on 7/1/16.
//  Copyright © 2015 Adyen. All rights reserved.
//

import Foundation

/**
 ProcessorError type.
 
 - invalidSignature: Invalid signature.
 - unexpectedData:   Unexpected data or data format.
 - networkError:     Network error.
 - unexpectedError:  Unexpected error.
 */
public enum ProcessorError: Error {
    case invalidSignature
    case unexpectedData
    case networkError (Error)
    case unexpectedError
}

public typealias PaymentMethodsCompletion = (_ methods: [PaymentMethod]?, _ error: ProcessorError?) -> ()
public typealias PayURLCompletion = (_ url: URL?, _ error: ProcessorError?) -> ()
public typealias PaymentResultCompletion = (_ result: PaymentResult?, _ error: ProcessorError?) -> ()

/// Payments processor.
open class PaymentsProcessor {
    
    /// Environment configuration.
    open let configuration: Configuration

    let session: URLSession
    
    /**
     Creates payments processor object and initialises it with provided configuration.
     
     - parameter configuration: Environment configuration.
     
     - returns: Initialised instance of payments processor.
     */
    public init(configuration: Configuration) {
        self.configuration = configuration
        self.session = URLSession(configuration: URLSessionConfiguration.default)
    }

    /**
     Fetches list of available payment methods for a given payment object.
     
     After calling this method, mobile client will send a signature calculation request to the merchant server specified in `Configuration`.
     
     - parameter payment:    Payment object.
     - parameter completion: Completion handler will be called when list of payment methods is avalible or an error occured.
     */
    open func fetchPaymentMethodsFor(_ payment: Payment, completion: @escaping PaymentMethodsCompletion) {
        fetchMerchantSignatureFor(payment) { (parameters, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let parameters = parameters else {
                completion(nil, .unexpectedData)
                return
            }
            
            self.fetchPaymentMethodsFor(parameters: parameters, completion: completion);
        }
    }
    
    /**
     Fetches payment URL for a given pair of paument object and payment method.
     
     After calling this method, mobile client will send a signature calculation request to the merchant server specified in `Configuration`.
     
     Use payment URL provided in completion handler to continue payment flow. Open payment URL in a mobile browser.
     
     - parameter payment:    Payment object.
     - parameter method:     Payment method.
     - parameter completion: Completion handler will be called when payment URL is avalible or an error occured.
     */
    open func fetchPayURLFor(_ payment: Payment, payingWith method: PaymentMethod, completion: @escaping PayURLCompletion) {
        fetchMerchantSignatureFor(payment, payingWith: method) { (parameters, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let parameters = parameters else {
                completion(nil, .unexpectedData)
                return
            }
            
            self.fetchPayURLFor(parameters, completion: completion)
        }
    }
    
    /**
     Verifies received payment result.
     
     Pass received callback URL to this method to validate final result of the payment.
     
     After calling this method merchant server will be asked to calculate signature for a given result.
     
     
     
     - parameter resultURL:  callback URL received by UIApplicationDelegate.
     - parameter payment:    Payment object.
     - parameter completion: Completion handler will be called when final result of the payment is known or an error occured.
     */
    open func verifyResult(_ resultURL: URL, forPayment payment: Payment, completion: @escaping PaymentResultCompletion) {
        fetchMerchnantSignatureFor(resultURL: resultURL) { (parameters, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let parameters = parameters else {
                completion(nil, .unexpectedData)
                return
            }
            
            let validSignature = self.signature(fromResultURL: resultURL, matchesSignatureFromParameters: parameters)
            if validSignature == false {
                completion(nil, .invalidSignature)
                return
            }
            
            self.fetchPaymentResultFor(payment, withResultURL: resultURL, completion: completion)
        }
    }
    
}

private typealias MerchantSignature = PaymentsProcessor
extension MerchantSignature {
    
    typealias MerchantSignatureCompletion = (_ parameters: [String: String]?, _ error: ProcessorError?) -> ()
    
    func fetchMerchantSignatureFor(_ payment: Payment, completion: @escaping MerchantSignatureCompletion) {
        fetchMerchantSignatureFor(parameters: payment.parameters(),
                                  fromURL: configuration.paymentSignatureURL as URL,
                                  completion: completion)
    }
    
    func fetchMerchantSignatureFor(_ payment: Payment, payingWith paymentMethod: PaymentMethod, completion: @escaping MerchantSignatureCompletion) {
        var parameters = payment.parameters()
        parameters.formUnion(paymentMethod.parameters())
        fetchMerchantSignatureFor(parameters: parameters,
                                  fromURL: configuration.paymentSignatureURL as URL,
                                  completion: completion)
    }

    func fetchMerchnantSignatureFor(resultURL url: URL, completion: @escaping MerchantSignatureCompletion) {
        var parameters = [String: String]()
        if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            _ = urlComponents.queryItems?.map({parameters[$0.name] = ($0.value ?? "")})
        }
        fetchMerchantSignatureFor(parameters: parameters,
                                  fromURL: configuration.paymentResultSignatureURL as URL,
                                  completion: completion)
    }

    func fetchMerchantSignatureFor(parameters: [String: String], fromURL url: URL, completion: @escaping MerchantSignatureCompletion) {
        let url = url.urlByAppending(parameters)
        session.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                completion(nil, .networkError(error))
                return
            }
            
            guard let data = data else {
                completion(nil, .unexpectedData)
                return
            }
            
            do {
                guard let parameters = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else {
                    completion(nil, .unexpectedData)
                    return
                }
                
                completion(parameters, nil)
            } catch {
                completion(nil, .unexpectedData)
            }
        }) .resume()
    }
    
}

private typealias PaymentMethods = PaymentsProcessor
extension PaymentMethods {
    
    func fetchPaymentMethodsFor(parameters: [String: String], completion: @escaping PaymentMethodsCompletion) {
        let request = NSMutableURLRequest(url: self.configuration.hppDirectoryURL() as URL)
        request.httpMethod = "POST"
        request.setHTTPBodyWith(parameters)
        self.session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            if let error = error {
                completion(nil, .networkError(error))
                return
            }
            
            guard let data = data else {
                completion(nil, .unexpectedError)
                return
            }
            
            do {
                guard
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject],
                    let methods = json["paymentMethods"] as? [[String: AnyObject]]
                    else
                {
                    completion(nil, .unexpectedError)
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
                
                completion(results, nil)
            } catch {
                completion(nil, .unexpectedError)
            }
            }) .resume()
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
        
        let isCard = CardBrandCode(rawValue: brandCode.lowercased()) != nil
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
    
    func fetchPayURLFor(_ parameters: [String: String], completion: @escaping PayURLCompletion) {
        let url = configuration.hppDetailsURL().urlByAppending(parameters)
        session.dataTask(with: url, completionHandler: { (_, response, error) in
            if let error = error {
                completion(nil, .networkError(error))
            }
            completion(response?.url, nil)
            }) .resume()
    }
    
}

private typealias ResultVerification = PaymentsProcessor
extension ResultVerification {
    
    func signature(fromResultURL url: URL, matchesSignatureFromParameters parameters: [String: String]) -> Bool {
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
    
    func paymentStatus(fromResultURL url: URL) -> PaymentStatus? {
        let authResultKey = "authResult"
        guard let authResult = url.queryParameters()?[authResultKey]?.lowercased() else {
            return nil
        }
        
        return PaymentStatus(rawValue: authResult)
    }
    
    var fetchResultFor: (_ payment: Payment, _ retryCount: Int, _ completion: @escaping PaymentResultCompletion) -> Void {
        return { payment, retryCount, completion in
            
            let retryCount = retryCount - 1
            
            let merchantReferenceKey = "merchantReference"
            let parameters = [merchantReferenceKey: payment.merchantReference]
            let url = self.configuration.paymentStatusURL.urlByAppending(parameters)
            
            self.session.dataTask(with: url, completionHandler: {(data, response, error) in
                if let error = error {
                    completion(nil, .networkError(error))
                    return
                }
                
                guard let data = data else {
                    completion(nil, .unexpectedData)
                    return
                }
                
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
                        completion(nil, .unexpectedData)
                        return
                    }
                    
                    //  Check if status is determined.
                    let eventCodeKey = "eventCode"
                    let successKey = "success"
                    if let eventCode = json[eventCodeKey] as? String, let success = json[successKey] as? String, eventCode == "AUTHORISATION" {
                        let status: PaymentStatus = (success == "true") ? .authorised : .refused
                        let result = PaymentResult(payment: payment, status: status)
                        completion(result, nil)
                        return
                    }
                    
                    if retryCount > 0 {
                        //  Retry.
                        let delayTime = DispatchTime.now() + Double(Int64(self.configuration.paymentStatusRetryInterval * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: delayTime) {
                            self.fetchResultFor(payment, retryCount, completion)
                        }
                    } else {
                        //  Give up on retrying.
                        let finalResult = PaymentResult(payment: payment, status: .pending)
                        completion(finalResult, nil)
                    }
                } catch {
                    completion(nil, .unexpectedData)
                }
            }) .resume()
        }
    }
    
    func fetchPaymentResultFor(_ payment: Payment, withResultURL url: URL, completion: @escaping PaymentResultCompletion) {
        guard let status = self.paymentStatus(fromResultURL: url) else {
            completion(nil, .unexpectedData)
            return
        }
        
        if status != .pending {
            let result = PaymentResult(payment: payment, status: status)
            completion(result, nil)
            return
        }
        
        fetchResultFor(payment,
                       self.configuration.paymentStatusRetryCount,
                       completion)
    }
    
}

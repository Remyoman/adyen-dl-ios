//
//  Configuration.swift
//  AdyenDL
//
//  Created by Oleg Lutsenko on 7/14/16.
//  Copyright © 2015 Adyen. All rights reserved.
//

import Foundation

/**
 Adyen's environment (Live or Test).
 
 - live: Adyen's Live environment.
 - test: Adyen's Test environment.
 */
public enum Environment: Int {
    case live
    case test
}

/// Describes environment configuration: Adyen's environment and Merchant's Server URLs.
open class Configuration : NSObject {
    
    open let environment: Environment
    open let paymentSignatureURL: URL
    open let paymentResultSignatureURL: URL
    open let paymentStatusURL: URL
    
    /// Specifies a count of retries to fetch payment status.
    open var paymentStatusRetryCount = 10
    
    //  Specifies time interval between retry atempts.
    open var paymentStatusRetryInterval: TimeInterval = 5
    
    /**
     Initialises configuration with provided parameters.
     
     - parameter environment:               Adyen's environment.
     - parameter paymentSignatureURL:       Merchant's Server url to calculate signature for payment.
     - parameter paymentResultSignatureURL: Merchant's Server url to calculate signature for payment result.
     - parameter paymentStatusURL:          Merchant's Server url to fetch status of the payment.
     
     - returns: Initialised instance of configuration.
     */
    public init (environment: Environment, paymentSignatureURL: URL, paymentResultSignatureURL: URL, paymentStatusURL: URL) {
        self.environment = environment
        self.paymentSignatureURL = paymentSignatureURL
        self.paymentResultSignatureURL = paymentResultSignatureURL
        self.paymentStatusURL = paymentStatusURL
    }
    
}

//  MARK: Private
extension Configuration {

    func hppDirectoryURL() -> URL {
        var url: URL = URL(string: "https://live.adyen.com/hpp/directory.shtml")!
        if environment == .test {
            url = URL(string: "https://test.adyen.com/hpp/directory.shtml")!
        }
        return url
    }
    
    func hppDetailsURL() -> URL {
        var url: URL = URL(string: "https://live.adyen.com/hpp/details.shtml")!
        if environment == .test {
            url = URL(string: "https://test.adyen.com/hpp/details.shtml")!
        }
        return url
    }
    
}

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
public enum Environment {
    case live
    case test
}

/// Describes environment configuration: Adyen's environment and Merchant's Server URLs.
public class Configuration {
    
    public let environment: Environment
    public let paymentSignatureURL: NSURL
    public let paymentResultSignatureURL: NSURL
    public let paymentStatusURL: NSURL
    
    /// Specifies a count of retries to fetch payment status.
    public var paymentStatusRetryCount = 10
    
    //  Specifies time interval between retry atempts.
    public var paymentStatusRetryInterval: NSTimeInterval = 5
    
    /**
     Initialises configuration with provided parameters.
     
     - parameter environment:               Adyen's environment.
     - parameter paymentSignatureURL:       Merchant's Server url to calculate signature for payment.
     - parameter paymentResultSignatureURL: Merchant's Server url to calculate signature for payment result.
     - parameter paymentStatusURL:          Merchant's Server url to fetch status of the payment.
     
     - returns: Initialised instance of configuration.
     */
    public init (environment: Environment, paymentSignatureURL: NSURL, paymentResultSignatureURL: NSURL, paymentStatusURL: NSURL) {
        self.environment = environment
        self.paymentSignatureURL = paymentSignatureURL
        self.paymentResultSignatureURL = paymentResultSignatureURL
        self.paymentStatusURL = paymentStatusURL
    }
    
}

//  MARK: Private
extension Configuration {

    func hppDirectoryURL() -> NSURL {
        var url: NSURL = NSURL(string: "https://live.adyen.com/hpp/directory.shtml")!
        if environment == .test {
            url = NSURL(string: "https://test.adyen.com/hpp/directory.shtml")!
        }
        return url
    }
    
    func hppDetailsURL() -> NSURL {
        var url: NSURL = NSURL(string: "https://live.adyen.com/hpp/details.shtml")!
        if environment == .test {
            url = NSURL(string: "https://test.adyen.com/hpp/details.shtml")!
        }
        return url
    }
    
}

//
//  Payment.swift
//  AdyenDL
//
//  Created by Oleg Lutsenko on 7/1/16.
//  Copyright © 2015 Adyen. All rights reserved.
//

import Foundation

/// Describes payment object.
open class Payment {
    
    let amount: Int
    let currency: String
    let country: String
    let merchantReference: String

    /**
     Initialise payment object with specified amount, currency and country code.
     Payment object will get a unique randomly generated merchantReference.
     
     - parameter amount:   Amount in minor units (i.e. 100).
     - parameter currency: Currency symbol (i.e. 'EUR').
     - parameter country:  Country code (i.e. 'NL').
     
     - returns: Initialised Payment object.
     */
    public convenience init(amount: Int, currency: String, country: String) {
        self.init(amount: amount, currency: currency, country: country, merchantReference: UUID().uuidString)
    }
    
    /**
     Initialise payment object with specified amount, currency, country code and merchant reference.

     
     - parameter amount:   Amount in minor units (i.e. 100).
     - parameter currency: Currency symbol (i.e. 'EUR').
     - parameter country:  Country code (i.e. 'NL').
     - parameter merchantReference: Merchant reference.
     
     - returns: Initialised Payment object.
     */
    public init(amount: Int, currency: String, country: String, merchantReference: String) {
        self.amount = amount
        self.currency = currency
        self.country = country
        self.merchantReference = merchantReference
    }

}

//  MARK: Private
extension Payment {
    
    func parameters() -> [String: String] {
        return ["paymentAmount": String(amount),
                "currencyCode": currency,
                "merchantReference":merchantReference,
                "countryCode": country]
    }
    
}

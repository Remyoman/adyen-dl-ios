//
//  PaymentMethod.swift
//  AdyenDL
//
//  Created by Oleg Lutsenko on 7/1/16.
//  Copyright © 2015 Adyen. All rights reserved.
//

import UIKit

/**
 Payment method types.
 
 - card:  Card payment method (VISA, AMEX etc.).
 - other: Local payment methods (iDEAL, PayPal etc.).
 */
public enum PaymentMethodType: Int {
    case card
    case other
}

/// Payment method information.
open class PaymentMethod : NSObject {

    /// Name of the payment method.
    open let name: String
    
    /// Payment method type.
    open let type: PaymentMethodType
    
    /// Issuers' payment methods (i.e. ING, ABN-AMRO etc. for iDEAL).
    open let issuers: [PaymentMethod]?

    let brandCode: String?
    let issuerId: String?
    
    convenience init(cardPaymentMethodWith submethods: [PaymentMethod]) {
        self.init(type: .card, name: "Card", brandCode: nil, issuerId: nil, submethods: submethods)
    }
    
    init(type: PaymentMethodType, name: String, brandCode: String?, issuerId: String?, submethods: [PaymentMethod]?) {
        self.name = name
        self.type = type
        self.issuers = submethods
        self.brandCode = brandCode
        self.issuerId = issuerId
    }
    
}

enum CardBrandCode: String {
    case mc
    case amex
    case jcb
    case diners
    case kcp_creditcard
    case hipercard
    case discover
    case elo
    case visa
    case unionpay
    case maestro
    case bcmc
    case cartebancaire
    case visadankort
    case bijcard
    case dankort
    case uatp
    case maestrouk
    case accel
    case cabal
    case pulse
    case star
    case nyce
    case hiper
    case cu24
    case argencard
    case netplus
    case shopping
    case warehouse
    case oasis
    case cencosud
    case chequedejeneur
    case karenmillen
}

private typealias Private = PaymentMethod
extension Private {

    func parameters() -> [String: String] {
        var result = [String: String]()
        if let brandCode = brandCode {
            result["brandCode"] = brandCode
        }
        if let issuerId = issuerId {
            result["issuerId"] = issuerId
        }
        return result
    }
    
}

public func ==(lhs: PaymentMethod, rhs: PaymentMethod) -> Bool {
    return lhs.name == rhs.name && lhs.type == rhs.type
}

extension PaymentMethod {
    override open var description: String {
        return name
    }
    
    override open var debugDescription: String {
        return name
    }
}

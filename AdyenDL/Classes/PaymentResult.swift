//
//  PaymentResult.swift
//  AdyenDL
//
//  Created by Oleg Lutsenko on 7/11/16.
//  Copyright © 2015 Adyen. All rights reserved.
//

import Foundation

/**
 Payment statuses.
 
 - authorised: Payment authorised.
 - refused:    Payment refused.
 - cancelled:  Payment cancelled.
 - pending:    Payment pending.
 - error:      Payment error.
 */
public enum PaymentStatus: String {
    case authorised
    case refused
    case cancelled
    case pending
    case error
}

/// Payment result information.
open class PaymentResult : NSObject {
    
    /// Payment object.
    open let payment: Payment
    
    /// Status of the payment.
    open let status: PaymentStatus
    
    init(payment: Payment, status: PaymentStatus) {
        self.payment = payment
        self.status = status
    }
    
}

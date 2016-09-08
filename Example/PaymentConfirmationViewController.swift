//
//  PaymentConfirmationViewController.swift
//  AdyenCheckout
//
//  Created by Oleg Lutsenko on 7/12/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import AdyenCheckout

class PaymentConfirmationViewController: UIViewController {
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func done(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func verifyResult(url: NSURL, paymentsProcessor: PaymentsProcessor) {
        let payment = Payment(amount: 0, currency: "", country: "")
        paymentsProcessor.verifyResult(url, forPayment: payment) { (result, error) in
            
            
            var status = "Error"
            if let result = result {
                status = result.status.rawValue
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.statusLabel.text = status
                
                self.activityIndicator.stopAnimating()
                self.doneButton.hidden = false
            })
        }
    }
}

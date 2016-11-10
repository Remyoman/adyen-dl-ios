//
//  PaymentResultViewController.swift
//  AdyenCheckout
//
//  Created by Oleg Lutsenko on 7/12/16.
//  Copyright © 2016 Adyen. All rights reserved.
//

import UIKit
import AdyenDL

class PaymentResultViewController: UIViewController {
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func done(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    func verifyResult(_ url: URL, paymentsProcessor: PaymentsProcessor) {
        let payment = Payment(amount: 0, currency: "", country: "")
        paymentsProcessor.verifyResult(url, forPayment: payment) { (result, error) in
            
            
            var status = "Error"
            if let result = result {
                status = result.status.rawValue
            }
            
            DispatchQueue.main.async(execute: {
                self.statusLabel.text = status
                
                self.activityIndicator.stopAnimating()
                self.doneButton.isHidden = false
            })
        }
    }
}

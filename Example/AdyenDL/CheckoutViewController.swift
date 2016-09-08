//
//  CheckoutViewController
//  AdyenDL
//
//  Created by Oleg Lutsenko on 9/6/16.
//  Copyright © 2016 Adyen. All rights reserved.
//

import UIKit
import AdyenDL

class CheckoutViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Products - Posters"
    }
    
    @IBAction func pay(sender: AnyObject) {
        let payment = Payment(amount: 10, currency: "EUR", country: "NL")
        
        let paymentPicker = PaymentPickerViewController(payment: payment)

        paymentPicker.completion = { url, paymentsProcessor in
            self.dismissViewControllerAnimated(false) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let confirmationVC = storyboard.instantiateViewControllerWithIdentifier("Confirmation") as! PaymentResultViewController
                self.presentViewController(confirmationVC, animated: false) {
                    confirmationVC.verifyResult(url, paymentsProcessor: paymentsProcessor)
                }
            }
        }

        let navigationController = UINavigationController(rootViewController: paymentPicker)
        navigationController.navigationBar.barTintColor = UIColor(red: 254/255, green: 40/255, blue: 81/255, alpha: 1)
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationController.navigationBar.tintColor = UIColor.whiteColor()
        presentViewController(navigationController, animated: true, completion: nil)
    }
}

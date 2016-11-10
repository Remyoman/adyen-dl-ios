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
    
    @IBAction func pay(_ sender: AnyObject) {
        let payment = Payment(amount: 1, currency: "EUR", country: "NL")
        
        let paymentPicker = PaymentPickerViewController(payment: payment)

        paymentPicker.completion = { url, paymentsProcessor in
            self.dismiss(animated: false) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let confirmationVC = storyboard.instantiateViewController(withIdentifier: "Confirmation") as! PaymentResultViewController
                self.present(confirmationVC, animated: false) {
                    confirmationVC.verifyResult(url, paymentsProcessor: paymentsProcessor)
                }
            }
        }

        let navigationController = UINavigationController(rootViewController: paymentPicker)
        navigationController.navigationBar.barTintColor = UIColor(red: 254/255, green: 40/255, blue: 81/255, alpha: 1)
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController.navigationBar.tintColor = UIColor.white
        present(navigationController, animated: true, completion: nil)
    }
}

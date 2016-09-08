//
//  PaymentPickerViewController.swift
//  AdyenCheckout
//
//  Created by Oleg Lutsenko on 7/5/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import SafariServices
import AdyenCheckout

class PaymentPickerViewController: LoadingTableViewController {
    var payment: Payment?
    var paymentMethods: [PaymentMethod]?
    
    lazy var testConfiguration: Configuration = {
        let signatureURL = NSURL(string: "http://www.mozuma.nl/adyen/api.php?method=calculateSignature&action=paymentInitiation&environment=test")!
        let resultSignatureURL = NSURL(string: "http://www.mozuma.nl/adyen/api.php?method=calculateSignature&action=paymentVerification&environment=test")!
        let statusURL = NSURL(string: "http://www.mozuma.nl/adyen/api.php?method=validateNotification&environment=test")!
        
        return Configuration(environment: .test,
                             paymentSignatureURL: signatureURL,
                             paymentResultSignatureURL: resultSignatureURL,
                             paymentStatusURL: statusURL)
    }()
    
    lazy var liveConfiguration: Configuration = {
//        http://node-merchant-server.herokuapp.com/calculateSignature?action=paymentInitiation&environment=test
//        let signatureURL = NSURL(string: "http://www.mozuma.nl/adyen/api.php?method=calculateSignature&action=paymentInitiation")!
        let signatureURL = NSURL(string: "http://node-merchant-server.herokuapp.com/calculateSignature?action=paymentInitiation&environment=live")!
        let resultSignatureURL = NSURL(string: "http://www.mozuma.nl/adyen/api.php?method=calculateSignature&action=paymentVerification")!
        let statusURL = NSURL(string: "http://www.mozuma.nl/adyen/api.php?method=validateNotification")!
        
        return Configuration(environment: .live,
                             paymentSignatureURL: signatureURL,
                             paymentResultSignatureURL: resultSignatureURL,
                             paymentStatusURL: statusURL)
    }()
    
    lazy var paymentsProcessor: PaymentsProcessor = {
        return PaymentsProcessor(configuration: self.liveConfiguration)
    }()
    
    var safariViewController: SFSafariViewController?
    
    var completion: ((url: NSURL, paymentsProcessor: PaymentsProcessor) -> ())?
    
    init(payment: Payment) {
        super.init(style: .Plain)
        
        self.payment = payment
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Select Payment"
        loading = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Cancel,
            target: self,
            action: #selector(self.cancelPayment))
        
        tableView.registerClass(LoadingTableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(PaymentPickerViewController.receivedUrlNotification),
            name: openUrlNotification,
            object: nil)
        
        fetchPayments()
    }

    func cancelPayment() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func receivedUrlNotification() {
        if let url = receivedUrl {
            completion?(url: url, paymentsProcessor: paymentsProcessor)
        }
    }
    
    func fetchPayments() {
        guard let payment = payment else {
            return
        }
        
        paymentsProcessor.fetchPaymentMethodsFor(payment) { (payments, error) in
            guard let paymentMethods = payments else {
                return
            }
            
            self.paymentMethods = paymentMethods
            self.loading = false
            
            dispatch_async(dispatch_get_main_queue(), { 
                self.tableView.reloadData()
            })
        }
    }
}

private typealias TableViewFunctions = PaymentPickerViewController
extension TableViewFunctions {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return paymentMethods?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let method = paymentMethods?[section]
        return method?.issuers == nil ? " " : method?.name
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethods?[section].issuers?.count ?? 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let method = paymentMethods?[indexPath.section]
        if method?.issuers != nil {
            cell.textLabel?.text = method?.issuers?[indexPath.row].name
        } else {
            cell.textLabel?.text = method?.name
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        guard let payment = payment else {
            return
        }

        let cell = tableView.cellForRowAtIndexPath(indexPath) as? LoadingTableViewCell
        if let cell = cell {
            cell.startLoadingAnimation()
        }

        var method = paymentMethods?[indexPath.section]
        if method?.issuers != nil {
            method = method?.issuers?[indexPath.row]
        }
        
        paymentsProcessor.fetchPayURLFor(payment, payingWith: method!) {[weak self] (url, error) in
            if let cell = cell {
                cell.stopLoadingAnimation()
            }

            guard let url = url else {
                return
            }
            
            self?.safariViewController = SFSafariViewController(URL: url)
            self?.safariViewController?.modalPresentationStyle = .FormSheet
            self?.presentViewController(self!.safariViewController!, animated: true, completion: nil)
        }
    }
}

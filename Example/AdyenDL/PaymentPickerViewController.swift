//
//  PaymentPickerViewController.swift
//  AdyenCheckout
//
//  Created by Oleg Lutsenko on 7/5/16.
//  Copyright © 2016 Adyen. All rights reserved.
//

import UIKit
import SafariServices
import AdyenDL

class PaymentPickerViewController: LoadingTableViewController {
    var payment: Payment?
    var paymentMethods: [PaymentMethod]?

    lazy var liveConfiguration: Configuration = {
        let signatureURL =          //  PROVIDE URL
        let resultSignatureURL =    //  PROVIDE URL
        let statusURL =             //  PROVIDE URL
        
        return Configuration(environment: .live,
                             paymentSignatureURL: signatureURL,
                             paymentResultSignatureURL: resultSignatureURL,
                             paymentStatusURL: statusURL)
    }()
    
    lazy var paymentsProcessor: PaymentsProcessor = {
        return PaymentsProcessor(configuration: self.liveConfiguration)
    }()
    
    var safariViewController: SFSafariViewController?
    
    var completion: ((_ url: URL, _ paymentsProcessor: PaymentsProcessor) -> ())?
    
    init(payment: Payment) {
        super.init(style: .plain)
        
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
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(self.cancelPayment))
        
        tableView.register(LoadingTableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(PaymentPickerViewController.receivedUrlNotification),
            name: NSNotification.Name(rawValue: ApplicationDidReceiveResultURLNotification),
            object: nil)
        
        fetchPayments()
    }

    func cancelPayment() {
        dismiss(animated: true, completion: nil)
    }

    func receivedUrlNotification() {
        if let url = resultURL {
            completion?(url, paymentsProcessor)
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
            
            DispatchQueue.main.async(execute: { 
                self.tableView.reloadData()
            })
        }
    }
}

private typealias TableViewFunctions = PaymentPickerViewController
extension TableViewFunctions {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return paymentMethods?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let method = paymentMethods?[section]
        return method?.issuers == nil ? " " : method?.name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paymentMethods?[section].issuers?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let method = paymentMethods?[indexPath.section]
        if method?.issuers != nil {
            cell.textLabel?.text = method?.issuers?[indexPath.row].name
        } else {
            cell.textLabel?.text = method?.name
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let payment = payment else {
            return
        }

        let cell = tableView.cellForRow(at: indexPath) as? LoadingTableViewCell
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
            
            self?.safariViewController = SFSafariViewController(url: url)
            self?.safariViewController?.modalPresentationStyle = .formSheet
            self?.present(self!.safariViewController!, animated: true, completion: nil)
        }
    }
}

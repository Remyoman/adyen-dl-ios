//
//  LoadingTableViewController.swift
//  AdyenCheckout
//
//  Created by Oleg Lutsenko on 7/5/16.
//  Copyright © 2016 Adyen. All rights reserved.
//

import UIKit

class LoadingTableViewController: UITableViewController {

    let loadingView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    fileprivate var _loading = false
    var loading: Bool {
        get {
            return _loading
        }
        
        set {
            _loading = newValue
            self.updateUI()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = true
        loadingView.stopAnimating()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        view.addConstraint(
            NSLayoutConstraint(
                item: loadingView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: loadingView,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerY,
                multiplier: 1,
                constant: 0
            )
        )
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            
            self.loadingView.isHidden = !self.loading
            
            if self.loading {
                self.loadingView.startAnimating()
            } else {
                self.loadingView.stopAnimating()
            }
            
        }
    }

}

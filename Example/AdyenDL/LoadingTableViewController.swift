//
//  LoadingTableViewController.swift
//  AdyenCheckout
//
//  Created by Oleg Lutsenko on 7/5/16.
//  Copyright © 2016 Adyen. All rights reserved.
//

import UIKit

class LoadingTableViewController: UITableViewController {

    let loadingView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    private var _loading = false
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
        
        loadingView.hidden = true
        loadingView.stopAnimating()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingView)
        view.addConstraint(
            NSLayoutConstraint(
                item: loadingView,
                attribute: .CenterX,
                relatedBy: .Equal,
                toItem: view,
                attribute: .CenterX,
                multiplier: 1,
                constant: 0
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: loadingView,
                attribute: .CenterY,
                relatedBy: .Equal,
                toItem: view,
                attribute: .CenterY,
                multiplier: 1,
                constant: 0
            )
        )
    }
    
    func updateUI() {
        dispatch_async(dispatch_get_main_queue()) {
            
            self.loadingView.hidden = !self.loading
            
            if self.loading {
                self.loadingView.startAnimating()
            } else {
                self.loadingView.stopAnimating()
            }
            
        }
    }

}

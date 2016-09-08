//
//  LoadingTableViewCell.swift
//  AdyenCheckout
//
//  Created by Oleg Lutsenko on 7/14/16.
//  Copyright © 2016 Adyen. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryView = loadingIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startLoadingAnimation() {
        dispatch_async(dispatch_get_main_queue()) {
            self.loadingIndicator.startAnimating()
        }
    }
    
    func stopLoadingAnimation() {
        dispatch_async(dispatch_get_main_queue()) {
            self.loadingIndicator.stopAnimating()
        }
    }
}
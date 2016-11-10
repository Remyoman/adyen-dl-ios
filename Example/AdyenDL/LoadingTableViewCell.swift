//
//  LoadingTableViewCell.swift
//  AdyenCheckout
//
//  Created by Oleg Lutsenko on 7/14/16.
//  Copyright © 2016 Adyen. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryView = loadingIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startLoadingAnimation() {
        DispatchQueue.main.async {
            self.loadingIndicator.startAnimating()
        }
    }
    
    func stopLoadingAnimation() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
        }
    }
}

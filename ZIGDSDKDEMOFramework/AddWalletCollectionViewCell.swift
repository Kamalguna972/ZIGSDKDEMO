//
//  AddWalletCollectionViewCell.swift
//  SwiftFramework
//
//  Created by Ashok on 05/09/24.
//

import UIKit

class AddWalletCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var listedAmount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        amountView.backgroundColor = UIColor.red
        listedAmount.textColor = UIColor.white
        
        amountView.layer.cornerRadius = 10
        amountView.layer.masksToBounds = false
        
    }
}

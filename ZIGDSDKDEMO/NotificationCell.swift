//
//  NotificationCell.swift
//  SwiftFramework
//
//  Created by Ashok on 21/08/24.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var allowBtn: UIButton!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var mainView: UIView!
    var TicketAction : (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        mainView.layer.cornerRadius = 10
        allowBtn.layer.cornerRadius = allowBtn.frame.height/2
        allowBtn.backgroundColor = UIColor.black
        allowBtn.tintColor = UIColor.white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }
    @IBAction func allowAction(_ sender: Any) {
        TicketAction?()
    }
    
}

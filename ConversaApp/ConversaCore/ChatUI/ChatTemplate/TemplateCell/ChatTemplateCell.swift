//
//  ChatTemplateCell.swift
//  ConversaApp
//
//  Created by Ansyar Hafid on 18/09/21.
//  Copyright © 2021 Erlang Solutions. All rights reserved.
//

import UIKit

class ChatTemplateCell: UITableViewCell {
    
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cellButton: UIButton!
    
    var message: String! {
        didSet {
            messageLabel.text = message
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        customView.layer.cornerRadius = 5
        customView.backgroundColor = UIColor(red: 209.0/255.0, green: 209.0/255.0, blue: 209.0/255.0, alpha: 1.0)
        messageLabel.textColor = .darkGray
    }
    
    override func prepareForReuse() {
        messageLabel.text = ""
        customView.backgroundColor = UIColor(red: 209.0/255.0, green: 209.0/255.0, blue: 209.0/255.0, alpha: 1.0)
        messageLabel.textColor = .darkGray
    }

}

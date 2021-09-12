//
//  ChatMyTextCell.swift
//  ConversaApp
//
//  Created by Ansyar Hafid on 12/09/21.
//  Copyright © 2021 Erlang Solutions. All rights reserved.
//

import UIKit

class ChatMyTextCell: UITableViewCell {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var chatStatus: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    
    var item: ConversaMessage! {
        didSet {
            textView.text = item.message?.body
            userNameLabel.text = item.message?.from?.resource
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yy hh:mm a"
            if let date = item.message?.delayedDeliveryDate {
                timeStamp.text = dateFormatter.string(from: date)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textView.layer.borderColor = UIColor.white.cgColor
        self.textView.layer.borderWidth = 1
        self.textView.layer.cornerRadius = 10
        self.textView.translatesAutoresizingMaskIntoConstraints = false
    }
}

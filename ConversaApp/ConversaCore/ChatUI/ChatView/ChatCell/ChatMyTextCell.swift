//
//  ChatMyTextCell.swift
//  ConversaApp
//
//  Created by Ansyar Hafid on 12/09/21.
//  Copyright © 2021 Erlang Solutions. All rights reserved.
//

import UIKit

class ChatMyTextCell: UITableViewCell {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var chatStatus: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    
    var item: ConversaMessage! {
        didSet {
            textView.text = item.message?.body
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm"
            if let date = item.message?.delayedDeliveryDate {
                timeStamp.text = dateFormatter.string(from: date)
            }
            
            if item.message?.hasReceiptResponse == true {
                self.chatStatus.image = UIImage(named: "chatCellSent")
            }
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.chatStatus.image = UIImage(named: "chatCellSend")
        self.chatStatus.widthAnchor.constraint(equalToConstant: 15).isActive = true
        self.chatStatus.heightAnchor.constraint(equalToConstant: 15).isActive = true
        
        self.textView.layer.borderColor = UIColor.white.cgColor
        self.textView.layer.borderWidth = 1
        self.textView.layer.cornerRadius = 10
        self.textView.translatesAutoresizingMaskIntoConstraints = false
    }
}

//
//  ChatBar.swift
//  ConversaApp
//
//  Created by Ansyar Hafid on 10/09/21.
//  Copyright © 2021 Erlang Solutions. All rights reserved.
//

import UIKit

class ChatBar: UIView {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var chatBarBuble: UIButton!
    @IBOutlet weak var chatBarImage: UIButton!
    @IBOutlet weak var chatBarField: UITextField!
    @IBOutlet weak var chatBarSend: UIButton!
    @IBOutlet weak var chatBarMic: UIButton!
    @IBOutlet weak var recordTime: UILabel!
    @IBOutlet weak var buttonContainer: UIStackView!
    @IBOutlet weak var cancelRecord: UIButton!
    @IBOutlet weak var sendRecord: UIButton!
    
    var isVoice = false
    var isTemplate = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSubViews()
    }
    
    private func initSubViews() {
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: Bundle(for: type(of: self)))
        nib.instantiate(withOwner: self, options: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        addConstraints()
        cancelRecord.layer.cornerRadius = 5
        sendRecord.layer.cornerRadius = 5
        chatBarSend.tintColor = UIColor(red: 1.0/255.0, green: 152.0/255.0, blue: 215.0/255.0, alpha: 1.0)
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @IBAction func cancelButtonClicked() {
        isVoice = false
        toggleVoice()
    }
    
    func toggleVoice() {
        chatBarBuble.isHidden = isVoice
        chatBarImage.isHidden = isVoice
        chatBarField.isHidden = isVoice
        recordTime.isHidden = !isVoice
        buttonContainer.isHidden = !isVoice
        chatBarMic.tintColor = isVoice ? .red : .darkGray
    }
    
    func toggleTemplate() {
        chatBarMic.isHidden = isTemplate
        chatBarSend.isHidden = !isTemplate
    }
}

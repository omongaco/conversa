//
//  ChatView.swift
//  ConversaApp
//
//  Created by Ansyar Hafid on 10/09/21.
//  Copyright © 2021 Erlang Solutions. All rights reserved.
//

import UIKit
import PhotosUI

class ChatView: UIView {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var chatHeader: ChatHeader!
    @IBOutlet weak var chatTableContainer: UIView!
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var chatBar: ChatBar!
    
    var spacer: UIView?
    var chatTemplate: ChatTemplate?
    var messages: [ConversaMessage] = []
    var isChatTemplate = false
    
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
        setupSpacer()
        setupChatHeader()
        setupChatTable()
        setupChatBar()
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupSpacer() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resignReponder)))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardRect = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
            if spacer == nil {
                spacer = UIView()
                stackView.addArrangedSubview(spacer!)
                var safeBottom = CGFloat(0)
                if #available(iOS 13.0, *) {
                    if let window = UIApplication.shared.keyWindow {
                        safeBottom = window.safeAreaInsets.bottom
                    }
                }
                spacer?.heightAnchor.constraint(equalToConstant: keyboardRect.height - safeBottom).isActive = true
            }
        }
    }

    @objc func keyBoardWillHide(notification: Notification) {
        if spacer != nil {
            stackView.removeArrangedSubview(spacer!)
            spacer = nil
        }
    }
    
    @objc func keyBoardDidShow(notification: Notification) {
        scrollTableToBottom()
    }
    
    @objc func resignReponder() {
        chatBar.chatBarField.resignFirstResponder()
    }
    
    private func setupChatTable() {
        let tableBg = UIImageView(image: UIImage(named: "chatTableBg"))
        tableBg.frame = CGRect(x: 0, y: -44, width: chatTableContainer.frame.size.width, height: 65)
        chatTableContainer.addSubview(tableBg)
        
        chatTable.delegate = self
        chatTable.dataSource = self
        chatTable.tableFooterView = UIView()
        chatTable.separatorStyle = .none
        chatTable.register(UINib(nibName: "ChatMyTextCell", bundle: nil), forCellReuseIdentifier: "ChatMyTextCell")
        chatTable.register(UINib(nibName: "ChatOtherTextCell", bundle: nil), forCellReuseIdentifier: "ChatOtherTextCell")
    }
    
    private func setupChatHeader() {
        // To do

    }
    
    private func setupChatBar() {
        chatBar.chatBarBuble.addTarget(self, action: #selector(bubbleChatClicked), for: .touchUpInside)
        chatBar.chatBarImage.addTarget(self, action: #selector(imageChatClicked), for: .touchUpInside)
        chatBar.chatBarMic.addTarget(self, action: #selector(voiceChatClicked), for: .touchUpInside)
        chatBar.chatBarSend.addTarget(self, action: #selector(messageButtonClicked), for: .touchUpInside)
        chatBar.chatBarField.delegate = self
    }
}

extension ChatView {
    @objc func messageButtonClicked() {
        if let text = chatBar.chatBarField.text {
            sendMessage(message: text)
        }
        
        chatBar.chatBarField.text = ""
        bubbleChatClicked()
    }
    
    @objc func bubbleChatClicked() {
        if isChatTemplate {
            if chatTemplate != nil {
                chatTemplate?.removeFromSuperview()
                chatTemplate = nil
                chatBar.chatBarBuble.setImage(UIImage(named: "chatBarBubbleIcon"), for: .normal)
                chatBar.isTemplate = false
                chatBar.toggleTemplate()
                isChatTemplate = false
            }
        } else {
            if chatTemplate == nil {
                chatTemplate = ChatTemplate()
                chatTemplate!.delegate = self
                stackView.addArrangedSubview(chatTemplate!)
                var safeBottom = CGFloat(0)
                if #available(iOS 13.0, *) {
                    if let window = UIApplication.shared.keyWindow {
                        safeBottom = window.safeAreaInsets.bottom
                    }
                }
                chatTemplate!.heightAnchor.constraint(equalToConstant: 313 - safeBottom).isActive = true
                chatBar.chatBarBuble.setImage(UIImage(named: "chatBarKeyboard"), for: .normal)
                chatBar.isTemplate = true
                chatBar.toggleTemplate()
                isChatTemplate = true
            }
        }
    }
    
    @objc func imageChatClicked() {
        let alertController = UIAlertController(title: "Image", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Take a Photo", style: .default, handler: { action in
            //
        }))
        
        alertController.addAction(UIAlertAction(title: "Add from gallery", style: .default, handler: { action in
            //
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        var parentView = UIApplication.shared.keyWindow?.rootViewController
        while parentView?.presentedViewController != nil {
            parentView = parentView?.presentedViewController
        }

        parentView?.present(alertController, animated: true, completion: nil)
    }
    
    @objc func voiceChatClicked() {
        chatBar.isVoice = chatBar.isVoice ? false : true
        chatBar.toggleVoice()
    }
    
    func loadMessages() {
        chatTable.reloadData()
        scrollTableToBottom()
    }
    
    func scrollTableToBottom() {
        if chatTable != nil && messages.count > 0 {
            chatTable.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .top, animated: true)
        }
    }
}

extension ChatView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headStack = UIStackView()
        headStack.axis = .vertical
        headStack.alignment = .center
        
        let labelContainer = UIView()
        headStack.addArrangedSubview(labelContainer)
        if #available(iOS 13.0, *) {
            labelContainer.backgroundColor = .systemGray6
        } else {
            labelContainer.backgroundColor = .lightGray
        }
        labelContainer.layer.cornerRadius = 5
        labelContainer.widthAnchor.constraint(equalToConstant: 200).isActive = true
        labelContainer.heightAnchor.constraint(equalToConstant: 44).isActive = true
        labelContainer.topAnchor.constraint(equalTo: headStack.topAnchor, constant: 10).isActive = true
        
        let dateLabel = UILabel()
        dateLabel.textColor = .darkGray
        dateLabel.textAlignment = .center
        dateLabel.font = UIFont(name: "Thonburi", size: 12)
        labelContainer.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.topAnchor.constraint(equalTo: labelContainer.topAnchor).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: labelContainer.bottomAnchor).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: labelContainer.leadingAnchor).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: labelContainer.trailingAnchor).isActive = true

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM dd yyyy"
        dateLabel.text = dateFormatter.string(from: Date())
        
        return headStack
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard messages.count > 0 else {
            return UITableViewCell()
        }
        
        guard let myJid = XMPPManager.sharedInstance.xmppStream.myJID else {
            return UITableViewCell()
        }
        
        let dataRow = messages[indexPath.row]

        if let sender = dataRow.message?.from {
            if sender.resource == myJid.user {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMyTextCell", for: indexPath) as! ChatMyTextCell
                cell.item = dataRow
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatOtherTextCell", for: indexPath) as! ChatOtherTextCell
                cell.item = dataRow
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
}

extension ChatView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            sendMessage(message: text)
        }
        
        textField.text = ""
        textField.resignFirstResponder()
        
        return true
    }
    
    func sendMessage(message: String) {
        if let xmppRoom = XMPPManager.sharedInstance.xmppRoom {
            xmppRoom.sendMessage(withBody: message)
        }
    }
}

extension ChatView: ChatTemplateProtocol {
    func messageDidSelected(message: String) {
        chatBar.chatBarField.text = message
    }
}

//
//  ChatView.swift
//  ConversaApp
//
//  Created by Ansyar Hafid on 10/09/21.
//  Copyright © 2021 Erlang Solutions. All rights reserved.
//

import UIKit

class ChatView: UIView {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var chatHeader: ChatHeader!
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var chatBar: ChatBar!
    @IBOutlet weak var spacer: UIView!
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resignReponder)))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyBoardWillShow(notification: Notification) {
        if let keyboardRect = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
            spacer.heightAnchor.constraint(equalToConstant: keyboardRect.height).isActive = true
        }
    }

    @objc func keyBoardDidHide(notification: Notification) {
        spacer.heightAnchor.constraint(equalToConstant: 0).isActive = true
    }
    
    @objc func resignReponder() {
        chatBar.chatBarField.resignFirstResponder()
    }
    
    private func setupChatTable() {
        chatTable.tableFooterView = UIView()
        chatTable.separatorStyle = .none
        let tableBg = UIImageView(image: UIImage(named: "chatTableBg"))
        tableBg.frame = CGRect(x: 0, y: -44, width: chatTable.frame.size.width, height: 65)
        chatTable.addSubview(tableBg)
    }
    
    private func setupChatHeader() {
        // To do

    }
    
    private func setupChatBar() {
        // To do
    }
}

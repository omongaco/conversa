//
//  ChatTemplate.swift
//  ConversaApp
//
//  Created by Ansyar Hafid on 18/09/21.
//  Copyright © 2021 Erlang Solutions. All rights reserved.
//

import UIKit

protocol ChatTemplateProtocol {
    func messageDidSelected(message: String)
}

class ChatTemplate: UIView {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var templateTable: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addLabel: UILabel!
    
    var chatTemplates: [String] = []
    var delegate: ChatTemplateProtocol?
    let textView = UITextView(frame: CGRect.zero)
    
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
    }
    
    private func addConstraints() {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        setupTableView()
    }
    
    private func setupTableView() {
        templateTable.register(UINib(nibName: "ChatTemplateCell", bundle: nil), forCellReuseIdentifier: "ChatTemplateCell")
        templateTable.tableFooterView = UIView()
        templateTable.allowsSelection = false
        templateTable.separatorStyle = .none
        templateTable.dataSource = self
        templateTable.delegate = self
        
        addButton.addTarget(self, action: #selector(addButtonCLicked), for: .touchUpInside)
        
        initiateData()
    }
    
    private func initiateData() {
        guard let bundlePath = Bundle.main.path(forResource: "ChatTemplate", ofType: "plist") else {
            return
        }
        
        let url = URL(fileURLWithPath: bundlePath)
        
        do {
            let data = try Data(contentsOf: url)
            if let plist = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String] {
                chatTemplates = plist
                self.templateTable.reloadData()
            }
        } catch {
            print("Chat Template Error: \(error)")
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds"{
            if let rect = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgRectValue {
                let margin: CGFloat = 15
                let xPos = rect.origin.x + margin
                let yPos = rect.origin.y + 54
                let width = rect.width - 2 * margin
                let height: CGFloat = 90

                textView.frame = CGRect.init(x: xPos, y: yPos, width: width, height: height)
            }
        }
    }
}

extension ChatTemplate: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatTemplates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatTemplateCell", for: indexPath) as! ChatTemplateCell
        guard chatTemplates.count > 0 else {
            return cell
        }
        // Customize selection
        cell.cellButton.tag = indexPath.row
        cell.cellButton.addTarget(self, action: #selector(messageEditClicked(sender:)), for: .touchUpInside)
        
        cell.customView.tag = indexPath.row
        cell.customView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(templateSelected(_:))))
        
        //  assign message
        cell.message = chatTemplates[indexPath.row]
        
        return cell
    }
    
    @objc func templateSelected(_ sender: UIGestureRecognizer) {
        guard chatTemplates.count > 0 else {
            return
        }
        
        guard let view = sender.view else {
            return
        }
        
        templateTable.reloadData()
        
        let cell = templateTable.cellForRow(at: IndexPath(row: view.tag, section: 0)) as! ChatTemplateCell
        cell.customView.backgroundColor = UIColor(red: 1.0/255.0, green: 152.0/255.0, blue: 215.0/255.0, alpha: 1.0)
        cell.messageLabel.textColor = .white
        
        let message = chatTemplates[view.tag]
        delegate?.messageDidSelected(message: message)
        print("Selected Message: \(message)")
    }
    
    @objc func messageEditClicked(sender: UIButton) {
        let alertController = UIAlertController(title: "Template Message", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Edit", style: .default, handler: { action in
            self.editMessageTemplate(index: sender.tag)
        }))
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .default, handler: { action in
            self.deleteMessage(index: sender.tag)
        }))
        
        var parentView = UIApplication.shared.keyWindow?.rootViewController
        while parentView?.presentedViewController != nil {
            parentView = parentView?.presentedViewController
        }
        parentView?.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func addButtonCLicked() {
        var parentView = UIApplication.shared.keyWindow?.rootViewController
        while parentView?.presentedViewController != nil {
            parentView = parentView?.presentedViewController
        }

        let titlePrefix = "Add Message"
        
        let alertController = UIAlertController(title: "\(titlePrefix) \n\n\n\n\n", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            alertController.view.removeObserver(self, forKeyPath: "bounds")
        }))
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
            alertController.view.removeObserver(self, forKeyPath: "bounds")
            if let enteredText = self.textView.text {
                print(enteredText)
                self.messageTemplateSaved(message: enteredText)
                self.textView.text = ""
            }
        }))

        alertController.view.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.new, context: nil)
        textView.backgroundColor = UIColor(red: 245.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        textView.textContainerInset = UIEdgeInsets.init(top: 8, left: 5, bottom: 8, right: 5)
        alertController.view.addSubview(textView)

        parentView?.present(alertController, animated: true, completion: nil)
    }
    
    @objc func deleteMessage(index: Int) {
        let alertController = UIAlertController(title: "Are you sure to delete this message template?", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            guard let bundlePath = Bundle.main.path(forResource: "ChatTemplate", ofType: "plist") else {
                return
            }
            
            let url = URL(fileURLWithPath: bundlePath)
            
            do {
                let data = try Data(contentsOf: url)
                if var messages = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String] {
                    messages.remove(at: index)
                    let updatedData = try PropertyListSerialization.data(fromPropertyList: messages, format: .binary, options: .zero)
                    try updatedData.write(to: url)
                    self.initiateData()
                }
            } catch {
                print("Chat Template Error: \(error)")
            }
        }))
        
        var parentView = UIApplication.shared.keyWindow?.rootViewController
        while parentView?.presentedViewController != nil {
            parentView = parentView?.presentedViewController
        }
        parentView?.present(alertController, animated: true, completion: nil)
    }
    
    @objc func editMessageTemplate(index: Int) {
        guard let bundlePath = Bundle.main.path(forResource: "ChatTemplate", ofType: "plist") else {
            return
        }
        
        let url = URL(fileURLWithPath: bundlePath)
        var messages = [String]()
        
        do {
            let data = try Data(contentsOf: url)
            if let plistData = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String] {
                messages = plistData
                let editedMessage = messages[index]
                self.textView.text = editedMessage
            }
        } catch {
            print("Chat Template Error: \(error)")
        }
        
        var parentView = UIApplication.shared.keyWindow?.rootViewController
        while parentView?.presentedViewController != nil {
            parentView = parentView?.presentedViewController
        }

        let titlePrefix = "Edit Message"
        
        let alertController = UIAlertController(title: "\(titlePrefix) \n\n\n\n\n", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
            alertController.view.removeObserver(self, forKeyPath: "bounds")
        }))
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { action in
            alertController.view.removeObserver(self, forKeyPath: "bounds")
            if let enteredText = self.textView.text {
                print(enteredText)
                do {
                    let data = try Data(contentsOf: url)
                    if var messages = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String] {
                        messages.remove(at: index)
                        messages.insert(enteredText, at: index)
                        let updatedData = try PropertyListSerialization.data(fromPropertyList: messages, format: .binary, options: .zero)
                        try updatedData.write(to: url)
                        self.initiateData()
                    }
                } catch {
                    print("Chat Template Error: \(error)")
                }
            }
        }))

        alertController.view.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.new, context: nil)
        textView.backgroundColor = UIColor(red: 245.0/255.0, green: 244.0/255.0, blue: 244.0/255.0, alpha: 1.0)
        textView.textContainerInset = UIEdgeInsets.init(top: 8, left: 5, bottom: 8, right: 5)
        alertController.view.addSubview(textView)

        parentView?.present(alertController, animated: true, completion: nil)
    }
    
    @objc func messageTemplateSaved(message: String) {
        guard let bundlePath = Bundle.main.path(forResource: "ChatTemplate", ofType: "plist") else {
            return
        }
        
        let url = URL(fileURLWithPath: bundlePath)
        
        do {
            let data = try Data(contentsOf: url)
            if var messages = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String] {
                messages.append(message)
                let updatedData = try PropertyListSerialization.data(fromPropertyList: messages, format: .binary, options: .zero)
                try updatedData.write(to: url)
                self.initiateData()
            }
        } catch {
            print("Chat Template Error: \(error)")
        }
    }
}

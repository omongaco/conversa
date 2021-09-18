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
}

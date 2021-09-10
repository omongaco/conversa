//
//  ChatHeader.swift
//  ConversaApp
//
//  Created by Ansyar Hafid on 10/09/21.
//  Copyright © 2021 Erlang Solutions. All rights reserved.
//

import UIKit

class ChatHeader: UIView {
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userDescription: UILabel!
    
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
    }
}

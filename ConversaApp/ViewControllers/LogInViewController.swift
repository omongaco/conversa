//
//  LoginViewController.swift
//  ConversaApp
//
//  Created by Ansyar on 8/22/21.
//  Copyright © 2021 Ansyar. All rights reserved.
//

import UIKit
import XMPPFramework
import MBProgressHUD

class LogInViewController: UIViewController {

	@IBOutlet weak var userJIDLabel: UITextField!
	@IBOutlet weak var userPasswordLabel: UITextField!
	@IBOutlet weak var errorLabel: UILabel!

	weak var delegate:LogInViewControllerDelegate?
	var hud: MBProgressHUD!
	
    override func viewDidLoad() {
        super.viewDidLoad()
	}

	@IBAction func logInAction(sender: AnyObject) {
		if self.userJIDLabel.text?.count == 0
		  || self.userPasswordLabel.text?.count == 0 {
				
			self.errorLabel.text = "Something is missing or wrong!"
			return
		}

        guard let _ = XMPPJID(string: self.userJIDLabel.text!) else {
			self.errorLabel.text = "Username is not a jid!"
			return
		}

        self.hud = MBProgressHUD.showAdded(to: self.view, animated: true)
		self.hud.label.text = "Signing in..."
		
        self.delegate?.didTouchLogIn(sender: self, userJID: self.userJIDLabel.text!, userPassword: self.userPasswordLabel.text!)
	}
	
	func showErrorMessage(message: String) {
		hud.mode = .text
		hud.label.text = message
		hud.hide(animated: true, afterDelay: 1.5)
	}

}

protocol LogInViewControllerDelegate: AnyObject {
	func didTouchLogIn(sender: LogInViewController, userJID: String, userPassword: String)
}

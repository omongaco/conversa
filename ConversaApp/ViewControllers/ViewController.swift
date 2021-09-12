//
//  ViewController.swift
//  ConversaApp
//
//  Created by Ansyar on 8/22/21.
//  Copyright © 2021 Ansyar. All rights reserved.
//

import UIKit
import XMPPFramework

class ViewController: UIViewController {

    @IBOutlet weak var chatView: ChatView!
    
    weak var logInViewController: LogInViewController?
    var logInPresented = false
    var xmppManager: XMPPManager!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !self.logInPresented {
            self.logInPresented = true
            self.performSegue(withIdentifier: "LogInViewController", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LogInViewController" {
            let viewController = segue.destination as! LogInViewController
            viewController.delegate = self
        }
    }
}

extension ViewController: LogInViewControllerDelegate {
    func didTouchLogIn(sender: LogInViewController, userJID: String, userPassword: String) {
        self.logInViewController = sender
        
        xmppManager = XMPPManager.sharedInstance
        xmppManager.setupUser(userId: userJID,password: userPassword)
        xmppManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppManager.connect()
        xmppManager.messageDelegate = self
    }
}

extension ViewController: XMPPStreamDelegate {
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        self.logInViewController?.dismiss(animated: true, completion: nil)
    }
    
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        self.logInViewController?.showErrorMessage(message: "Wrong password or username")
    }
}

extension ViewController: MessageDelegate {
    func messageReceived(message: ConversaMessage) {
        chatView.messages.append(message)
        chatView.loadMessages()
    }
}

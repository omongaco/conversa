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
    
    @IBOutlet weak var joinButton: UIButton!
    
    weak var logInViewController: LogInViewController?
    var logInPresented = false
    let xmppManager = XMPPManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        joinButton.isEnabled = false
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
    
    @IBAction func joinRoom(_ sender: Any) {
        let chatController = ConversaChatController(nibName: "ConversaChatController", bundle: nil)
        chatController.modalPresentationStyle = .overCurrentContext
        self.present(chatController, animated: true, completion: nil)
    }
}

extension ViewController: LogInViewControllerDelegate {
    func didTouchLogIn(sender: LogInViewController, userJID: String) {
        self.logInViewController = sender
        
        let conversaAPI = ConversaAPI.shared
        conversaAPI.getToken(userId: userJID) { token, error in
            guard let token = token, error == nil else {
                DispatchQueue.main.async {
                    self.logInViewController?.showErrorMessage(message: "Connect Failed!")
                }
                return
            }
            
            self.xmppManager.setupUser(userId: userJID,password: token)
            self.xmppManager.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
            self.xmppManager.connect()
        }
    }
}

extension ViewController: XMPPStreamDelegate {
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        self.logInViewController?.dismiss(animated: true, completion: nil)
        self.joinButton.isEnabled = true
    }
    
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        self.logInViewController?.showErrorMessage(message: "Wrong password or username")
    }
}

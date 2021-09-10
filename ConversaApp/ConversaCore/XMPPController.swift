//
//  XMPPController.swift
//  ConversaApp
//
//  Created by Ansyar on 8/22/21.
//  Copyright © 2021 Ansyar. All rights reserved.
//

import Foundation
import XMPPFramework



class XMPPController: NSObject {
	var xmppStream: XMPPStream
    
    init(userId: String, password: String) throws {
        UserDefaults.standard.setValue(userId, forKey: keyUserID)
        UserDefaults.standard.setValue(password, forKey: keyUserPass)
        self.xmppStream = XMPPStream()
        super.init()
        do {
            try setupXmppStream()
        } catch {
            
        }
        
    }
    
    func setupXmppStream() throws {
        guard let userId = UserDefaults.standard.string(forKey: keyUserID) else {
            throw XMPPControllerError.missingUserID
        }
        
        guard let userJID = XMPPJID(string: userId) else {
            throw XMPPControllerError.wrongUserJID
        }
        
        // Stream Configuration
        self.xmppStream.hostName = hostName
        self.xmppStream.hostPort = hostPort
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        self.xmppStream.myJID = userJID
        
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
	
	func connect() {
		if !self.xmppStream.isDisconnected() {
			return
		}

        try! self.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
	}
}

extension XMPPController: XMPPStreamDelegate {
	
	func xmppStreamDidConnect(_ stream: XMPPStream!) {
		print("Stream: Connected")
        
        guard let userPass = UserDefaults.standard.string(forKey: keyUserPass) else {
            print("Stream: UserPassword Required")
            return
        }
        
        do {
            try stream.authenticate(withPassword: userPass)
        } catch {
            print("Stream Error: \(error)")
        }
		
	}
	
	func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
		self.xmppStream.send(XMPPPresence())
		print("Stream: Authenticated")
	}
	
	func xmppStream(_ sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
		print("Stream: Fail to Authenticate")
	}
}

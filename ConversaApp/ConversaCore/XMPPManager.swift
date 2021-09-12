//
//  XMPPManager.swift
//  ConversaApp
//
//  Created by Ansyar on 8/22/21.
//  Copyright © 2021 Ansyar. All rights reserved.
//

import Foundation
import XMPPFramework

protocol MessageDelegate {
    func messageReceived(message: ConversaMessage)
}

class XMPPManager: NSObject {
    static let sharedInstance = XMPPManager()
	
    var xmppStream: XMPPStream
    var xmppRoom: XMPPRoom?
    var messageDelegate: MessageDelegate?
    
    override init() {
        self.xmppStream = XMPPStream()
        self.xmppStream.hostName = hostName
        self.xmppStream.hostPort = hostPort
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        
        super.init()
        
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
    }
    
    func setupUser(userId: String, password: String) {
        UserDefaults.standard.setValue(userId, forKey: keyUserID)
        UserDefaults.standard.setValue(password, forKey: keyUserPass)
        do {
            try setupXmppStream()
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    func setupXmppStream() throws {
        guard let userId = UserDefaults.standard.string(forKey: keyUserID) else {
            throw XMPPControllerError.missingUserID
        }
        
        guard let userJID = XMPPJID(string: userId) else {
            throw XMPPControllerError.wrongUserJID
        }

        self.xmppStream.myJID = userJID
    }
	
	func connect() {
        if !xmppStream.isDisconnected {
			return
		}
        
        do {
            try xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
        } catch {
            print("Error: \(error)")
        }
	}
    
    func disconect() {
        xmppStream.disconnect()
    }
    
    func joinRoom(with jidString: String) {
        guard let roomJID = XMPPJID(string: "\(jidString)@\(mucSubdomain).\(domain)") else {
            return
        }
        
        //  Sebaiknya di simpan dalam database/core data maybe??
        guard let roomStorage = XMPPRoomMemoryStorage() else {
            return
        }
        
        xmppRoom = XMPPRoom(roomStorage: roomStorage, jid: roomJID, dispatchQueue: DispatchQueue.main)
        xmppRoom?.activate(xmppStream)
        xmppRoom?.addDelegate(self, delegateQueue: DispatchQueue.main)

        if let user = xmppStream.myJID?.user {
            xmppRoom?.join(usingNickname: user, history: nil)
        }
    }
    
    func sendDirectMessage(recipient: String, message: String) {
        let recipientJID = XMPPJID(string: recipient)
        let xmppMessage = XMPPMessage(type: "chat", to: recipientJID)
        xmppMessage.addBody(message)
        self.xmppStream.send(xmppMessage)
    }
    
    func sendRoomMessage(message: String) {
        xmppRoom?.sendMessage(withBody: message)
    }
    
    func sendImage(image: UIImage, room: XMPPRoom) {
        // To do
    }
}

extension XMPPManager: XMPPStreamDelegate {
	
    func xmppStreamDidConnect(_ stream: XMPPStream) {
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
	
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
		self.xmppStream.send(XMPPPresence())
		print("Stream: Authenticated")
        joinRoom(with: "chat")
	}
	
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
		print("Stream: Fail to Authenticate")
	}
}

extension XMPPManager: XMPPRoomDelegate {
    public func xmppRoomDidCreate(_ sender: XMPPRoom) {
        print("xmppRoomDidCreate")
        sender.fetchConfigurationForm()
    }

    public func xmppRoomDidJoin(_ sender: XMPPRoom) {
        print("xmppRoomDidJoin")
    }

    public func xmppRoom(_ sender: XMPPRoom, didFetchConfigurationForm configForm: DDXMLElement) {
        print("didFetchConfigurationForm")
        let newForm = configForm.copy() as! DDXMLElement

        for field in newForm.elements(forName: "field") {
            if let _var = field.attributeStringValue(forName: "var") {
                switch _var {
                case "muc#roomconfig_persistentroom":
                    field.remove(forName: "value")
                    field.addChild(DDXMLElement(name: "value", numberValue: 1))

                case "muc#roomconfig_membersonly":
                    field.remove(forName: "value")
                    field.addChild(DDXMLElement(name: "value", numberValue: 1))

                default:
                    break
                }
            }
        }

        sender.configureRoom(usingOptions: newForm)
    }

    public func xmppRoom(_ sender: XMPPRoom, didConfigure iqResult: XMPPIQ) {
        print("didConfigure")
    }
    
    func xmppRoom(_ sender: XMPPRoom, didReceive message: XMPPMessage, fromOccupant occupantJID: XMPPJID) {
        let roomMessage = ConversaMessage()
        roomMessage.room = sender
        roomMessage.message = message
        roomMessage.from = occupantJID
        
        messageDelegate?.messageReceived(message: roomMessage)
    }
}

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
    var roomJid: XMPPJID!
    var messageDelegate: MessageDelegate?
    
    lazy var chatViewController: ConversaChatController = {
        return ConversaChatController(nibName: "ConversaChatController", bundle: nil)
    }()
    
    override init() {
        self.xmppStream = XMPPStream()
        self.xmppStream.hostName = Configs.hostName
        self.xmppStream.hostPort = Configs.hostPort
        self.xmppStream.startTLSPolicy = .required
        
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
        
        guard let userJID = XMPPJID(user: userId, domain: Configs.domain, resource: nil) else {
            throw XMPPControllerError.wrongUserJID
        }

        self.xmppStream.myJID = userJID
    }
	
	func connect() {
        if !xmppStream.isDisconnected {
			return
		}
        
        do {
            let deliveryReceipt = XMPPMessageDeliveryReceipts(dispatchQueue: .main)
            deliveryReceipt.autoSendMessageDeliveryReceipts = true
            deliveryReceipt.autoSendMessageDeliveryRequests = true
            deliveryReceipt.activate(xmppStream)
            
            try xmppStream.connect(withTimeout: 20000)
        } catch {
            print("Error: \(error)")
        }
	}
    
    func disconect() {
        xmppStream.disconnect()
    }
    
    func joinRoom(with jidString: String) {
        guard let jid = XMPPJID(string: "\(jidString)@\(Configs.mucSubdomain).\(Configs.domain)") else {
            return
        }
        
        roomJid = jid
        
        //  Sebaiknya di simpan dalam database/core data maybe??
        guard let roomStorage = XMPPRoomMemoryStorage() else {
            return
        }
        
        xmppRoom = XMPPRoom(roomStorage: roomStorage, jid: roomJid, dispatchQueue: DispatchQueue.main)
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
        let msgUid = xmppStream.generateUUID
        let xmppMessage = XMPPMessage(type: "groupchat", to: roomJid, elementID: msgUid)
        xmppMessage.addBody(message)
        
        xmppRoom?.send(xmppMessage)
    }
    
    func sendImageToRoom(image: UIImage, room: XMPPRoom) {
        // To do
    }
    
    func sendImageToUser(image: UIImage, user: String) {
        // To do
    }
    
    func sendVoiceToRoom(data: Data, room: XMPPRoom) {
        // To do
    }
    
    func sendVoiceToUser(data: Data, room: String) {
        // To do
    }
}

extension XMPPManager: XMPPStreamDelegate {
    
    func xmppStreamWillConnect(_ sender: XMPPStream) {
        print("Stream: Will Conect")
    }
	
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
    
    func xmppStreamDidSecure(_ sender: XMPPStream) {
        print("Stream: Did Secured")
    }
	
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
		self.xmppStream.send(XMPPPresence())
		print("Stream: Authenticated")
        joinRoom(with: "tisa")
	}
	
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
		print("Stream: Fail to Authenticate")
	}
    
    func xmppStream(_ sender: XMPPStream, willSecureWithSettings settings: NSMutableDictionary) {
        print("Stream: WillSecure With Settings")
        settings.setValue("YES", forKey: GCDAsyncSocketManuallyEvaluateTrust)
    }
    
    func xmppStream(_ sender: XMPPStream, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        print("Stream: Did received trust")
        print(trust)
        completionHandler(true)
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

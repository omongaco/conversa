//
//  RoomMesssage.swift
//  ConversaApp
//
//  Created by Ansyar Hafid on 12/09/21.
//  Copyright © 2021 Erlang Solutions. All rights reserved.
//

import Foundation
import XMPPFramework

class ConversaMessage {
    var room: XMPPRoom?
    var message: XMPPMessage?
    var from: XMPPJID?
}

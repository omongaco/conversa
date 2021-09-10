//
//  Enums.swift
//  ConversaApp
//
//  Created by Ansyar Hafid on 10/09/21.
//  Copyright © 2021 Erlang Solutions. All rights reserved.
//

import Foundation

enum XMPPControllerError: Error {
    case wrongUserJID
    case missingUserID
    case missingUserPass
    case missingUserToken
}

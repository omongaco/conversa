//
//  Configs.swift
//  ConversaApp
//
//  Created by Ansyar Hafid on 16/11/21.
//  Copyright © 2021 Erlang Solutions. All rights reserved.
//

import Foundation

class Configs {
    
    static let appId: String = "IQGjZSR0mvwPMNDtpmUfllchHQN0zKFqbTEKppNrZ0Y"
    static let baseURL: String = "https://blue-bird-dev.prosa.ai/sdk"
    
    static let hostName: String = "34.101.69.15"
    static let hostPort: UInt16 = UInt16(5222)
    
    static let domain: String = "localhost"
    static let mucSubdomain: String = "conference"
    
    // Ednpoints
    static let urlGetApplication: String = baseURL + "/applications"
    static let urlGetNonce: String = baseURL + "/nonce"
    static let urlGetToken: String = baseURL + "/dummy-token"
    static let urlAuthorize: String = baseURL + "/auth"
}

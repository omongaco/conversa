//
//  NetworkResponse.swift
//  ConversaApp
//
//  Created by Ansyar Hafid on 15/09/21.
//  Copyright © 2021 Erlang Solutions. All rights reserved.
//

import Foundation

class ConversaAPI {
    static let shared = ConversaAPI()
    
    private init(){}
    
    func getApplication(appId: String, completion: @escaping(_ data: Data?, _ error: Error?) -> Void) {
        guard let url = URL(string: Configs.urlGetApplication) else {
            completion(nil, NSError(domain: "", code: 401, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if error != nil {
                completion(nil, error)
            } else {
                completion(data, nil)
            }
        }
        .resume()
    }
    
    func getNonce(userId: String, completion: @escaping(_ nonce: String?, _ error: Error?) -> Void) {
        guard let url = URL(string: Configs.urlGetNonce) else {
            completion(nil, NSError(domain: "", code: 401, userInfo: nil))
            return
        }
        
        let params = ["userid": userId, "application_id": Configs.appId]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch {
            print(error)
            completion(nil, error)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, NSError(domain: "", code: 401, userInfo: nil))
                return
            }
            
            let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJson = jsonResponse as? [String: Any] {
                let nonce = responseJson["nonce"] as? String
                completion(nonce, nil)
            }
        }
        .resume()
    }
    
    func getToken(userId: String, completion: @escaping(_ token: String?, _ error: Error?) -> Void) {
        guard let url = URL(string: Configs.urlGetToken) else {
            completion(nil, NSError(domain: "", code: 401, userInfo: nil))
            return
        }
        
        let params = ["userid": userId, "application_id": Configs.appId]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch {
            print(error)
            completion(nil, error)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil, NSError(domain: "", code: 401, userInfo: nil))
                return
            }
            
            let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: [])
            print(jsonResponse)
            if let responseJson = jsonResponse as? [String: Any] {
                let token = responseJson["token"] as? String
                completion(token, nil)
            }
        }
        .resume()
    }
}

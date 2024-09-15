//
//  WalletViewModel.swift
//  SwiftFramework
//
//  Created by Ashok on 05/09/24.
//

import Foundation
import Alamofire
class WalletViewModel : NSObject{
    
    static let sharedInstance: WalletViewModel = {
        let instance = WalletViewModel()
        return instance
    }()
    func walletBalanceCheck(clientId: Int, userId: Int, completion: @escaping (_ response: walletBalance?, _ success: Bool) -> Void) {
            var clientIds = 0
            if clientId == 0 {
                clientIds = 1
            } else {
                clientIds = clientId
            }
            
            let urlString = "\(apiBaseUrl.baseURL)api/Wallet_Sdk/GetWallet?userId=\(userId)&clientId=\(clientIds)"
            guard let url = URL(string: urlString) else {
                print("Invalid URL.")
                completion(nil, false)
                return
            }
            
            print("URLData=====>", urlString)
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Network Error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(nil, false)
                    }
                    return
                }
                
                guard let data = data else {
                    print("No data received.")
                    DispatchQueue.main.async {
                        completion(nil, false)
                    }
                    return
                }
                
                do {
                    let json = try JSONDecoder().decode(walletBalance.self, from: data)
                    DispatchQueue.main.async {
                        completion(json, true)
                    }
                } catch let decodingError {
                    print("Decoding Error: \(decodingError.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(nil, false)
                    }
                }
            }
            
            // Start the task
            task.resume()
        }
//    func walletBalanceCheck(clientId: Int,userId: Int,completion: @escaping (_ response: walletBalance?, _ success: Bool) -> Void){
//        var clientIds = 0
//        if clientId == 0{
//            clientIds = 1
//        }
//        else{
//            clientIds = clientId
//        }
//        let url = "\(apiBaseUrl.baseURL)api/Wallet_Sdk/GetWallet?userId=\(userId)&clientId=\(clientIds)"
//        print("URLData=====>",url)
//        AF.request(url, method: .get)
//            .responseData{ (response) in
//                switch response.result {
//                case .success(let data):
//                    do {
//                        let json = try JSONDecoder().decode(walletBalance.self, from: data)
//                        completion(json, true)
//                    } catch {
//                        completion(nil, false)
//                    }
//                case .failure:
//                    completion(nil,false)
//                    
//                }
//            }
//    }
    func walletPaymentMethod(clientName: String, clientId: Int, userId: Int, userName: String, creditAmount: Double, debitAmount: Double, purpose: String, walletBool: Bool, completion: @escaping (_ response: addWalletAmount?, _ success: Bool) -> Void) {
        
        let url = URL(string: "\(apiBaseUrl.baseURL)api/Wallet_Sdk/AddWallet")!
        
        var parametersValue: [String: Any] = [:]
        
        if walletBool {
            parametersValue = [
                "clientName": clientName,
                "clientId": clientId,
                "userId": userId,
                "userName": userName,
                "creditAmount": creditAmount,
                "purpose": purpose
            ]
        } else {
            parametersValue = [
                "clientName": clientName,
                "clientId": clientId,
                "userId": userId,
                "userName": userName,
                "debitAmount": debitAmount,
                "purpose": purpose
            ]
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parametersValue, options: [])
            request.httpBody = jsonData
        } catch {
            completion(nil, false)
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let data = data else {
                DispatchQueue.main.async {
                    completion(nil, false)
                }
                return
            }
            do {
                let json = try JSONDecoder().decode(SwiftFramework.addWalletAmount.self, from: data)
                DispatchQueue.main.async {
                    completion(json, true)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, false)
                }
            }
        }
        task.resume()
    }

//    func walletPaymentMethod(clientName: String,clientId: Int,userId: Int,userName: String,creditAmount:Double,debitAmount: Double,purpose: String,walletBool: Bool,completion: @escaping (_ response: addWalletAmount?, _ success: Bool) -> Void){
//        let url = "\(apiBaseUrl.baseURL)api/Wallet_Sdk/AddWallet"
//        var parametersValue: [String : Any] = [:]
//        if walletBool{
//            parametersValue = [
//                "clientName" : clientName,
//                "clientId" : clientId,
//                "userId" : userId,
//                "userName" : userName,
//                "creditAmount" : creditAmount,
//                "purpose" : purpose
//            ]
//        }
//        else {
//            parametersValue = [
//                "clientName" : clientName,
//                "clientId" : clientId,
//                "userId" : userId,
//                "userName" : userName,
//                "debitAmount" : debitAmount,
//                "purpose" : purpose
//            ]
//        }
//        print("parametersValueURL",url)
//        print("parametersValue=====>",parametersValue)
//        AF.request(url, method: .post, parameters: parametersValue, encoding: JSONEncoding.default).response { response in
//            switch response.result {
//            case .success(let data):
//                if let data = data {
//                    do {
//                        let json = try JSONDecoder().decode(SwiftFramework.addWalletAmount.self, from: data)
//                        completion(json, true)
//                    } catch {
//                        completion(nil, false)
//                    }
//                } else {
//                    completion(nil, false)
//                }
//            case .failure(_):
//                if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
//                }
//                completion(nil, false)
//            }
//        }
//        
//    }
}

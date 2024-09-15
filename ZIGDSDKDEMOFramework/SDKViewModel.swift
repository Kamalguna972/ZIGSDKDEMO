//
//  SDKViewModel.swift
//  SwiftFramework
//
//  Created by apple on 29/03/24.
//

import Foundation
import Alamofire
class SDKViewModel : NSObject{
    
    static let sharedInstance: SDKViewModel = {
        let instance = SDKViewModel()
        return instance
    }()
    func configApi(authKey: String, completion: @escaping (_ response: configData?, _ success: Bool) -> Void) {
        let urlString = "\(apiBaseUrl.baseURL)api/Auth"
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            completion(nil, false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: String] = ["authToken": authKey]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch let error {
            print("Error serializing JSON: \(error.localizedDescription)")
            completion(nil, false)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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

            // Attempt to decode the response data
            do {
                let json = try JSONDecoder().decode(configData.self, from: data)
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
//    func configApi(authKey: String, completion: @escaping (_ response: configData?, _ success: Bool) -> Void) {
//        let url = "\(apiBaseUrl.baseURL)api/Auth"
//        let parametersValue: Parameters = [
//            "authToken": authKey
//        ]
//        
//        AF.request(url, method: .post, parameters: parametersValue, encoding: JSONEncoding.default).response { response in
//            switch response.result {
//            case .success(let data):
//                if let data = data {
//                    do {
//                        let json = try JSONDecoder().decode(configData.self, from: data)
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
//    }
    
    
    func limitchange(count: Int, userid: Int,typeValidate : String,ticketID: String,ValidationMode: Bool,BatteryHealth: String,MobileModel: String,TypeMobile: String,ConfigAPITime: Int,ValidationDistance: Int,ibeaconStatus: String,ConfigForegroundFeet: String,TimeTaken: Int, completion: @escaping (_ response: validationLimit?, _ success: Bool) -> Void) {
        
        let url = "\(apiBaseUrl.baseURL)api/validation"
        let parametersValue: Parameters = [
            "User_id": userid,
            "Validation_count": count,
            "ValidationType" : typeValidate,
            "TicketID" : ticketID,
            "ValidationMode": ValidationMode,
            "BatteryHealth" : BatteryHealth,
            "MobileModel" : MobileModel,
            "TypeMobile" : TypeMobile,
            "ConfigAPITime" : ConfigAPITime,
            "ValidationDistance" : ValidationDistance,
            "ibeaconStatus" : ibeaconStatus,
            "ConfigForegroundFeet" : ConfigForegroundFeet,
            "TimeTaken" : TimeTaken
        ]
        print("parametersValue====>",parametersValue)
        print("parametersValueApi=====>",url)
        AF.request(url, method: .post, parameters: parametersValue, encoding: JSONEncoding.default).response { response in
            switch response.result {
            case .success(let data):
                if let data = data {
                    do {
                        let json = try JSONDecoder().decode(validationLimit.self, from: data)
                        completion(json, true)
                    } catch {
                        completion(nil, false)
                    }
                } else {
                    completion(nil, false)
                }
            case .failure(_):
                if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                }
                completion(nil, false)
            }
        }
    }
}

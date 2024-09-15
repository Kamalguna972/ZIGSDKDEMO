//
//  ApiList.swift
//  SwiftFramework
//
//  Created by apple on 29/03/24.
//

import Foundation
import Alamofire
class Api: NSObject {
    
    
    static let sharedInstance: Api = {
        let instance = Api()
        return instance
    }()
    func postMethod(url:String,params:[String:Any],headers:HTTPHeaders,completion:@escaping(_ response:Data?,_ success:Bool)-> Void){
        
        AF.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).validate(statusCode: 200 ..< 600).responseData { response in
            
            switch response.result{
                
            case .success:
                completion(response.data,true)
                
            case .failure:
                completion(nil,false)
                
            }
        }
    }
    func TicketLog(ticketID:String,Name:String,typeValidation:String,ibeaconStatus:String,sdkVersion:String)
    {
        let url1 =  "https://docs.google.com/forms/u/1/d/e/1FAIpQLSfJ3uVTV87NIOFggqYIZH-o-bQ_5Xr0D7geEtv8kYfgBpYL4g/formResponse"
        let parameters1: Parameters = [
            "entry.1929799608": "\(ticketID)",
            "entry.1947291673": "\(Name)",
            "entry.1992346399": "\(typeValidation)",
            "entry.171888070": "\(ibeaconStatus)",
            "entry.1862799069": "\(sdkVersion)",
        ]
        
        AF.request(url1, method: .post, parameters:parameters1 )
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("success")
                case .failure(let error):
                    
                    print(error)
                    
                }
            }
    }
    func MqttLog(Macddress:String,MQTTMessage:String,SuccessFailure:String,sdkVersion:String)
    {
        let url1 =  "https://docs.google.com/forms/u/0/d/e/1FAIpQLSc1CKw4o3rlqFIGBVJ1--IpCUWE7siI1ZHLtzOjzvUMIhM1kQ/formResponse"
        let parameters1: Parameters = [
            "entry.1896005212": "\(Macddress)",
            "entry.1031379999": "\(MQTTMessage)",
            "entry.1716540237": "\(SuccessFailure)",
            "entry.1762653410": "\(sdkVersion)",
        ]
        AF.request(url1, method: .post, parameters:parameters1 )
            .responseJSON { response in
                switch response.result {
                case .success:
                    print("success")
                case .failure(let error):
                    
                    print(error)
                    
                }
            }
    }
}

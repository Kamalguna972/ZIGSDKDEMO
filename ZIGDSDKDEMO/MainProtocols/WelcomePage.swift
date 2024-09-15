// CustomDialogBox.swift

import UIKit

 protocol PresenterDelegate {
    func showAlert(title : String)
    func showAlert(title: String, message: String,buttonName : String, completion: @escaping (Bool) -> Void)
}
protocol OnboardingDelegate {
    func startOnboarding(title: String, subtitle: String, buttonTitle: String, buttonTitle1: String,imgUrl : String,backgroundColors : String,textColor: String, completion: @escaping (Bool, String?) -> Void)
}
public protocol StopRequestDelegate {
    func StopRequest(title: String, subtitle: String, backroundColor: String, message: String,imgURL : String,titleTextColor: String,subtitleTextColor: String, completion: @escaping (Bool, String?) -> Void)
}
public protocol SosRequestDelegate {
    func SosRequest(title: String, subtitle: String,backroundColor: String,textColor : String,message : String,imgURL : String, completion: @escaping (Bool, String?) -> Void)
}
public protocol QRRequestDelegate {
    func QRgeneration(ticketStatus : String,ticketId : String,expiryDate : String,totalCount : String,startColorHex : String,endColorHex : String,textColorHex : String,agencyName: String)
}
public protocol needPermissionDelegate {
    func needPermisson(Title : String, subTitle : String, description : String, noteTitle : String, noteDescription : String, permissionList: [PermissionItem],completion: @escaping (Bool, String?) -> Void)
}
public protocol TicketValidationDelegate {
    func addTickets(ticketID : Int, ticketName : String, ticketCount : Int, purchasedTicket : String,expiryDate : String, ticketStatus : Int,agencyName: String ) -> Bool
    func GetTicket()-> [[String: Any]]
    func changeStatus(ticketId : Int,Status : Int) -> Bool
}

public protocol bearonRangingDelegate {
    func ZIGSDKInit(authKey : String,enableLog : Bool,completion: @escaping (Bool, String?) -> Void)
}

public protocol receiverDelegate {
    func registerForMessages(handler: @escaping ([String: Any]) -> Void)
}

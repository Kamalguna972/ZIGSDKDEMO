//
//  customdialog.swift
//  ZIGBIBOSDK
//
//  Created by apple on 15/03/24.
//



import UIKit
import RealmSwift
import CoreLocation
import AVFoundation
import CoreBluetooth
import Alamofire
internal class PresenterImpl: PresenterDelegate {
    
    func showAlert(title : String) {
        let title = title
        let alertController = UIAlertController(title: title, message: "", preferredStyle: .alert)
        let titleFont = UIFont.boldSystemFont(ofSize: 20)
        let titleAttributes = [NSAttributedString.Key.font: titleFont]
        let attributedTitle = NSMutableAttributedString(string: title, attributes: titleAttributes)
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        
        let messageFont = UIFont.systemFont(ofSize: 18)
        let messageAttributes = [NSAttributedString.Key.font: messageFont]
        let attributedMessage = NSMutableAttributedString(string: "", attributes: messageAttributes)
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        let okAction = UIAlertAction(title: "Done", style: .default, handler: nil)
        alertController.addAction(okAction)
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
    func showAlert(title: String, message: String,buttonName : String,completion: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let titleFont = UIFont.boldSystemFont(ofSize: 20)
        let titleAttributes = [NSAttributedString.Key.font: titleFont]
        let attributedTitle = NSMutableAttributedString(string: title, attributes: titleAttributes)
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        
        let messageFont = UIFont.systemFont(ofSize: 18)
        let messageAttributes = [NSAttributedString.Key.font: messageFont]
        let attributedMessage = NSMutableAttributedString(string: message, attributes: messageAttributes)
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
        }
        let stopAction = UIAlertAction(title: buttonName, style: .default) { _ in
            completion(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(stopAction)
        
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
}
class QRpresenter : UINavigationController, QRRequestDelegate{
    func QRgeneration(ticketStatus : String,ticketId : String,expiryDate : String,totalCount : String,startColorHex : String,endColorHex : String,textColorHex : String,agencyName: String){
        QRViewController.ticketStatus = ticketStatus
        QRViewController.ticketId = ticketId
        QRViewController.ticketExpiry = expiryDate
        QRViewController.startColor = startColorHex
        QRViewController.endColor = endColorHex
        QRViewController.textColor = textColorHex
        QRViewController.agencyName = agencyName
        let storyboard = UIStoryboard(name: "QRGenerator", bundle: Bundle(for: QRpresenter.self))
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "QRViewController") as! QRViewController
        if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
            loginViewController.modalPresentationStyle = .fullScreen
            rootViewController.present(loginViewController, animated: true, completion: nil)
        }
    }
}
class OnboardingPresenterImpl: OnboardingViewController, OnboardingDelegate {
    
    func startOnboarding(title: String, subtitle: String, buttonTitle: String, buttonTitle1: String,imgUrl : String,backgroundColors : String,textColor: String, completion: @escaping (Bool, String?) -> Void) {
        OnboardingViewController.title = title
        OnboardingViewController.subtitle = subtitle
        OnboardingViewController.sendButtonTitle = buttonTitle
        OnboardingViewController.cancleButtonTitle = buttonTitle1
        OnboardingViewController.imgUrl = imgUrl
        OnboardingViewController.backgroundColor = backgroundColors
        OnboardingViewController.textColor = textColor
        let storyboard = UIStoryboard(name: "OnboardingViewController", bundle: Bundle(for: OnboardingPresenterImpl.self))
        let onboardingViewController = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
        onboardingViewController.completionHandler = { success, message in
            completion(success, message)
        }
        onboardingViewController.cancelButtonAction = {  success, message in
            completion(success, message)
        }
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            completion(false, "Failed to present onboarding")
            return
        }
        onboardingViewController.modalPresentationStyle = .fullScreen
        rootViewController.present(onboardingViewController, animated: true, completion: nil)
    }
}
class StopRequestpresenter : StopViewController,StopRequestDelegate {
    var titleName = ""
    var subTitleName = ""
    var buttonName = ""
    func StopRequest(title: String, subtitle: String, backroundColor: String, message: String,imgURL : String,titleTextColor: String,subtitleTextColor: String, completion: @escaping (Bool, String?) -> Void) {
        StopViewController.boolCheck = ""
        StopViewController.boolCheck = "STOP"
        StopViewController.title = title
        StopViewController.subtitle = subtitle
        StopViewController.mainImage = "sos_images"
        StopViewController.backroundColor = backroundColor
        StopViewController.beaconMessage = message
        StopViewController.imgUrl = imgURL
        StopViewController.titleTextColor = titleTextColor
        StopViewController.subtitleTitleColor = subtitleTextColor
        if BeavonRanging.userLimitBool{
            if BeavonRanging.beaconBool{
                if StopViewController.beaconMessage == "STOP"{
                    titleName = "Stop Request"
                    subTitleName = "Click to request to stop at the upcomming bus stop"
                    buttonName = "STOP"
                }
                else if StopViewController.beaconMessage == "SOS"{
                    titleName = "SOS Request"
                    subTitleName = "Click to request the driver to SOS"
                    buttonName = "SOS"
                }
                
                PresenterImpl().showAlert(title: titleName, message: subTitleName,buttonName: buttonName) { success in
                    if success{
                        BeavonRanging.mqttValidationStart = 0
                        BeavonRanging.mqttValidationEnd = 0
                        BeavonRanging.mqttValidationStart = Date().inMiliSeconds()
                        let storyboard = UIStoryboard(name: "stopFeature", bundle: Bundle(for: QRpresenter.self))
                        let stopViewConroller = storyboard.instantiateViewController(withIdentifier: "StopViewController") as! StopViewController
                        stopViewConroller.successHandler = { success, message in
                            completion(success, message)
                        }
                        stopViewConroller.failureHandler = {  success, message in
                            completion(success, message)
                        }
                        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
                            completion(false, "Failed to present onboarding")
                            return
                        }
                        stopViewConroller.modalPresentationStyle = .fullScreen
                        rootViewController.present(stopViewConroller, animated: true, completion: nil)
                    }
                }
            }
            else{
                completion(false, "No device was found")
                PresenterImpl().showAlert(title: "No device was found")
            }
        }
        else{
            PresenterImpl().showAlert(title: "Your limit has been exceeded. Please contact the admin")
        }
    }
}
class sosRequest : SosRequestDelegate {
    func SosRequest(title: String, subtitle: String, backroundColor: String, textColor: String, message: String,imgURL : String, completion: @escaping (Bool, String?) -> Void){
        SOSViewController.boolCheck = ""
        SOSViewController.boolCheck = "SOS"
        SOSViewController.title = title
        SOSViewController.subtitle = subtitle
        SOSViewController.mainImage = "sos_images"
        SOSViewController.backroundColor = backroundColor
        SOSViewController.textColor = textColor
        SOSViewController.beaconMessage = message
        SOSViewController.imageUrl = imgURL
        
        if BeavonRanging.beaconBool{
            PresenterImpl().showAlert(title: "SOS Request", message: "Click to request the driver to SOS",buttonName: "SOS") { success in
                if success{
                    let storyboard = UIStoryboard(name: "SOS", bundle: Bundle(for: sosRequest.self))
                    let sosViewController = storyboard.instantiateViewController(withIdentifier: "SOSViewController") as! SOSViewController
                    
                    
                    sosViewController.successHandler = { success, message in
                        completion(success, message)
                    }
                    
                    sosViewController.failureHandler = {  success, message in
                        completion(success, message)
                    }
                    guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
                        completion(false, "Failed to present onboarding") // Failed to present, return false
                        return
                    }
                    sosViewController.modalPresentationStyle = .fullScreen
                    rootViewController.present(sosViewController, animated: true, completion: nil)
                }
            }
        }
        else{
            completion(false, "Beacon not found")
            PresenterImpl().showAlert(title: "No device found")
        }
    }
}
class NeedPermisson: NSObject, needPermissionDelegate, CBCentralManagerDelegate {
    var blutoothBool = true
    
    var manager : CBCentralManager!
    
     override init() {
        super.init()
        manager = CBCentralManager()
        manager.delegate = self
    }
    var notificationBool = false
    func needPermisson(Title: String = "", subTitle: String = "", description: String = "", noteTitle: String = "", noteDescription : String = "",permissionList: [PermissionItem] = [], completion: @escaping (Bool, String?) -> Void) {
        let emptyList = [PermissionItem(description: "Please set location access to 'Allow all the time' in order to gain entry to the venue", keywordHighlight: "Allow all the time", permissionType: .location, title: "Location", image: "location.fill.viewfinder"),PermissionItem(description: "Allow Bluetooth permission in order to complete your purchase", keywordHighlight: "Bluetooth permission", permissionType: .bluetooth, title: "Bluetooth", image: "location.fill.viewfinder"),PermissionItem(description: "Allow Notification Permission", keywordHighlight: "Notification Permission", permissionType: .notification, title: "Notification", image: "location.fill.viewfinder"),PermissionItem(description: "Allow camera permission for capturing moments", keywordHighlight: "camera permission", permissionType: .camera, title: "Camera", image: "location.fill.viewfinder")]
        checkNotificationAuthorization { success in
            self.notificationBool = success
        }
        NeedPermissionViewController.notificationList.removeAll()
        NeedPermissionViewController.titleValue = Title
        NeedPermissionViewController.subTitleValue = subTitle
        NeedPermissionViewController.descriptionValue = description
        let locationBool = checkLocationServices()
        let cameraBool = checkCameraAuthorization()
        if permissionList.count > 0 {
            for list in permissionList{
                NeedPermissionViewController.notificationList.append(list)
            }
        }
        else{
            for list in emptyList{
                NeedPermissionViewController.notificationList.append(list)
            }
        }
        if locationBool == false && notificationBool == false && cameraBool == false && blutoothBool == false {
            completion(true,"All Permission Granded")
        }
       if locationBool == false || notificationBool == false || cameraBool == false || blutoothBool == false {
            let storyboard = UIStoryboard(name: "NeedPermission", bundle: Bundle(for: NeedPermisson.self))
            let needPermissionController = storyboard.instantiateViewController(withIdentifier: "NeedPermissionViewController") as! NeedPermissionViewController
            
            needPermissionController.successHandler = { success, message in
                completion(success, message)
            }
            
            needPermissionController.failureHandler = { success, message in
                completion(success, message)
            }
            guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
                completion(false, "Failed to present onboarding") // Failed to present, return false
                return
            }
            
            if let navigationController = rootViewController as? UINavigationController {
                navigationController.modalPresentationStyle = .fullScreen
            } else {
                rootViewController.modalPresentationStyle = .fullScreen
            }
            rootViewController.present(needPermissionController, animated: true, completion: nil)
        }
        else
        {
            completion(true, "All Permission Granded")
        }
    }
    func checkLocationServices()-> Bool {
        var authoried = false
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                authoried = false
                NeedPermissionViewController.locationStatus = false
            case .restricted, .denied:
                authoried = false
                NeedPermissionViewController.locationStatus = false
            case .authorizedAlways:
                authoried = true
                NeedPermissionViewController.locationStatus = true
            case.authorizedWhenInUse:
                authoried = false
                NeedPermissionViewController.locationStatus = false
            @unknown default:
                break
            }
        } else {
            authoried = false
        }
        return authoried
    }
    func checkNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            var authorized = false
            switch settings.authorizationStatus {
            case .notDetermined:
                NeedPermissionViewController.notificationStatus = false
            case .denied:
                NeedPermissionViewController.notificationStatus = false
            case .authorized:
                authorized = true
                NeedPermissionViewController.notificationStatus = true
            case .ephemeral:
                NeedPermissionViewController.notificationStatus = false
            @unknown default:
                break
            }
            completion(authorized)
        }
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            blutoothBool = true
            NeedPermissionViewController.blutoothStatus = true
        case .poweredOff:
            blutoothBool = false
            NeedPermissionViewController.blutoothStatus = false
        case .resetting:
            blutoothBool = false
            NeedPermissionViewController.blutoothStatus = false
        case .unauthorized:
            blutoothBool = false
            NeedPermissionViewController.blutoothStatus = false
        case .unsupported:
            blutoothBool = false
            NeedPermissionViewController.blutoothStatus = false
        case .unknown:
            blutoothBool = false
            NeedPermissionViewController.blutoothStatus = false
        default:
            blutoothBool = false
            NeedPermissionViewController.blutoothStatus = false
        }
    }
    func checkCameraAuthorization() -> Bool{
        var authoried = false
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .notDetermined:
            authoried = false
            NeedPermissionViewController.cameraStatus = false
        case .restricted, .denied:
            authoried = false
            NeedPermissionViewController.cameraStatus = false
        case .authorized:
            authoried = true
            NeedPermissionViewController.cameraStatus = true
        @unknown default:
            break
        }
        return authoried
    }
}
class TicketMethods : TicketValidationDelegate{
    var ticketArray: [[String: Any]] = []
    public   func addTickets(ticketID: Int, ticketName: String, ticketCount: Int, purchasedTicket: String, expiryDate: String, ticketStatus: Int,agencyName: String) -> Bool {
        do {
            let realm = try Realm()
            let newTask = TicketDatas()
            newTask.ticketID = ticketID
            newTask.ticketName = ticketName
            newTask.ticketCount = ticketCount
            newTask.purchasedDate = purchasedTicket
            newTask.expiryDate = expiryDate
            newTask.ticketStatus = ticketStatus
            newTask.agencyName = agencyName
            try realm.write {
                realm.add(newTask)
            }
        } catch {
            return false
        }
        
        return true
    }
    func GetTicket()-> [[String: Any]]{
        do {
            let realm = try Realm()
            let tasks = realm.objects(TicketDatas.self)
            
            ticketArray.removeAll()
            for task in tasks {
                ticketArray.append([
                    "ticketId": task.ticketID,
                    "ticketName": task.ticketName,
                    "ticketCount": task.ticketCount,
                    "purchasedTicket": task.purchasedDate,
                    "expiryDate": task.expiryDate,
                    "ticketStatus": task.ticketStatus,
                    "agencyName": task.agencyName
                ])
            }
            ticketArray.reverse()
        } catch {
            return []
        }
        return ticketArray
    }
    func changeStatus(ticketId: Int, Status: Int) -> Bool {
        var check: Bool = false
        do {
            let realm = try Realm()
            
            if let taskToUpdate = realm.objects(TicketDatas.self).filter("ticketID == %@", ticketId).first {
                try realm.beginWrite()
                taskToUpdate.ticketStatus = Status
                try realm.commitWrite(withoutNotifying: [])
                
            
                check = true
            }
        } catch {
            check = false
        }
        return check
    }
}
extension UIFont {
    static func customFont(name: String, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: name, size: size) else {
            fatalError("Font '\(name)' not found")
        }
        return font
    }
}


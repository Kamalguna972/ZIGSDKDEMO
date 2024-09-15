//
//  StopViewController.swift
//  ZIGBIBOSDK
//
//  Created by apple on 18/03/24.
//

import UIKit
import CoreLocation
import UserNotifications
import AVFAudio
import CocoaMQTT
struct beaconLogData{
    static var rssi = ""
    static var uuid = ""
    static var minor = ""
    static var major = ""
    static var proximity = ""
    static var range = ""
    static var bleValue = ""
    static var locationValue = ""
    static var macaddress = ""
    static var latLong = ""
    static var validationFeetDistance = 0
    static var beaconValidationFeet = ""
    static var bg_location_permission = ""
}

class StopViewController: UIViewController,CLLocationManagerDelegate,UNUserNotificationCenterDelegate,AVSpeechSynthesizerDelegate {
    var successHandler: ((Bool, String?) -> Void)?
    var failureHandler: ((Bool, String?) -> Void)?
    @IBOutlet weak var Title_name: UILabel!
    @IBOutlet weak var Current_location: UILabel!
    @IBOutlet weak var Current_location_img: UIImageView!
    @IBOutlet weak var SubTitle_name: UILabel!
    @IBOutlet weak var Stop_img: UIImageView!
    
    static var title = ""
    static var subtitle = ""
    static var mainImage = ""
    static var backroundColor = ""
    static var beaconMessage = ""
    static var textColor = ""
    static var beaconfound : Bool = false
    static var boolCheck = ""
    static var messageCheck = 0
    static var imgUrl = ""
    static var titleTextColor = ""
    static var subtitleTitleColor = ""
    static var textToVoiceMessage = ""
    
    var startColorHex = "#E00F12" // Green
    var endColorHex = "#ed4c4e"
    var blePermissionValue = "false"
    var locationPermissionValue = "false"
    let geocoder = CLGeocoder()
    let requestIdentifier = "SampleRequest"
    var locationManager = CLLocationManager()
    var synth = AVSpeechSynthesizer()
    let receiver = receiverNotification()
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        SetupUI()
        if BeavonRanging.beaconCheck{
            SoSandStopFeature()
        }
        else{
            dismissViewController()
            failureHandler?(false,"Stop request not Send to beacon")
        }
    }
    
    func SetupUI()
    {
        StopViewController.title = StopViewController.title.isEmpty ? "STOP Request" : StopViewController.title
        StopViewController.subtitle = StopViewController.subtitle.isEmpty ? "Your Stop request has been delivered to the driver" : StopViewController.subtitle
        StopViewController.titleTextColor = StopViewController.titleTextColor.isEmpty ? "#FFFFFF" : StopViewController.titleTextColor
        StopViewController.subtitleTitleColor = StopViewController.subtitleTitleColor.isEmpty ? "#FFFFFF" : StopViewController.subtitleTitleColor
        StopViewController.backroundColor = StopViewController.backroundColor.isEmpty ? "#FF0000" : StopViewController.backroundColor
        StopViewController.mainImage = "StopRequest"
        StopViewController.imgUrl = StopViewController.imgUrl.isEmpty ? "https://www.zed.digital/img/app/stop.png" : StopViewController.imgUrl
        Title_name.text = StopViewController.title
        SubTitle_name.text = StopViewController.subtitle
        Title_name.textColor = UIColor(hex: StopViewController.titleTextColor)
        SubTitle_name.textColor = UIColor(hex: StopViewController.subtitleTitleColor)
        Current_location.textColor = UIColor(hex: StopViewController.subtitleTitleColor)
        
        view.backgroundColor = UIColor(hex:StopViewController.backroundColor )
        Stop_img.backgroundColor = UIColor(hex: StopViewController.backroundColor)
        Current_location_img.backgroundColor = UIColor(hex: StopViewController.backroundColor)
        Current_location_img.tintColor = UIColor(hex:StopViewController.subtitleTitleColor)
        loadImage(from: StopViewController.imgUrl) { [weak self] image in
            guard let self = self else { return }
            if let image = image {
                self.Stop_img.image = image
            } else {
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil {
                return 
            }
            if let placemark = placemarks?.first {
                let formattedAddress = "\(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? ""), \(placemark.country ?? "")"
                self.Current_location.text = formattedAddress
                self.locationManager.stopUpdatingLocation()
            } else {
            }
        }
    }
    func SoSandStopFeature()
    {
        if isReachable(){
            let dataString = StopViewController.beaconMessage
            let message = CocoaMQTTMessage(topic: "\(beaconLogData.macaddress)/nfc", string: dataString)
            CocoaMQTTManager.shared.publish(message: message) { success, ackMessage, id in
                if success {
                    
                    BeavonRanging.mqttValidationEnd = Date().inMiliSeconds()
                    BeavonRanging.totalValidationtime = BeavonRanging.mqttValidationEnd - BeavonRanging.mqttValidationStart
                    
                    SDKViewModel.sharedInstance.limitchange(count: 1, userid: MqttValidationData.userid, typeValidate: StopViewController.beaconMessage, ticketID: " ", ValidationMode: BeavonRanging.validationMode, BatteryHealth: "\(benchMarkData.batteryPercent)", MobileModel: "\(benchMarkData.phoneModel)", TypeMobile: "iOS", ConfigAPITime: benchMarkData.cofigApiResponseTime, ValidationDistance: beaconLogData.validationFeetDistance, ibeaconStatus: "3", ConfigForegroundFeet: beaconLogData.beaconValidationFeet, TimeTaken: BeavonRanging.totalValidationtime){ response, success in
                        if success{
                            let jsonObject: [String: Any] = [
                                "TicketId" : "\(StopViewController.beaconMessage) Request",
                                "Message" : "Your \(StopViewController.beaconMessage) request has been delivered to the driver"
                            ]
                            self.receiver.senderFunction(jsonObject: jsonObject)
                            self.successHandler?(success,"Message sent successfully")
                            if StopViewController.beaconMessage == "STOP"{
                                Trigger().scheduleNotification(title: "Stop Request", body: "Your stop request has been delivered to the driver")
                                StopViewController.textToVoiceMessage = "Your stop request has been delivered to the driver"
                            }
                            else if StopViewController.beaconMessage == "SOS" {
                                Trigger().scheduleNotification(title: "SOS", body: "Your SOS request has been delivered to the driver")
                                StopViewController.textToVoiceMessage = "Your SOS request has been delivered to the driver"
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                self.dismissViewController()
                                let text = "Your stop request has been delivered to the driver succesfully."
                                let utterance = AVSpeechUtterance(string: text)
                                utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                                utterance.rate = 0.5
                                self.synth.speak(utterance)
                            }
                            if response?.Message == "OK" && response?.LimitStatus ?? false {
                            }
                            else {
                                BeavonRanging.stopRangingBeacons()
                                BeavonRanging.beaconBool = false
                                BeavonRanging.userLimitBool = false
                                BeavonRanging.timer?.invalidate()
                                BeavonRanging.timer = nil
                                PresenterImpl().showAlert(title: "Your limit has been exceeded. Please contact the admin")
                            }
                        }
                        else{
                            self.failureHandler?(success,"mqtt message delivery failed:\(ackMessage ?? "")")
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        self.dismissViewController()
                        self.failureHandler?(success,"mqtt message delivery failed:\(ackMessage ?? "")")
                    }
                }
            }
        }
        else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.dismissViewController()
                self.failureHandler?(false,"Stop request not Send to beacon..because due to network error")
            }
        }
    }
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func BackBtn(_ sender: Any) {
        dismissViewController()
    }
}



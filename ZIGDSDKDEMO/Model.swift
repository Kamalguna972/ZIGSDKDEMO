//
//  Model.swift
//  
//
//  Created by apple on 15/03/24.
//

import Foundation

struct onbordingscreen {
    var title : String?
    var msubtitle : String?
    var number : Int?
}

struct configData : Codable{
    var userName : String?
    var userId : Int?
    var SlowLaneMajor : Int?
    var FastLaneMajor : Int?
    var Tollstatus : Bool?
    var Beveragestatus : Bool?
    var WalletEnableStatus : Bool?
    var TicketValidationStatus : Bool?
    var Beveragemajor : Int?
    var beaconUuid : String?
    var MqttUrl : String?
    var mqttUserName : String?
    var mqttPassword : String?
    var mqttPortNumber : Int?
    var validationLimit : Int?
    var LimitStatus : Bool?
    var message : String?
    var threshold : Int?
    var process_noise : String?
    var measurement_noise : String?
    var formula_status : Int?
    var Clientuuid : String?
    var Scaninterval : Int?
    var Rssvalue : String?
    var BeaconRadius : Int?
    var SendOutData : Bool?
    var BibobRssi : String?
    var BibobRssi_ios : String?
    var Rssi_Ios : String?
    var ibeacon_Status : Int?
    var averageRSSIvalue : String?
    var tx_power : String?
    var distance : String?
    var powerValue : String?
    var distanceTimes : String?
    var ibeaconAndroidStatus : String?
    var ble_rssi_4 : String?
    var ble_rssi_5a : String?
    var ble_rssi_5b : String?
    var ble_rssi_5c : String?
    var screen_wake_status : Bool?
    var tollBeaconList : [tollBeaconList]
}
struct tollBeaconList : Codable{
    var name : String?
    var laneType : String?
    var major : Int?
    var minor : Int?
    var deviceID : String?
    var mqttMac : String?
    var validationFeet : Int?
    var MeasureValue : Int?
    var validationFeetiOS : Int?
    var MeasureValueiOS : Int?
    var beaconA_ID : String?
}
struct validationLimit : Codable{
    var LimitStatus : Bool?
    var Message : String?
    var BalanceLimit : Int?
}
struct MqttValidationData {
    static var mqttHostUrl: String = ""
    static var mqttPort: Int = 0
    static var userName : String = ""
    static var password : String = ""
    static var userid : Int = 0
    static var personalUserName : String = ""
    static var measurem = ""
    static var distance = ""
    static var txPower = ""
    static var uuid = ""
}

struct addWalletAmount : Codable{
    var Message : String?
    var userId : Int?
    var userName : String?
    var walletBalanceAmount : Double?
    var WalletEnableStatus : Bool?
}
struct walletBalance : Codable{
    var Message: String?
    var userId : Int?
    var userName : String?
    var walletBalanceAmount : Double?
}

//
//  BeaconRanging.swift
//  SwiftFramework
//
//  Created by apple on 29/03/24.
//

import Foundation
import CoreLocation
import RealmSwift
import Alamofire
import UserNotifications
import BackgroundTasks
import AVFoundation
import CocoaMQTT
class BeavonRanging:NSObject, bearonRangingDelegate, CLLocationManagerDelegate,AVSpeechSynthesizerDelegate {
   static var illegalCheck = 0
    var currentlat = 0.0
    var currentLong = 0.0
    var blePermissionValue = "false"
    var locationPermissionValue = "false"
    var realmTotal = 0
    var activeTicketCount = 0
    var newTicketCount = 0
    var validateTicketCount = 0
    var macAddress = "04:e9:e5:16:f6:3d"
    var validationflag = ""
    let realm = try! Realm()
    let present = TicketMethods()
    var synth = AVSpeechSynthesizer()
    static var beaconStatus = 0
    static var macAddress = ""
    static var major = 0
    static var minor = 0
    static var beaconCheck = false
    static var beaconBool = false
    static var userLimitBool = false
    static var limited = 0
    static var logEnable = true
    static var locationManager = CLLocationManager()
    private var beaconRegion: CLBeaconRegion!
    var mqttManager : CocoaMQTTManager?
    var rssiValues: [RssiData] = []
    static var timer: Timer!
    static var iBeaconList = [IBeaconToll]()
    static var validationMode = false
    static var batteryPercentage = 0
    static var fastLaneBeacon = 540
    static var slowLaneBeacon = 780
    static var mqttValidationStart = 0
    static var mqttValidationEnd = 0
    static var totalValidationtime = 0
    static var beverageMajor = 0
    let receiver = receiverNotification()
    override init() {
        super.init()
        setupLocationManager()
    }
    private func setupLocationManager() {
        BeavonRanging.locationManager.delegate = self
        BeavonRanging.locationManager.requestWhenInUseAuthorization()
        BeavonRanging.locationManager.allowsBackgroundLocationUpdates = true
        BeavonRanging.locationManager.showsBackgroundLocationIndicator = true
        BeavonRanging.locationManager.pausesLocationUpdatesAutomatically = false
    }
    internal func ZIGSDKInit(authKey : String, enableLog : Bool = false,completion: @escaping (Bool, String?) -> Void) {
        let startTime = DispatchTime.now()
        SDKViewModel.sharedInstance.configApi(authKey: authKey) { response, success in
            if success{
                let endTime = DispatchTime.now()
                let responseTimeNanos = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                let responseMilleSeconds = responseTimeNanos / 1_000_000
                let responseSeconds = Double(responseTimeNanos) / 1_000_000_000
                benchMarkData.cofigApiResponseTime = Int(responseMilleSeconds)
                sdkLog.shared.printLog(message: "ZEDSDK initialized successfully")
                if response?.message != "Invalid Token"{
                    BeavonRanging.slowLaneBeacon = response?.SlowLaneMajor ?? 0
                    BeavonRanging.fastLaneBeacon = response?.FastLaneMajor ?? 0
                    if response?.LimitStatus ?? false{
                        if response?.validationLimit ?? 0 != 0{
                            // beacon details
                            BeavonRanging.locationManager.startUpdatingLocation()
                            BeavonRanging.locationManager.showsBackgroundLocationIndicator = true
                            BeavonRanging.locationManager.allowsBackgroundLocationUpdates = true
                            BeavonRanging.locationManager.pausesLocationUpdatesAutomatically = false
                            BeavonRanging.locationManager.requestAlwaysAuthorization()
                            BeavonRanging.logEnable = enableLog
                            BeavonRanging.userLimitBool = response?.LimitStatus ?? false
                            BeavonRanging.limited = response?.validationLimit ?? 0
                            BeavonRanging.beaconStatus = response?.ibeacon_Status ?? 0
                            BeavonRanging.beverageMajor = response?.Beveragemajor ?? 0
                            
                            //Mqtt Details
                            MqttValidationData.userName = response?.mqttUserName ?? ""
                            MqttValidationData.password = response?.mqttPassword ?? ""
                            MqttValidationData.userid = response?.userId ?? 0
                            MqttValidationData.mqttHostUrl = response?.MqttUrl ?? ""
                            MqttValidationData.mqttPort = response?.mqttPortNumber ?? 0
                            MqttValidationData.personalUserName = response?.userName ?? ""
                            MqttValidationData.distance = response?.distance ?? ""
                            MqttValidationData.txPower = response?.tx_power ?? ""
                            MqttValidationData.uuid = response?.beaconUuid ?? ""
                            
                            //Features Status.
                            featureStatus.beverageValidation = response?.Beveragestatus ?? false
                            featureStatus.tollValidation = response?.Tollstatus ?? false
                            featureStatus.WalletEnableStatus = response?.WalletEnableStatus ?? false
                            featureStatus.TicketValidationStatus = response?.TicketValidationStatus ?? false
                            
                            if featureStatus.TicketValidationStatus || featureStatus.beverageValidation || featureStatus.tollValidation{
                                let tollArray = response?.tollBeaconList ?? []
                                if tollArray.count > 0 {
                                    BeavonRanging.iBeaconList.removeAll()
                                    for tollData in tollArray {
                                        BeavonRanging.iBeaconList.append(IBeaconToll(name: tollData.name ?? "", laneType: tollData.laneType ?? "", major: tollData.major ?? 0, minor: tollData.minor ?? 0, deviceID: tollData.deviceID ?? "", mqttMac: tollData.mqttMac ?? "", validationFeetiOS: Double(tollData.validationFeetiOS ?? Int(0.0)), MeasureValueiOS: tollData.MeasureValueiOS ?? 0, beaconA_ID: tollData.deviceID ?? ""))
                                    }
                                    guard CLLocationManager.isRangingAvailable() else {
                                        sdkLog.shared.printLog(message: "Beacon ranging is not available.")
                                        return
                                    }
                                    self.mqttManager = CocoaMQTTManager.shared
                                    self.startScanning()
                                    completion(success,"Your Ticket Feature has been Enabled")
                                }
                                else {
                                    completion(false,"MAC address was not found, please contact admin to add MAC address with error code 1001")
                                    sdkLog.shared.printLog(message: "MAC address was not found, please contact admin to add MAC address with error code 1001")
                                    PresenterImpl().showAlert(title: "MAC address was not found, please contact admin to add MAC address")
                                }
                            }
                            else if featureStatus.WalletEnableStatus{
                                completion(true,"Your Wallet Feature has been Enabled")
                            }
                            else{
                                completion(false,"All features are Blocked Contact Admin")
                            }
                        }
                        else{
                            BeavonRanging.userLimitBool = false
                            completion(success,"Your limit has been exceeded. Please contact the admin")
                            PresenterImpl().showAlert(title: "Your limit has been exceeded. Please contact the admin")
                        }
                    }
                    else{
                        BeavonRanging.userLimitBool = false
                        completion(success,"Your limit has been exceeded. Please contact the admin")
                        PresenterImpl().showAlert(title: "Your limit has been exceeded. Please contact the admin")
                    }
                }
                else{
                    completion(success,"Security key is invalid or unauthorized, please contact admin")
                    PresenterImpl().showAlert(title: "Security key is invalid or unauthorized, please contact admin")
                }
            }
            else{
                print("API Failed======>")
                let endTime = DispatchTime.now()
                let responseTimeNanos = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                let responseMilleSeconds = responseTimeNanos / 1_000_000
                let responseSeconds = Double(responseTimeNanos) / 1_000_000_000
                benchMarkData.cofigApiResponseTime = Int(responseMilleSeconds)
                sdkLog.shared.printLog(message: "Security key is invalid or unauthorized, please contact admin")
                completion(success,"Security key is invalid or unauthorized, please contact admin")
                PresenterImpl().showAlert(title: "Security key is invalid or unauthorized, please contact admin")
            }
        }
    }
    func startScanning(){
        let clientIdentifiler = "Validationbeacon"
        let uuid = UUID(uuidString:MqttValidationData.uuid ?? "")!
        self.beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: clientIdentifiler)
        BeavonRanging.locationManager.startRangingBeacons(in: self.beaconRegion)
    }
    public static func stopRangingBeacons() {
        let clientIdentifier = "Validationbeacon"
        guard let uuid = UUID(uuidString: MqttValidationData.uuid) else {
            print("Invalid UUID string")
            return
        }
        let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: clientIdentifier)
        BeavonRanging.locationManager.stopRangingBeacons(in: beaconRegion)
    }
    internal func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let loc = manager.location?.coordinate
        currentlat = loc?.latitude ?? 0.0
        currentLong = loc?.longitude ?? 0.0
        sdkLog.shared.printLog(message: "Scan found nearby devices")
        print("BeaconData====>",beacons)
        if beacons.count > 0{
            for beacon in beacons {
                updateDistance(beacon.proximity, locationCo: loc!, RssiValue: beacon.rssi, Meterint: beacon.accuracy, major: Int(truncating: beacon.major), Minor: Int(truncating: beacon.minor), proximityVle: beacon.proximity.rawValue, uuid: "\(beacon.uuid)")
                beaconLogData.rssi = "\(beacon.rssi)"
                beaconLogData.uuid = "\(beacon.uuid)"
                beaconLogData.minor = "\(Int(truncating: beacon.minor))"
                beaconLogData.major = "\(Int(truncating: beacon.major))"
                beaconLogData.proximity = "\(beacon.proximity.rawValue)"
                beaconLogData.range = "far"
                beaconLogData.bleValue = "\(blePermissionValue)"
                beaconLogData.locationValue = "\(locationPermissionValue)"
            }
        }
        else{
            BeavonRanging.beaconCheck = false
            BeavonRanging.beaconBool = false
            sdkLog.shared.printLog(message: "Scan failed to find nearby devices ")
        }
    }
    private func updateDistance(_ distance: CLProximity,locationCo:CLLocationCoordinate2D,RssiValue:Int,Meterint:Double,major:Int,Minor:Int,proximityVle : Int,uuid : String) {
        beaconLogData.rssi = "\(RssiValue)"
        beaconLogData.proximity = "\(proximityVle)"
        beaconLogData.bleValue = blePermissionValue
        beaconLogData.locationValue = locationPermissionValue
        if featureStatus.tollValidation {
            if RssiValue != 0 {
                let distance = calculateDistance(rssi: RssiValue, measurePower: self.findMeasureValue(minor: Minor) ?? 0, txPower: Double(MqttValidationData.txPower) ?? 0.0, configDistance: Double(MqttValidationData.distance) ?? 0.0) //=======> Calculate a Distance
                
                let beaconInfo = RssiData(rssi: RssiValue, major: major, minor: Minor, distance: distance, uuid: uuid) // =====> Stored RSSI data into one array.
                BeavonRanging.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    // var totalTicketCountForMQTT = 1
                    if !self.rssiValues.isEmpty {
                        var backup = self.rssiValues
                        self.rssiValues.removeAll()
                        self.calculateTolls(scanResultList: backup) { scanResultFinal in
                            let fastLaneData = scanResultFinal.filter { $0.lane == "FAST LANE" && $0.distance <= $0.validationFeet && $0.distance != 0.0 }
                            let shortestFastLaneData = fastLaneData.min(by: { $0.distance < $1.distance }) // find nearest beacon using distance
                            
                            let slowLaneData = scanResultFinal.filter { $0.lane != "FAST LANE" && $0.distance <= $0.validationFeet && $0.distance != 0.0 }
                            let shortestSlowLaneData = slowLaneData.min(by: { $0.distance < $1.distance }) // find nearest beacon using distance
                            
                            
                            var scanResultFinalCut: RssiDataToll? = nil
                            if let mac = shortestSlowLaneData?.mac, !mac.isEmpty {
                                scanResultFinalCut = shortestSlowLaneData
                            } else if let mac = shortestFastLaneData?.mac, !mac.isEmpty {
                                scanResultFinalCut = shortestFastLaneData
                            }
                            if scanResultFinalCut != nil {
                                beaconLogData.range = "far"
                                beaconLogData.major = "\(scanResultFinalCut?.major ?? 0)"
                                beaconLogData.minor = "\(scanResultFinalCut?.minor ?? 0)"
                                beaconLogData.uuid = "\(scanResultFinalCut?.uuid ?? "")"
                                beaconLogData.macaddress = "\(scanResultFinalCut?.mac ?? "")"
                                beaconLogData.validationFeetDistance = Int(scanResultFinalCut?.distance ?? 0.0)
                                beaconLogData.beaconValidationFeet = "\(scanResultFinalCut?.validationFeet ?? 0)"
                                self.ticketCounter()
                            }
                            backup.removeAll()
                        }
                    } else {
                        print("rssiValues is empty, nothing to process")
                    }
                }
                self.rssiValues.append(beaconInfo)
            }
            else {
                print("toll1233: no rssi")
            }
        }
        else {
            switch distance {
            case .unknown:
                BeavonRanging.beaconCheck = false
                BeavonRanging.beaconBool = false
            case .far:
                if BeavonRanging.beaconStatus == 3{
                    print("BeaconList=====>",BeavonRanging.iBeaconList)
                    for list in BeavonRanging.iBeaconList{
                        if major == 102 && Minor == list.minor{
                            print("Beverage Validation",major,Minor,BeavonRanging.beaconStatus)
                            beaconLogData.macaddress = list.mqttMac
                        }
                        else if major == list.major && Minor == list.minor{
                            
                            print("TicketValidation=====>far1=======>",major,Minor,BeavonRanging.beaconStatus)
                            beaconLogData.macaddress = list.mqttMac
                            ticketCounter()
                        }
                        else{
                            print("TicketValidation=====>far1=======>",major,Minor,BeavonRanging.beaconStatus)
                        }
                    }
                }
            case .near:
                if BeavonRanging.beaconStatus == 2 {
                    for list in BeavonRanging.iBeaconList{
                        if major == 102{
                            print("Beverage Validation",major,Minor,BeavonRanging.beaconStatus)
                            beaconLogData.macaddress = list.mqttMac
                        }
                        else if major == 100{
                            if major == list.major && Minor == list.minor{
                                print("TicketValidation=====>Near=======>",major,Minor,BeavonRanging.beaconStatus)
                                beaconLogData.macaddress = list.mqttMac
                                ticketCounter()
                            }
                        }
                    }
                }
            case .immediate:
                if BeavonRanging.beaconStatus == 1{
                    for list in BeavonRanging.iBeaconList{
                        if major == 102{
                            print("Beverage Validation",major,Minor,BeavonRanging.beaconStatus)
                            beaconLogData.macaddress = list.mqttMac
                        }
                        else if major == 100{
                            if major == list.major && Minor == list.minor{
                                print("TicketValidation=====>immediate=======>",major,Minor,BeavonRanging.beaconStatus)
                                beaconLogData.macaddress = list.mqttMac
                                ticketCounter()
                            }
                        }
                    }
                }
                break
            @unknown default:
                BeavonRanging.beaconBool = false
                BeavonRanging.beaconCheck = false
                break
            }
        }
    }
    func calculateTolls(scanResultList: [RssiData], callback: @escaping ([RssiDataToll]) -> Void) {
        do {
            var fastLaneResults = [RssiData]()
            var slowLaneResults = [RssiData]()
         //   var bevereageResults = [RssiData]()
            fastLaneResults.removeAll()
            slowLaneResults.removeAll()
            for rssiData in scanResultList {
                if rssiData.distance != 0.0 {
                    if rssiData.major == BeavonRanging.fastLaneBeacon {
                        fastLaneResults.append(rssiData)
                    } else if rssiData.major == BeavonRanging.slowLaneBeacon {
                        slowLaneResults.append(rssiData)
                    }
//                    else if rssiData.major == BeavonRanging.beverageMajor {
//                        bevereageResults.append(rssiData)
//                    }
                }
            }
            var findShortestSlowLane = findLowestAverageDistanceRssiData(rssiList: slowLaneResults)
            var findShortestFastlane = findLowestAverageDistanceRssiData(rssiList: fastLaneResults)
          //  var beverageShortestLane = findLowestAverageDistanceRssiData(rssiList: bevereageResults)
            
            if findShortestSlowLane == nil {
                findShortestSlowLane = RssiDataToll(major: 100, minor: 0, distance: 200.0, mac: "", lane: "", validationFeet: 0, uuid: "",tollBeaconID: "")
            }
            
            if findShortestFastlane == nil {
                findShortestFastlane = RssiDataToll(major: 100, minor: 0, distance: 200.0, mac: "", lane: "", validationFeet: 0, uuid: "",tollBeaconID: "")
            }
//            
//            if beverageShortestLane == nil {
//                beverageShortestLane = RssiDataToll(major: 100, minor: 0, distance: 200.0, mac: "", lane: "", validationFeet: 0, uuid: "",tollBeaconID: "")
//            }
//            
            
            let fastSlowList = [findShortestSlowLane!, findShortestFastlane!]
            callback(fastSlowList)
            
        } catch {
           
        }
    }
    
    func findLowestAverageDistanceRssiData(rssiList: [RssiData]) -> RssiDataToll? {
        let groupedByMinor = Dictionary(grouping: rssiList, by: { $0.minor })
        var averagedList = [RssiDataToll]()
        for (minor, dataList) in groupedByMinor {
            let averageDistance = dataList.reduce(0.0) { $0 + $1.distance } / Double(dataList.count)
            if let beacon = BeavonRanging.iBeaconList.first(where: { $0.minor == minor }) {
                averagedList.append(RssiDataToll(
                    major: beacon.major,
                    minor: minor,
                    distance: averageDistance,
                    mac: beacon.mqttMac,
                    lane: beacon.name,
                    validationFeet: beacon.validationFeetiOS, uuid: "",
                    tollBeaconID: beacon.beaconA_ID
                ))
            }
            else{
               
            }
        }
        return averagedList.min(by: { $0.distance < $1.distance })
    }
    
    func findMeasureValue(minor: Int) -> Int? {
        let findMeasure = BeavonRanging.iBeaconList.first { $0.minor == minor }
        return findMeasure?.MeasureValueiOS
    }
    
    func calculateDistance(rssi: Int, measurePower: Int, txPower: Double, configDistance: Double) -> Double {
        if rssi < 0 {
            let iRssi = abs(rssi)
            let iMeasurePower = abs(measurePower)
            let power = (Double(iRssi) - Double(iMeasurePower)) / (txPower * 2.0)
            let distance = pow(10.0, power) * configDistance
            return distance
        }
        else{
            return 300
        }
    }
    func ticketCounter() {
        activeTicketCount = 0
        newTicketCount = 0
        realmTotal = 0
        validateTicketCount = 0
        var isAppInBackground: Bool {
            return UIApplication.shared.applicationState == .background
        }
        print("TicketValidation=====>far3=======>",BeavonRanging.beaconStatus)
        self.startScanning()
        BeavonRanging.validationMode = isAppInBackground
        let TicketRealm = self.realm.objects(TicketDatas.self)
        let activateTicket = self.realm.objects(TicketDatas.self).filter("ticketStatus == 2")
        let validateTicket = self.realm.objects(TicketDatas.self).filter("ticketStatus == 3")
        let newTicket = self.realm.objects(TicketDatas.self).filter("ticketStatus == 1")
        activeTicketCount = activateTicket.count
        validateTicketCount = validateTicket.count
        newTicketCount = newTicket.count
        realmTotal = TicketRealm.count
        
        BeavonRanging.mqttValidationStart = 0
        BeavonRanging.mqttValidationEnd = 0
        BeavonRanging.mqttValidationStart = Date().inMiliSeconds()
        
        if activeTicketCount == 0 && validateTicketCount == 0 && newTicketCount > 0{
            validationflag = "Autovalidation"
            BeavonRanging.beaconCheck = true
            BeavonRanging.beaconBool = true
            TicketVerityAuto()
        }
        else if activeTicketCount == 0 && validateTicketCount == 0 && newTicketCount == 0 {
            if BeavonRanging.illegalCheck == 0 {
                BeavonRanging.illegalCheck += 1
                validationflag = "Illegal"
                BeavonRanging.beaconCheck = true
                BeavonRanging.beaconBool = true
                 TicketIllegal()
            }
            else{
                BeavonRanging.beaconCheck = true
                BeavonRanging.beaconBool = true
            }
        }
        else{
            validationflag = "Validate"
            print("Validation1--->")
            BeavonRanging.beaconCheck = true
            BeavonRanging.beaconBool = true
            TicketValidation()
        }
    }
    func TicketIllegal() -> String {
        if validationflag == "Illegal" {
            BeavonRanging.checkbattery()
            
            let dataString = "301001"
            let message = CocoaMQTTMessage(topic:"\(beaconLogData.macaddress)/nfc" , string: dataString)
            CocoaMQTTManager.shared.publish(message: message) { success, ackMessage, id in
                if success {
                    
                    let jsonObject: [String: Any] = [
                        "TicketId" : "Illegal",
                        "Message" : "Successfully validate a Illegal Entry"
                    ]
                    self.receiver.senderFunction(jsonObject: jsonObject)
                    
                    BeavonRanging.mqttValidationEnd = Date().inMiliSeconds()
                    BeavonRanging.totalValidationtime = BeavonRanging.mqttValidationEnd - BeavonRanging.mqttValidationStart
                    
                    SDKViewModel.sharedInstance.limitchange(count: 1, userid: MqttValidationData.userid, typeValidate: "Illegal", ticketID: " ", ValidationMode: BeavonRanging.validationMode, BatteryHealth: "\(benchMarkData.batteryPercent)", MobileModel: "\(benchMarkData.phoneModel)", TypeMobile: "iOS", ConfigAPITime: benchMarkData.cofigApiResponseTime, ValidationDistance: beaconLogData.validationFeetDistance, ibeaconStatus: "3", ConfigForegroundFeet: beaconLogData.beaconValidationFeet, TimeTaken: BeavonRanging.totalValidationtime){ response, success in
                        if success {
                            
                            Trigger().scheduleNotification(title: "Illegal Entry", body: "You do not have any active tickets, Please buy a new ticket")
                            
                            let storyboard = UIStoryboard(name: "Illegal", bundle: Bundle(for: OnboardingPresenterImpl.self))
                            let illegalViewController = storyboard.instantiateViewController(withIdentifier: "IllegalViewController") as! IllegalViewController
                            
                            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                                illegalViewController.modalPresentationStyle = .fullScreen
                                rootViewController.present(illegalViewController, animated: true, completion: nil)
                            }
                            self.startScanning()
                            let text = "You do not have any active tickets, Please buy a new ticket"
                            let utterance = AVSpeechUtterance(string: text)
                            utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                            utterance.rate = 0.5
                            self.synth.speak(utterance)
                            
                            Api.sharedInstance.TicketLog(ticketID: "", Name: "", typeValidation: "Illegal", ibeaconStatus: "\(BeavonRanging.beaconStatus)", sdkVersion: "\(ZIGSDK.sdkversion)")
                            
                            if response?.Message == "OK" && response?.LimitStatus ?? false {
                                self.startScanning()
                            }
                            else {
                                BeavonRanging.stopRangingBeacons()
                                BeavonRanging.beaconBool = false
                                BeavonRanging.timer?.invalidate()
                                BeavonRanging.timer = nil
                                BeavonRanging.userLimitBool = false
                                PresenterImpl().showAlert(title: "Your limit has been exceeded. Please contact the admin")
                            }
                        }
                        else {
                            
                        }
                    }
                }
                else {
                    
                }
            }
        }
        return validationflag
    }
    func TicketValidation()->String{
        var dataString = ""
        var ticketId = ""
        var ticketCount = ""
        var agencyName = ""
        BeavonRanging.checkbattery()
        let obj = self.realm.objects(TicketDatas.self).filter("ticketStatus == 2")
        var value : Bool = false
        if realmTotal > 0 && validationflag == "Validate"{
            for realmdata in obj{
                let NewTicketTicket_CountWithZero = String(format: "%03d", realmdata.ticketCount);
                dataString = "201\(NewTicketTicket_CountWithZero)#kamalesh#0#\(realmdata.ticketID)#03-20-2024 16:50#03-20-2024 19:50"
                ticketId = "\(realmdata.ticketID)"
                ticketCount = "\(realmdata.ticketCount)"
                agencyName = "\(realmdata.agencyName)"
            }
            if dataString.isEmpty == false{
                if isReachable(){
                    for realmdata in obj{
                        value = self.present.changeStatus(ticketId: realmdata.ticketID, Status: 3)
                    }
                    let message = CocoaMQTTMessage(topic:"\(beaconLogData.macaddress)/nfc" , string: dataString)
                    CocoaMQTTManager.shared.publish(message: message) { success, ackMessage, id in
                        if success {
                            
                            let jsonObject: [String: Any] = [
                                "TicketId" : "\(ticketId)",
                                "Message" : "Your Ticket Validated Successfully"
                            ]
                            self.receiver.senderFunction(jsonObject: jsonObject)
                            
                            BeavonRanging.mqttValidationEnd = Date().inMiliSeconds()
                            
                            BeavonRanging.totalValidationtime = BeavonRanging.mqttValidationEnd - BeavonRanging.mqttValidationStart
                            
                            SDKViewModel.sharedInstance.limitchange(count: 1, userid: MqttValidationData.userid, typeValidate: "Ticket", ticketID: "\(ticketId)", ValidationMode: BeavonRanging.validationMode, BatteryHealth: "\(benchMarkData.batteryPercent)", MobileModel: "\(benchMarkData.phoneModel)", TypeMobile: "iOS", ConfigAPITime: benchMarkData.cofigApiResponseTime, ValidationDistance: beaconLogData.validationFeetDistance, ibeaconStatus: "3", ConfigForegroundFeet: beaconLogData.beaconValidationFeet, TimeTaken: BeavonRanging.totalValidationtime){ response, success in
                                if success {
                                 //   BeavonRanging.ValidationDeatils(TicketID: Int(ticketId) ?? 0, macAddress:beaconLogData.macaddress)
                                    Trigger().scheduleNotification(title: "Ticket Validate", body: "Your Ticket #\(ticketId) Validated Successfully")
                                    
                                    QRViewController.ticketStatus = "VALIDATE"
                                    QRViewController.ticketId = ticketId
                                    QRViewController.ticketExpiry = "#03-20-2024 16:50"
                                    QRViewController.startColor = "#96e6a1"
                                    QRViewController.endColor = "#009688"
                                    QRViewController.textColor = "#E53638"
                                    QRViewController.totalCount = ticketCount
                                    QRViewController.agencyName = agencyName
                                    let storyboard = UIStoryboard(name: "QRGenerator", bundle: Bundle(for: QRpresenter.self))
                                    let loginViewController = storyboard.instantiateViewController(withIdentifier: "QRViewController") as! QRViewController
                                    if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                                        loginViewController.modalPresentationStyle = .fullScreen
                                        rootViewController.present(loginViewController, animated: true, completion: nil)
                                    }
                                
                                    let text = "Your Ticket #\(ticketId) has been Validated Successfully"
                                    let utterance = AVSpeechUtterance(string: text)
                                    utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                                    utterance.rate = 0.5
                                    self.synth.speak(utterance)
                                    if response?.Message == "OK" && response?.LimitStatus ?? false {
                                        self.startScanning()
                                    }
                                    else {
                                        BeavonRanging.stopRangingBeacons()
                                        BeavonRanging.beaconBool = false
                                        BeavonRanging.timer?.invalidate()
                                        BeavonRanging.timer = nil
                                        BeavonRanging.userLimitBool = false
                                        PresenterImpl().showAlert(title: "Your limit has been exceeded. Please contact the admin")
                                    }
                                }
                                else{
                                    print("Limit Api failed")
                                }
                            }
                            
                        }
                        else {
                            Trigger().scheduleNotification(title: "Ticket Validate", body: "Your Ticket #\(ticketId) Not Validated")
                        }
                    }
                }
                else{
                    PresenterImpl().showAlert(title: "No internet connection")
                }
            }
        }
        if value == true{
            return validationflag
        }
        else{
            return "ValidationFailed"
        }
    }
    
    func TicketVerityAuto() -> String {
        var dataString = ""
        var ticketId = ""
        var ticketCount = ""
        var agencyName = ""
        BeavonRanging.checkbattery()
        let obj = self.realm.objects(TicketDatas.self).filter("ticketStatus == 1")
        var value: Bool = false
        if newTicketCount > 0 && validationflag == "Autovalidation" {
            ticketId = "\(obj[0].ticketID)"
            ticketCount = "\(obj[0].ticketCount)"
            agencyName = "\(obj[0].agencyName)"
            let NewTicketTicket_CountWithZero = String(format: "%03d", obj[0].ticketCount)
            dataString = "201\(NewTicketTicket_CountWithZero)#kamalesh#0#\(obj[0].ticketID)#03-20-2024 16:50#03-20-2024 19:50"
            if !dataString.isEmpty {
                if isReachable(){
                    value = self.present.changeStatus(ticketId: obj[0].ticketID, Status: 3)
                    let message = CocoaMQTTMessage(topic:"\(beaconLogData.macaddress)/nfc" , string: dataString)
                    CocoaMQTTManager.shared.publish(message: message) { success, ackMessage, id in
                        if success {
                            let jsonObject: [String: Any] = [
                                "TicketId" : "\(ticketId)",
                                "Message" : "Your Ticket Validated Successfully"
                            ]
                            self.receiver.senderFunction(jsonObject: jsonObject)
                            BeavonRanging.mqttValidationEnd = Date().inMiliSeconds()
                            BeavonRanging.totalValidationtime = BeavonRanging.mqttValidationEnd - BeavonRanging.mqttValidationStart
                            SDKViewModel.sharedInstance.limitchange(count: 1, userid: MqttValidationData.userid, typeValidate: "Ticket", ticketID: "\(ticketId)", ValidationMode: BeavonRanging.validationMode, BatteryHealth: "\(benchMarkData.batteryPercent)", MobileModel: "\(benchMarkData.phoneModel)", TypeMobile: "iOS", ConfigAPITime: benchMarkData.cofigApiResponseTime, ValidationDistance: beaconLogData.validationFeetDistance, ibeaconStatus: "3", ConfigForegroundFeet: beaconLogData.beaconValidationFeet, TimeTaken: BeavonRanging.totalValidationtime){ response, success in
                                if success {
                              //      BeavonRanging.ValidationDeatils(TicketID: Int(ticketId) ?? 0, macAddress:beaconLogData.macaddress)
                                    Trigger().scheduleNotification(title: "Ticket Validate", body: "Your Ticket #\(ticketId) Validated Successfully")
                                    QRViewController.ticketStatus = "VALIDATE"
                                    QRViewController.ticketId = ticketId
                                    QRViewController.ticketExpiry = "#03-20-2024 16:50"
                                    QRViewController.startColor = "#96e6a1"
                                    QRViewController.endColor = "#009688"
                                    QRViewController.textColor = "#E53638"
                                    QRViewController.totalCount = ticketCount
                                    QRViewController.agencyName = agencyName
                                    let storyboard = UIStoryboard(name: "QRGenerator", bundle: Bundle(for: QRpresenter.self))
                                    let loginViewController = storyboard.instantiateViewController(withIdentifier: "QRViewController") as! QRViewController
                                    if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                                        loginViewController.modalPresentationStyle = .fullScreen
                                        rootViewController.present(loginViewController, animated: true, completion: nil)
                                    }
                                
                                    Api.sharedInstance.TicketLog(ticketID: ticketId, Name: "kamalesh", typeValidation: "AutoValidation", ibeaconStatus: "\(BeavonRanging.beaconStatus)", sdkVersion: "\(ZIGSDK.sdkversion)")
                                    let text = "Your Ticket #\(ticketId) has been Validated Successfully"
                                    let utterance = AVSpeechUtterance(string: text)
                                    utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
                                    utterance.rate = 0.5
                                    self.synth.speak(utterance)
                                    if response?.Message == "OK" && response?.LimitStatus ?? false {
                                        self.startScanning()
                                    }
                                    else {
                                        BeavonRanging.beaconBool = false
                                        BeavonRanging.stopRangingBeacons()
                                        BeavonRanging.timer?.invalidate()
                                        BeavonRanging.timer = nil
                                        BeavonRanging.userLimitBool = false
                                        PresenterImpl().showAlert(title: "Your limit has been exceeded. Please contact the admin")
                                    }
                                }
                                else{
                                    print("Limit api Failed")
                                }
                            }
                        }
                        else {
                            Trigger().scheduleNotification(title: "Ticket Validate", body: "Your Ticket #\(ticketId) has not Validated")
                        }
                    }
                }
                else{
                    PresenterImpl().showAlert(title: "No internet connection")
                }
            }
        }
        if value {
            return validationflag
        } else {
            return "ValidationFailed"
        }
    }
    public static func ValidationDeatils(TicketID : Int, macAddress : String){
        checkbattery()
        var parameters :[String:Any] = [:]
        if tollHeader.enableTollValidation {
            parameters = [
                "userId": MqttValidationData.userid,
                "userName": MqttValidationData.userName,
                "appName": "ZED-SDK",
                "appVersion": "1.0.1",
                "phoneSystem": benchMarkData.phoneSystem,
                "phoneModel": "\(benchMarkData.phoneModel)",
                "batteryPercentage": benchMarkData.batteryPercent,
                "ticketId": TicketID,
                "validationTimeMillis": BeavonRanging.totalValidationtime,
                "validationRangeFeet": beaconLogData.validationFeetDistance,
                "validationMode": validationMode,
                "configApiTime": "N/A",
                "getTicketApiTime": "N/A",
                "activateApiTime" : "N/A",
                "ibeaconStatus": 3,
                "configBackgroundFeet": beaconLogData.beaconValidationFeet,
                "configForegroundFeet": beaconLogData.beaconValidationFeet,
                "vehicleSpeed": "N/A"
            ]
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let message = CocoaMQTTMessage(topic:"\(macAddress)/benchmark" , string: "\(String(describing: jsonString))")
                CocoaMQTTManager.shared.publish(message: message) {_,_,_ in
                    if let acknowledgmentMessage = CocoaMQTTManager.shared.acknowledgmentMessage {
                        print("Acknowledgment received: \(acknowledgmentMessage)")
                        
                    } else {
                        print("Acknowledgment received, but message content is nil")
                    }
                }
            }
        } catch {
            print("Error creating JSON object: \(error)")
        }
        
    }
    public static func checkbattery(){
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        if batteryLevel >= 0.0 {
            benchMarkData.batteryPercent = Int(batteryLevel * 100)
            self.batteryPercentage = Int(batteryLevel * 100)
        } else {
            print("Unable to determine battery level.")
        }
    }
}

//
//  TollModel.swift
//  SwiftFramework
//
//  Created by Ashok on 05/08/24.
//

import Foundation
import UIKit

struct tollHeader {
    static var enableTollValidation = false
}
struct IBeaconToll {
    var name: String
    var laneType: String
    var major: Int
    var minor: Int
    var deviceID: String
    var mqttMac: String
    var validationFeetiOS: Double
    var MeasureValueiOS : Int
    var beaconA_ID : String
}
struct RssiData {
    var rssi: Int
    var major: Int
    var minor: Int
    var distance: Double
    var uuid : String
}
struct RssiDataToll {
    let major: Int
    let minor: Int
    let distance: Double
    let mac: String
    let lane: String
    let validationFeet: Double
    let uuid: String
    let tollBeaconID : String
}
struct featureStatus {
    static var tollValidation = false
    static var beverageValidation = false
    static var WalletEnableStatus = true
    static var TicketValidationStatus = false
}
struct benchMarkData {
    static var batteryPercent = 0
    static var phoneSystem = true
    static var phoneModel = UIDevice.modelName
    static var cofigApiResponseTime = 0
}
enum TicketCounterResult {
    case success
    case failure(Error)
}
public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
#if os(iOS)
            switch identifier {
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPhone13,1":                              return "iPhone 12 mini"
            case "iPhone13,2":                              return "iPhone 12"
            case "iPhone13,3":                              return "iPhone 12 Pro"
            case "iPhone13,4":                              return "iPhone 12 Pro Max"
            case "iPhone14,4":                              return "iPhone 13 mini"
            case "iPhone14,5":                              return "iPhone 13"
            case "iPhone14,2":                              return "iPhone 13 Pro"
            case "iPhone14,3":                              return "iPhone 13 Pro Max"
            case "iPhone8,4":                               return "iPhone SE (1st generation)"
            case "iPhone12,8":                              return "iPhone SE (2nd generation)"
            case "iPhone14,6":                              return "iPhone SE (3rd generation)"
            case "iPhone15,2":                              return "iPhone 14 Pro"
            case "iPhone15,3":                              return "iPhone 14 Pro Max"
            case "iPhone14,7":                              return "iPhone 14"
            case "iPhone14,8":                              return "iPhone 14 Plus"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                    return "iPad (8th generation)"
            case "iPad12,1", "iPad12,2":                    return "iPad (9th generation)"
            case "iPad13,18", "iPad13,19":                  return "iPad (10th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                     return "iPad Pro (11-inch) (2nd generation)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7": return "iPad Pro (11-inch) (3rd generation)"
            case "iPad14,3", "iPad14,4":                    return "iPad Pro (11-inch) (4th generation)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                    return "iPad Pro (12.9-inch) (4th generation)"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11": return "iPad Pro (12.9-inch) (5th generation)"
            case "iPad14,5", "iPad14,6":                    return "iPad Pro (12.9-inch) (6th generation)"
            case "iPad7,9", "iPad7,10":                     return "iPad Pro 2nd Gen (12.9-inch, Cellular)"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad14,1", "iPad14,2":                    return "iPad mini (6th generation)"
            case "iPad11,3", "iPad11,4":                    return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                    return "iPad Air (4th generation)"
            case "iPad13,16", "iPad13,17":                  return "iPad Air (5th generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AppleTV11,1":                             return "Apple TV 4K (2nd generation)"
            case "AppleTV14,1":                             return "Apple TV 4K (3rd generation)"
            case "AudioAccessory1,1":                       return "HomePod"
            case "AudioAccessory5,1":                       return "HomePod mini"
            case "i386", "x86_64", "arm64":                 return "Simulator"
            default:                                        return identifier
            }
#elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
#endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    static let iOSVersion: String = {
            return UIDevice.current.systemVersion
        }()
    
}
public extension Date{
    func inMiliSeconds() -> Int {
        let since1970 = self.timeIntervalSince1970
        return Int(since1970 * 1000)
    }
}

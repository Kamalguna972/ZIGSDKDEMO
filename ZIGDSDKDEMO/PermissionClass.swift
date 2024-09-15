//
//  PermissionClass.swift
//  SwiftFramework
//
//  Created by Ashok on 03/08/24.
//

import Foundation
import UIKit
public struct PermissionItem {
    let description: String
    let keywordHighlight: String
    let permissionType: PermissionType
    let title: String
    let Systemimage: String
    public init(description: String, keywordHighlight: String, permissionType: PermissionType, title: String, image: String) {
        self.description = description
        self.keywordHighlight = keywordHighlight
        self.permissionType = permissionType
        self.title = title
        self.Systemimage = image
    }
}
public enum PermissionType {
    case location
    case bluetooth
    case notification
    case camera
    var title: String {
        switch self {
        case .location:
            return "location.fill.viewfinder"
        case .notification:
            return "bell.fill"
        case .bluetooth:
            return "BlutoothImg"
        case.camera:
            return "camera.fill"
        default:
            return "General Permission"
        }
    }
}

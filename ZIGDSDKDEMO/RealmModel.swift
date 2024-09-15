//
//  RealmModel.swift
//  SwiftFramework
//
//  Created by apple on 28/03/24.
//

import Foundation
import RealmSwift
class TicketDatas : Object{
    @objc dynamic var ticketID = 0
    @objc dynamic var ticketName = ""
    @objc dynamic var ticketCount = 0
    @objc dynamic var activateDate = ""
    @objc dynamic var purchasedDate = ""
    @objc dynamic var expiryDate = ""
    @objc dynamic var ticketStatus = 0
    @objc dynamic var agencyName = ""
}

struct OdataAPi : Codable {
    var Message : String?
}

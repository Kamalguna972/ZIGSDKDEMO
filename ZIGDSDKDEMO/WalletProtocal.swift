//
//  WalletProtocal.swift
//  SwiftFramework
//
//  Created by Ashok on 05/09/24.
//

import Foundation
protocol addWalletDelegate {
    func zigCreditWallet( walletTitle: String,
                       buttonText: String,
                       userId : Int,
                       userName : String,
                       creditAmount : Double,completion: @escaping (Bool, ([String: Any])) -> Void)
}
protocol walletPaymentDelegate {
    func zigSuperwalletPayment( walletTitle: String,
                        buttonText: String,
                        userId : Int,
                        userName : String,
                        debitAmount : Double,
                        purpose: String,completion: @escaping (Bool, ([String: Any])) -> Void)
}
protocol ZIGSuperWalletBalanceDelegate {
    func zigGetWallet(userId: Int,completion: @escaping (Bool, ([String: Any])) -> Void)
}

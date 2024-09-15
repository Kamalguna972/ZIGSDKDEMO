//
//  ReduceWalletAmount.swift
//  SwiftFramework
//
//  Created by Ashok on 08/09/24.
//

import UIKit

class ReduceWalletAmount: UIViewController {
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var walletTotalAmount: UILabel!
    @IBOutlet weak var walletDescription: UILabel!
    @IBOutlet weak var walletTitle: UILabel!
    @IBOutlet weak var walletCheckBox: UIButton!
    @IBOutlet weak var walletPaymentView: UIView!
    @IBOutlet weak var totalTitlr: UILabel!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var PaymentTitle: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    var successHandler: ((Bool, [String: Any]?) -> Void)?
    var failureHandler: ((Bool, [String: Any]?) -> Void)?
    let activityIndicator = UIActivityIndicatorView()
    static var clientId = 0
    static var userId = 0
    static var debitAmount = 0.0
    static var purpose = ""
    static var userName = ""
    static var walletTitle = ""
    static var payTitle = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    func setUpUI(){
        overrideUserInterfaceStyle = .light
        self.showLoader()
        cancelButton.layer.cornerRadius = 10
        buyButton.layer.cornerRadius = 10
        WalletViewModel.sharedInstance.walletBalanceCheck(clientId: MqttValidationData.userid, userId: ReduceWalletAmount.userId) { response, success in
            if success{
                self.hideLoader()
                print("ReduceWalletAmount.debitAmount====>",ReduceWalletAmount.debitAmount)
                self.walletTotalAmount.text = "$ \(response?.walletBalanceAmount ?? 0.0)"
                self.totalAmount.text = "$ \(ReduceWalletAmount.debitAmount)"
            }
            else{
                self.hideLoader()
                let jsonObject: [String: Any] = [
                    "Message" : "\(response?.Message ?? "")"
                    ]
                self.failureHandler?(success,jsonObject)
            }
        }
    }
    @IBAction func buyAction(_ sender: Any) {
        self.showLoader()
        WalletViewModel.sharedInstance.walletPaymentMethod(clientName: MqttValidationData.userName, clientId: MqttValidationData.userid, userId: ReduceWalletAmount.userId, userName: ReduceWalletAmount.userName, creditAmount: 0.0, debitAmount: ReduceWalletAmount.debitAmount, purpose: ReduceWalletAmount.purpose, walletBool: false) { response, success in
            if success{
                self.hideLoader()
                if response?.WalletEnableStatus ?? false {
                    let jsonObject: [String: Any] = [
                        "Message" : "\(response?.Message ?? "")",
                        "userId" : "\(response?.userId ?? 0)",
                        "userName" : "\(response?.userName ?? "")",
                        "BalanceAmount" : "\(response?.walletBalanceAmount ?? 0.0)"
                    ]
                    Trigger().scheduleNotification(title: "ZIG SuperWallet", body: "Your recent transaction has been processed. $\(ReduceWalletAmount.debitAmount) has been debited from your wallet.")
                    self.successHandler?(response?.WalletEnableStatus ?? false,jsonObject)
                    self.dismiss(animated: true)
                }
                else{
                    self.hideLoader()
                    self.dismiss(animated: true)
                    let jsonObject: [String: Any] = [
                        "Message" : "\(response?.Message ?? "")",
                    ]
                    self.successHandler?(response?.WalletEnableStatus ?? false,jsonObject)
                }
            }
            else{
                self.hideLoader()
                let jsonObject: [String: Any] = [
                    "Message" : "\(response?.Message ?? "")"
                    ]
                self.failureHandler?(success,jsonObject)
                self.dismiss(animated: true)
            }
        }
    }
    @IBAction func cancelBtn(_ sender: Any) {
        self.dismiss(animated: true)
    }
    func hideLoader()
    {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    func showLoader()
    {
        DispatchQueue.main.async {
            self.activityIndicator.style = .medium
            self.activityIndicator.backgroundColor = .white
            self.activityIndicator.color = .black
            self.activityIndicator.alpha = 0.7
            self.activityIndicator.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            self.activityIndicator.center = self.view.center
            self.view.addSubview(self.activityIndicator)
            self.activityIndicator.startAnimating()
        }
    }
}

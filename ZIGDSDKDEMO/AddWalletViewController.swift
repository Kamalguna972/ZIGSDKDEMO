//
//  AddWalletViewController.swift
//  SwiftFramework
//
//  Created by Ashok on 05/09/24.
//

import UIKit

class AddWalletViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate {
    
    @IBOutlet weak var paybtn: UIButton!
    @IBOutlet weak var cancelImg: UIImageView!
    @IBOutlet weak var fieldView: UIView!
    @IBOutlet weak var amountCollection: UICollectionView!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var brandTitle: UILabel!
    let activityIndicator = UIActivityIndicatorView()
    var amountArray = ["10","15","20","50","100","1000"]
    
    static var brandTitle = ""
    static var payTitle = ""
    static var clientName = ""
    static var clientId = 0
    static var userID = 0
    static var userName = ""
    static var creditAmount = 0.0
    
    var successHandler: ((Bool, [String: Any]?) -> Void)?
    var failureHandler: ((Bool, [String: Any]?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setUpUI()
        amountCollection.register(UINib(nibName: "AddWallet",bundle: Bundle(for: type(of: self))), forCellWithReuseIdentifier: "AddWalletCollectionViewCell")
    }
    func setUpUI(){
        AddWalletViewController.brandTitle = AddWalletViewController.brandTitle.isEmpty ? "Add funds to ZIG SuperWallet" :  AddWalletViewController.brandTitle
        AddWalletViewController.payTitle = AddWalletViewController.payTitle.isEmpty ? "Pay" : AddWalletViewController.payTitle
        
        fieldView.layer.borderWidth = 2
        fieldView.layer.borderColor = UIColor.black.cgColor
        fieldView.layer.cornerRadius = 5
        amountField.keyboardType = .numberPad
        amountField.delegate = self
        
        brandTitle.text = AddWalletViewController.brandTitle
        paybtn.setTitle(AddWalletViewController.payTitle, for: .normal)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        cancelImg.addGestureRecognizer(tapGesture)
        
        paybtn.layer.cornerRadius = paybtn.frame.height/2
    }
    
    @IBAction func payAction(_ sender: Any) {
        self.showLoader()
        AddWalletViewController.creditAmount = 0.0
        if let amountText = amountField.text?.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces),
           let creditAmount = Double(amountText) {
            AddWalletViewController.creditAmount = creditAmount
        } else {
            print("Failed to convert the string to a Double")
        }
        if AddWalletViewController.creditAmount > 0{
            WalletViewModel.sharedInstance.walletPaymentMethod(clientName: MqttValidationData.userName, clientId: MqttValidationData.userid, userId: AddWalletViewController.userID, userName: AddWalletViewController.userName, creditAmount: AddWalletViewController.creditAmount, debitAmount: 0.0, purpose: "Wallet Recharge", walletBool: true) { response, success in
                if success{
                    if response?.WalletEnableStatus ?? false {
                        self.hideLoader()
                        self.dismiss(animated: true)
                        let jsonObject: [String: Any] = [
                            "Message" : "\(response?.Message ?? "")",
                            "userId" : "\(response?.userId ?? 0)",
                            "userName" : "\(response?.userName ?? "")",
                            "BalanceAmount" : "\(response?.walletBalanceAmount ?? 0.0)"
                        ]
                        Trigger().scheduleNotification(title: "ZIG SuperWallet", body: "Congratulations! Your wallet has been credited with $\(AddWalletViewController.creditAmount).")
                        self.successHandler?(response?.WalletEnableStatus ?? false,jsonObject)
                    }
                    else
                    {
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
                }
            }
        }
        else{
            self.hideLoader()
            let toast = ToastView(message: "Enter your amount")
            toast.showToast(inView: self.view)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return amountArray.count
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        amountField.placeholder = ""
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if amountField.text?.isEmpty ?? true {
            amountField.placeholder = "$ Enter an amount"
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        amountField.resignFirstResponder()
        return true
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddWalletCollectionViewCell", for: indexPath) as! AddWalletCollectionViewCell
        cell.listedAmount.text = "$ \(amountArray[indexPath.row])"
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        amountField.text = "$ \(amountArray[indexPath.row])"
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
extension AddWalletViewController {
    @objc func imageTapped() {
        self.dismiss(animated: true)
    }
}

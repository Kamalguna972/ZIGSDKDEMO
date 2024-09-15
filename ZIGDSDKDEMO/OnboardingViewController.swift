//
//  OnbordingViewController.swift
//  ZIGBIBOSDK
//
//  Created by apple on 15/03/24.
//

import UIKit
class OnboardingViewController: UIViewController {
    var completionHandler: ((Bool, String?) -> Void)?
    var cancelButtonAction: ((Bool, String?) -> Void)?
    @IBOutlet weak var canclebtn: UIButton!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var backview: UIView!
    @IBOutlet weak var Sublable: UILabel!
    @IBOutlet weak var onboardImg: UIImageView!
    static var title = ""
    static var subtitle = ""
    static var sendButtonTitle = ""
    static var cancleButtonTitle = ""
    static var imgUrl = ""
    static var backgroundColor = ""
    static var textColor = ""
    let startTime = Date()
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupui()
    }
    func setupui(){
        OnboardingViewController.title = OnboardingViewController.title.isEmpty ? "STOP Request" : OnboardingViewController.title
        OnboardingViewController.subtitle = OnboardingViewController.subtitle.isEmpty ? "Stop is a feature is available  on our buses. Click to request the driver to stop the upcomming bus stop." : OnboardingViewController.subtitle
        OnboardingViewController.sendButtonTitle = OnboardingViewController.sendButtonTitle.isEmpty ? "Send Request" : OnboardingViewController.sendButtonTitle
        OnboardingViewController.cancleButtonTitle = OnboardingViewController.cancleButtonTitle.isEmpty ? "Cancle" : OnboardingViewController.cancleButtonTitle
        OnboardingViewController.textColor =  OnboardingViewController.textColor.isEmpty ? "#FFFFFF" : OnboardingViewController.textColor
        OnboardingViewController.backgroundColor = OnboardingViewController.backgroundColor.isEmpty ? "#FF3B30" : OnboardingViewController.backgroundColor
        OnboardingViewController.imgUrl = OnboardingViewController.imgUrl.isEmpty ? "https://www.zed.digital/img/app/onbord.png" : OnboardingViewController.imgUrl
        
        canclebtn.setTitle(OnboardingViewController.cancleButtonTitle, for: .normal)
        sendBtn.setTitle(OnboardingViewController.sendButtonTitle, for: .normal)
        Sublable.text = OnboardingViewController.subtitle
        view.backgroundColor = UIColor(hex:OnboardingViewController.backgroundColor)
        sendBtn.setTitleColor(UIColor(hex:OnboardingViewController.textColor), for: .normal)
        canclebtn.setTitleColor(UIColor(hex: OnboardingViewController.textColor), for: .normal)
        titleLable.textColor = UIColor(hex: OnboardingViewController.textColor)
        Sublable.textColor = UIColor(hex: OnboardingViewController.textColor)
        titleLable.text = OnboardingViewController.title
        sendBtn.layer.cornerRadius = 10
        backview.layer.cornerRadius = backview.frame.height/2 - 10
        loadImage(from: OnboardingViewController.imgUrl) { [weak self] image in
            guard let self = self else { return }
            if let image = image {
                self.onboardImg.image = image
            } else {
               
            }
        }
    }
    @IBAction func sendAct(_ sender: Any) {
        self.dismiss(animated: true)
        completionHandler?(true,"Success")
    }
    @IBAction func cancleAct(_ sender: Any) {
        self.dismiss(animated: true)
        cancelButtonAction?(false, "Failure")
    }
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true)
        cancelButtonAction?(false, "Failure")
    }
}

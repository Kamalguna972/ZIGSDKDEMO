//
//  IllegalViewController.swift
//  SwiftFramework
//
//  Created by apple on 02/04/24.
//

import UIKit
class IllegalViewController: UIViewController {
    private var imageVC: UIImagePickerController?
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var messageLable: UILabel!
    @IBOutlet weak var illegalImg: UIImageView!
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var subTitleLable: UILabel!
    @IBOutlet weak var titleLable: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        initialSetup()
        camerasetup()
        setupUI()
    }
    func setupUI(){
        firstView.backgroundColor = UIColor.white
        subTitleLable.textColor = UIColor.black
        messageLable.textColor = UIColor.black
        firstView.layer.cornerRadius = 10
        mainView.layer.cornerRadius = 10
        firstView.layer.shadowColor = UIColor.lightGray.cgColor
        firstView.layer.shadowOffset = CGSize(width: 2, height: 2)
        firstView.layer.shadowRadius = 1
    }
    func camerasetup(){
        self.imageVC = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // self.imageVC?.didMove(toParent: self)
            self.imageVC?.sourceType = .camera
            self.imageVC?.allowsEditing = false
            self.imageVC?.cameraDevice = .front
            self.imageVC?.showsCameraControls = false
            let screenSize = UIScreen.main.bounds.size
            let cameraAspectRatio = CGFloat(4.0 / 3.0)
            let cameraImageHeight = screenSize.width * cameraAspectRatio
            let scale = screenSize.height/screenSize.width * cameraAspectRatio
            self.imageVC?.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
            self.imageVC?.view.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
            self.cameraView.addSubview(self.imageVC!.view)
            self.view.sendSubviewToBack(self.imageVC!.view)
        }
    }
    private func initialSetup() {
        let startColorHex = UIColor(red: 255.0 / 255.0, green: 149.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0).cgColor
        let endColorHex = UIColor(red: 253 / 255.0, green: 67.0 / 255.0, blue: 52 / 255.0, alpha: 1.0).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [startColorHex,endColorHex]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    @IBAction func closeAct(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

//
//  QRViewController.swift
//  QRpermisson
//
//  Created by apple on 30/03/24.
//

import UIKit
import AVFoundation
class QRViewController: UIViewController {
    private var imageVC: UIImagePickerController?
    @IBOutlet weak var ticketStatus: UILabel!
    @IBOutlet weak var expiryDate: UILabel!
    @IBOutlet weak var ticketId: UILabel!
    @IBOutlet weak var ticketIdLable: UILabel!
    @IBOutlet weak var upperView: UIView!
    @IBOutlet weak var expiryTime: UILabel!
    @IBOutlet weak var CloseBtn: UIButton!
    @IBOutlet weak var ticketCount: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var CameraView: UIView!
    @IBOutlet weak var QRImgView: UIImageView!
    @IBOutlet weak var MiddleView: UIView!
    @IBOutlet weak var Time: UILabel!
    @IBOutlet weak var agencyName: UILabel!
    var captureSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    static var ticketStatus = ""
    static var ticketId = ""
    static var ticketExpiry = ""
    static var totalCount = ""
    static var startColor = ""
    static var endColor = ""
    static var textColor = ""
    static var agencyName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        initialSetup()
        ticketId.text = "#\(QRViewController.ticketId)"
        ticketStatus.text = "\(QRViewController.ticketStatus)"
        ticketCount.text = "\(QRViewController.totalCount)"
        agencyName.text = "\(QRViewController.agencyName)"
        ticketStatus.textColor = UIColor(hex: QRViewController.textColor)
        expiryDate.textColor = UIColor.black
        ticketId.textColor = UIColor.black
        ticketIdLable.textColor = UIColor.black
        expiryTime.textColor = UIColor.black
        Time.textColor = UIColor.black
        upperView.layer.shadowColor = UIColor.lightGray.cgColor
        upperView.layer.shadowOffset = CGSize(width: 2, height: 2)
        upperView.layer.shadowRadius = 1
        upperView.backgroundColor = UIColor.white
        upperView.layer.cornerRadius = 10
        mainView.layer.cornerRadius = 10
        ticketCount.textColor = UIColor.black
        applyTicketMask(to: mainView)
        let image = generateQRCode(from: QRViewController.ticketId)
        QRImgView.image = image
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
            self.CameraView.addSubview(self.imageVC!.view)
            self.view.sendSubviewToBack(self.imageVC!.view)
        }
        
//        let toast = ToastView(message: "\(QRViewController.ticketId) has been succesfully validated" ?? "")
//        toast.showToast(inView: self.view)
    }
    private func initialSetup() {
        let startColorHex = "\(QRViewController.startColor)" // Green
        let endColorHex = "\(QRViewController.endColor)"   // Yellow
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(hex: startColorHex).cgColor, UIColor(hex: endColorHex).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
    
    @IBAction func CloseAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    func applyTicketMask(to view: UIView) {
            let path = UIBezierPath()
            let cornerRadius: CGFloat = 5.0
            let arcRadius: CGFloat = 15.0
            let rect = view.bounds
            
            // Start at the top-left corner
            path.move(to: CGPoint(x: cornerRadius, y: 0))
            
            // Top-right corner
            path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
            path.addArc(withCenter: CGPoint(x: rect.width - cornerRadius, y: cornerRadius),
                        radius: cornerRadius,
                        startAngle: CGFloat(3 * Double.pi / 2),
                        endAngle: 0,
                        clockwise: true)
            
            // Right side arc cut
            path.addLine(to: CGPoint(x: rect.width, y: rect.midY - arcRadius))
            path.addArc(withCenter: CGPoint(x: rect.width, y: 100),
                        radius: arcRadius,
                        startAngle: CGFloat(3 * Double.pi / 2),
                        endAngle: CGFloat(Double.pi / 2),
                        clockwise: false)
            path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
            
            // Bottom-right corner
            path.addArc(withCenter: CGPoint(x: rect.width - cornerRadius, y: rect.height - cornerRadius),
                        radius: cornerRadius,
                        startAngle: 0,
                        endAngle: CGFloat(Double.pi / 2),
                        clockwise: true)
            
            // Bottom-left corner
            path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
            path.addArc(withCenter: CGPoint(x: cornerRadius, y: rect.height - cornerRadius),
                        radius: cornerRadius,
                        startAngle: CGFloat(Double.pi / 2),
                        endAngle: CGFloat(Double.pi),
                        clockwise: true)
            
            // Left side arc cut
            path.addLine(to: CGPoint(x: 0, y: rect.midY + arcRadius))
            path.addArc(withCenter: CGPoint(x: 0, y: 100),
                        radius: arcRadius,
                        startAngle: CGFloat(Double.pi / 2),
                        endAngle: CGFloat(3 * Double.pi / 2),
                        clockwise: false)
            path.addLine(to: CGPoint(x: 0, y: cornerRadius))
            
            // Close the path
            path.close()
            
            // Create a shape layer for the mask
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            
            // Apply the mask to the view
            view.layer.mask = maskLayer
            
        }
    
}
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

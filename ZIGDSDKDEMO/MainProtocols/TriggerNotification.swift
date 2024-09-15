//
//  TriggerNotification.swift
//  SwiftFramework
//
//  Created by apple on 09/04/24.
//

import Foundation
import UserNotifications
import SystemConfiguration
import UIKit
class Trigger {
    public func scheduleNotification(title: String, body: String) {
        let identifier = UUID().uuidString
        let notificationCenter = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request)
    }
}
func isReachable() -> Bool{
    
    let isReach : Bool = ReachabilityNetwork.isConnectedToNetwork()
    
    return isReach
}

func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            completion(nil)
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            completion(nil)
            return
        }
        
        if let data = data, let image = UIImage(data: data) {
            DispatchQueue.main.async {
                completion(image)
            }
        } else {
            completion(nil)
        }
    }
    task.resume()
}
public class ReachabilityNetwork {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr()
        zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
        zeroAddress.sa_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else { return false }
        
        var flags = SCNetworkReachabilityFlags()
        guard SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) else { return false }
        
        return flags.contains(.reachable) && !flags.contains(.connectionRequired)
    }
    
}
class ToastView: UIView {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    init(message: String) {
        super.init(frame: CGRect.zero)
        configureView()
        messageLabel.text = message
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        backgroundColor = UIColor(white: 0, alpha: 0.7)
        layer.cornerRadius = 10
        addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }
    
    func showToast(inView view: UIView, duration: TimeInterval = 2.0) {
        self.alpha = 0.0
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseInOut, animations: {
                self.alpha = 0.0
            }, completion: { _ in
                self.removeFromSuperview()
            })
        }
    }
}
class receiverNotification: receiverDelegate {
    private var messageHandler: (([String: Any]) -> Void)?
    private var observer: NSObjectProtocol?

    func registerForMessages(handler: @escaping ([String: Any]) -> Void) {
        self.messageHandler = handler
        observer = NotificationCenter.default.addObserver(forName: .didReceiveMessage, object: nil, queue: .main) { [weak self] notification in
            if let userInfo = notification.userInfo, let jsonData = userInfo["json"] as? Data {
                do {
                    if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                        self?.messageHandler?(jsonObject)
                    }
                } catch {
                }
            }
        }
    }

    func senderFunction(jsonObject: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            NotificationCenter.default.post(name: .didReceiveMessage, object: nil, userInfo: ["json": jsonData])
        } catch {
        }
    }

    func unregisterForMessages() {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
            self.observer = nil
        }
    }

    deinit {
        unregisterForMessages()
    }
}
class sdkLog {
    public static let shared = sdkLog()
    public func printLog(message : String){
        if BeavonRanging.logEnable{
            print(message)
        }
    }
}

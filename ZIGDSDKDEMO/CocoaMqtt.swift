import Foundation
import CocoaMQTT

class CocoaMQTTManager: NSObject, CocoaMQTTDelegate {
    static let shared = CocoaMQTTManager()
    var mqtt: CocoaMQTT?
    var acknowledgmentMessage: String?
    private var publishCompletionHandler: ((Bool, String?, UInt16?) -> Void)?
    private var messageQueue: [CocoaMQTTMessage] = []
    private var isConnecting = false  // Flag to track connection attempts
    
    private override init() {
        super.init()
        setupMQTT()
    }
    
    private func setupMQTT() {
        let clientID = "CocoaMQTT-" + String(ProcessInfo().processIdentifier)
        mqtt = CocoaMQTT(clientID: clientID, host: "mqtt.zig-web.com", port: 1883)
        mqtt?.username = "iPhone"
        mqtt?.password = "Polgara12ZED2122"
        mqtt?.keepAlive = 60
        mqtt?.delegate = self
        mqtt?.enableSSL = false
        connect()
    }
    
    private func connect() {
        guard let mqtt = mqtt else {
            return
        }

        if mqtt.connState != .connected && !isConnecting {
            isConnecting = true
            mqtt.connect()
        } else if mqtt.connState == .connected {
            isConnecting = false
            publishQueuedMessages()
        }
    }
    
    func publish(message: CocoaMQTTMessage, completion: @escaping (Bool, String?, UInt16?) -> Void) {
        guard let mqtt = mqtt else {
            completion(false, "MQTT client is nil.", nil)
            return
        }
        
        publishCompletionHandler = completion

        if mqtt.connState == .connected {
            mqtt.publish(message)
        } else {
            messageQueue.append(message)
            connect()
        }
    }
    
    func subscribe(to topic: String) {
        mqtt?.subscribe(topic)
    }
    
    // MARK: - CocoaMQTTDelegate methods
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            publishQueuedMessages()
        } else {
            isConnecting = false
            publishCompletionHandler?(false, "Failed to connect to MQTT: \(ack)", nil)
            publishCompletionHandler = nil
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        if state == .disconnected && mqtt.autoReconnect {
            connect()
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        acknowledgmentMessage = message.string // Store the acknowledgment message
        publishCompletionHandler?(true, message.string, id)
        publishCompletionHandler = nil
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        NotificationCenter.default.post(name: NSNotification.Name("MQTTMessageReceived"), object: nil, userInfo: ["message": message.string ?? "Empty Message"])
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        isConnecting = false
        if let error = err {
            publishCompletionHandler?(false, "Disconnected with error: \(error.localizedDescription)", nil)
        } else {
            publishCompletionHandler?(false, "Disconnected from MQTT", nil)
        }
        publishCompletionHandler = nil
    }
    
    private func publishQueuedMessages() {
        guard let mqtt = mqtt else { return }
        
        while !messageQueue.isEmpty && mqtt.connState == .connected {
            let message = messageQueue.removeFirst()
            mqtt.publish(message)
        }
    }
}

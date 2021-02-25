//
//  ViewController.swift
//  Heart Rate to iCloud
//
//  Created by vctrg on 2/6/21.
//

import UIKit
import HealthKit
import WatchConnectivity
import AWSIoT

class ViewController: UIViewController {

    @IBOutlet var heartBeatiOS: UILabel!
    @IBOutlet var SPO2iOS: UILabel!
    @IBOutlet var avgLongTermNE: UILabel!
    @IBOutlet var publishButton: UIButton!
    @IBOutlet var awsConnectionLabel: UILabel!
    @IBOutlet var IDTextField: UITextField!
    var noiseExpos = "00"
    let session2 = WCSession.default
    var session: WCSession?
    var clientId = "0000"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.configureWatchKitSession()
        
        print("after init check")
//        HealthDataManager.sharedInstance.newECGQuery()
        AWSManagement.awsManagement.awsSetup()
        AWSManagement.awsManagement.getAWSClientId { (clientId, Error) in
            print(clientId!)
        }
        AWSManagement.awsManagement.connectToAWSIoT(clientId: clientId)
        AWSManagement.awsManagement.registerSubscription()
    }

    func configureWatchKitSession(){
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    @IBAction func closeKeyboardPressed(_ sender: Any){
        IDTextField.endEditing(true)
        let data: [String: Any] = ["Name Label":"\(IDTextField.text!)" as Any]
        print(data)
        self.session!.sendMessage(data, replyHandler: nil, errorHandler: nil)
    }
    
    @IBAction func publishButtonPressed(_ sender: UIButton) {
        AWSManagement.awsManagement.publishMessage(message: "hello", topic: "topicInitial")
    }
}
extension ViewController: WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){
    }
        
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("message received: \(message)")
        print("spo2 received: \(message)")
        print("Long Term Noise Expos Received: \(message)")
        DispatchQueue.main.async {
            if let heartRate = message["hr"] as? String {
                self.heartBeatiOS.text = ("\(heartRate) BPM")
                AWSManagement.awsManagement.publishMessage(message: "\(self.IDTextField.text!)'s HeartBeat: \(heartRate) BPM", topic: "topicInitial")
            }
        }
        DispatchQueue.main.async {
            if let SPO2 = message["spo2"] as? String {
                self.SPO2iOS.text = ("\(SPO2)%")
                AWSManagement.awsManagement.publishMessage(message: "\(self.IDTextField.text!)'s Blood Oxygen Saturation \(SPO2)%", topic: "topicInitial")
            }
        }
        DispatchQueue.main.async {
            if let noiseExpos = message["NoiseEx"] as? String {
                self.avgLongTermNE.text = ("\(noiseExpos) DB")
            print(noiseExpos)
                AWSManagement.awsManagement.publishMessage(message: "\(self.IDTextField.text!)'s Average Long Term Noise Exposure: \(noiseExpos) DB", topic: "topicInitial")
                print(self.IDTextField.text!)
            }
        }
    }

}


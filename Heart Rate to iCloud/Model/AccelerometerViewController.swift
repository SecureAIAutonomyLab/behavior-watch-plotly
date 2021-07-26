//
//  ECG Data View Controller.swift
//  Cloud Vitals
//
//  Created by vctrg on 3/8/21.
//

import Foundation
import UIKit
import HealthKit
import Charts
import WatchConnectivity
import Amplify
import AmplifyPlugins
import Combine

class AccelerometerViewController : UIViewController {
    
    @IBOutlet var xLabel: UILabel!
    //    crate label for x values
    @IBOutlet var yLabel: UILabel!
    //    create label for y values
    @IBOutlet var zLabel: UILabel!
    //    create label for z values
    @IBOutlet var resultantLabel: UILabel!
    //    create label for resultant values
    @IBOutlet weak var xyzSwitch: UISwitch!
    //    create outlet to xyz upload switch
    @IBOutlet weak var resultantSwitch: UISwitch!
    //    create outlet to resultant upload switch
    @IBOutlet var userGuideButton: UIButton!
    //    create outlet for user guide page button
    @IBOutlet var vitalsButton: UIButton!
    //    create outlet for vitals page button
    
    let settingsVC = SettingsViewController()
    var awsData = AWSDataManager()
    var session: WCSession?
    //    create variable for apple watch session
    var biometricArray : [String] = []
    //    create empty array
    var resultSink: AnyCancellable?
    //    initiate variable to signify result has been published to AWS
    var progressSink: AnyCancellable?
    //    initiate variable to display uploading progress for upload to AWS
    let userDefaultsVitals = UserDefaults.standard
    //    create variable for internal data storage
    var timer = Timer.init()
    //    create timer for monitoring accelerations at specified rates
    let viewController = ViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWatchKitSession()
        //        begin apple watch session
        userGuideButton.layer.cornerRadius = 13
        vitalsButton.layer.cornerRadius = 13
        //        curve corners of page navigation buttons with radi of 13 pixels
        let xyzSwitchCheck = userDefaultsVitals.string(forKey: "XYZ Switch")
        let resultantSwitchCheck = userDefaultsVitals.string(forKey: "Resultant Switch")
        //        get state of acceleration uploading switches
        if xyzSwitchCheck == "ON"{
            xyzSwitch.setOn(true, animated: true)
            print("Still ON")
        }
        else if xyzSwitchCheck == "OFF" {
            xyzSwitch.setOn(false, animated: true)
        }
        if resultantSwitchCheck == "ON"{
            resultantSwitch.setOn(true, animated: true)
        }
        else if resultantSwitchCheck == "OFF" {
            resultantSwitch.setOn(false, animated: true)
        }
        //        check for previous states of switches and update interface accordingly
    }
    
    func configureWatchKitSession() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            //            initialize apple watch session
        }
    }
    
    @IBAction func xyzButton(_ sender: Any) {
        if xyzSwitch.isOn{
            self.userDefaultsVitals.setValue("ON", forKey: "XYZ Switch")
            
        }
        else{
            self.userDefaultsVitals.setValue("OFF", forKey: "XYZ Switch")
        }
        //        change state of xyz upload switch if state was changed by user
    }
    @IBAction func resultantButton(_ sender: Any) {
        if resultantSwitch.isOn{
            self.userDefaultsVitals.setValue("ON", forKey: "Resultant Switch")
        }
        else{
            self.userDefaultsVitals.setValue("OFF", forKey: "Resultant Switch")
        }
        //        change state of resultant upload switch if state was changed by user
    }
}

extension AccelerometerViewController: WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    
        DispatchQueue.main.async {
            let dataSwitchCheck = self.userDefaultsVitals.string(forKey: "Data Switch")
            //            retrieve state of ViewController.swift's data switch
            let viewController = ViewController()
            if let heartRate = message["hr"] as? String {
                let heartRateMessage = ("heart_rate:\(heartRate)")
                if dataSwitchCheck == "ON" {
                    self.awsData.uploadPhysiologicalData(vitalsValue: heartRateMessage)
                }
            }
            
            if let SPO2 = message["spo2"] as? String {
                let spo2Message = ("blood_o2:\(SPO2)")
                if dataSwitchCheck == "ON"{
                    self.awsData.uploadPhysiologicalData(vitalsValue: spo2Message)
                }
            }
            
            if let noiseExpos = message["NoiseEx"] as? String {
                let longTermNEMessage = ("noise:\(noiseExpos)")
                if dataSwitchCheck == "ON"{
                    self.awsData.uploadPhysiologicalData(vitalsValue: longTermNEMessage)
                }
            }
            
            if let sleepTime = message["SleepTime"] as? Double {
                let sleepMessage = ("sleep:\(sleepTime)")
                HealthDataManager.sharedInstance.retrieveSleep { result -> Void in
                    DispatchQueue.main.async {
                    }
                }
                if dataSwitchCheck == "ON"{
                    self.awsData.uploadPhysiologicalData(vitalsValue: sleepMessage)
                }
            }
            if (message["Start Pressed"] as? String) != nil {
                if dataSwitchCheck == "ON" {
                    let uploadLocation = HealthDataManager.sharedInstance.requestLocationAuthorization()[1]
                    self.timer = Timer(fire: Date(), interval: (120.0/1.0),
                                       repeats: true, block: { (timer) in
                                        self.awsData.uploadPhysiologicalData(vitalsValue: uploadLocation)
                                       })
                    RunLoop.current.add(self.timer, forMode: .default)
                }
                self.userDefaultsVitals.setValue("Start", forKey: "Check Pressed")
            }
            //            retrieve physiological and location data from the apple watch and upload it in the background if the user requested to do so
        }
    }
}

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
    @IBOutlet var uploadingLabel: UILabel!
    @IBOutlet var uploadingProgress: UIActivityIndicatorView!
    
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
    
    func uploadXYZArray(xyzArray: [Double]) {
        let secretKey = userDefaultsVitals.string(forKey: "Random Key")!
        let finalData = "\(returnFinalTimeStamp()),xyz_acc:\(xyzArray[0]) \(xyzArray[1]) \(xyzArray[2])\n"
        // create final data string with heartbeat value and timestamp
        var biometricInputArray: [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        // retrieve biometric array from app storage (NSUserDefaults) to append final data
        biometricInputArray.append(finalData)
        // append final data to biometric array
        userDefaultsVitals.setValue(biometricInputArray, forKey: "Vitals Array6")
        // put new biometric array back into iPhone storage
        let newArray : [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as! [String]
        // retrieve biometric array once again in order to pass it on to AWS
        let finalArray = newArray.joined(separator: " ")
        // join array values with commas
        let XYZData = finalArray.data(using: .utf8)!
        // transform finalArray into Data datatype to allow for AWS uploading
        //        let storageOperation = Amplify.Storage.uploadData(key: userName, data: XYZData)
        let storageOperation = Amplify.Storage.uploadData(key: "\(secretKey)", data: XYZData)
        //upload new biometric array to AWS S3 bucket
        progressSink = storageOperation
            .progressPublisher
            .sink { progress in print("Progress: \(progress)") }
        // monitor upload progress
        uploadingLabel.isHidden = false
        uploadingProgress.startAnimating()
        resultSink = storageOperation
            .resultPublisher
            .sink {
                if case let .failure(storageError) = $0 {
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                    // check for upload errors
                }
            }
            receiveValue: { data in
                print("Completed: \(data)")
                // check for upload completion
                self.uploadingLabel.isHidden = true
                self.uploadingProgress.stopAnimating()
            }
    }
    
    func uploadResultantAccel(resultantAccel: Double) {
        let secretKey = userDefaultsVitals.string(forKey: "Random Key")!
        let finalData = "\(returnFinalTimeStamp()),resultant_acc:\(resultantAccel)\n"
        // create final data string with heartbeat value and timestamp
        var biometricInputArray: [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        // retrieve biometric array from app storage (NSUserDefaults) to append final data
        biometricInputArray.append(finalData)
        // append final data to biometric array
        userDefaultsVitals.setValue(biometricInputArray, forKey: "Vitals Array6")
        // put new biometric array back into iPhone storage
        let newArray : [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as! [String]
        // retrieve biometric array once again in order to pass it on to AWS
        let finalArray = newArray.joined(separator: " ")
        // join array values with commas
        let XYZData = finalArray.data(using: .utf8)!
        // transform finalArray into Data datatype to allow for AWS uploading
        //        let storageOperation = Amplify.Storage.uploadData(key: userName, data: XYZData)
        let storageOperation = Amplify.Storage.uploadData(key: "\(secretKey)", data: XYZData)
        //upload new biometric array to AWS S3 bucket
        progressSink = storageOperation
            .progressPublisher
            .sink { progress in print("Progress: \(progress)") }
        // monitor upload progress
        uploadingLabel.isHidden = false
        uploadingProgress.startAnimating()
        resultSink = storageOperation
            .resultPublisher
            .sink {
                if case let .failure(storageError) = $0 {
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                    // check for upload errors
                }
            }
            receiveValue: { data in
                print("Completed: \(data)")
                // check for upload completion
                self.uploadingLabel.isHidden = true
                self.uploadingProgress.stopAnimating()
                
            }
    }
    
    func returnFinalTimeStamp() -> String {
        let timeStamp = ViewController.getDateOnly(fromTimeStamp: 0.0)
        //    set variable to return timestamp variable
        var currentTime: Double
        currentTime = CACurrentMediaTime()
        let truncatedMilliseconds = currentTime.truncatingRemainder(dividingBy: 1)
        let finalMilliseconds = Int(truncatedMilliseconds * 1000)
        let finalTimeStamp = "\(timeStamp)\(finalMilliseconds)"
        return(finalTimeStamp)
        //        get timestamp from ViewController.swift
    }
    @IBAction func xyzButton(_ sender: Any) {
        if xyzSwitch.isOn{
            self.userDefaultsVitals.setValue("ON", forKey: "XYZ Switch")
            
        }
        else{
            self.userDefaultsVitals.setValue("OFF", forKey: "XYZ Switch")
            self.uploadingLabel.isHidden = true
            self.uploadingProgress.stopAnimating()
        }
        //        change state of xyz upload switch if state was changed by user
    }
    @IBAction func resultantButton(_ sender: Any) {
        if resultantSwitch.isOn{
            self.userDefaultsVitals.setValue("ON", forKey: "Resultant Switch")
        }
        else{
            self.userDefaultsVitals.setValue("OFF", forKey: "Resultant Switch")
            self.uploadingLabel.isHidden = true
            self.uploadingProgress.stopAnimating()
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
            //            run all processes below in the main thread
            if let xyzArray = message["Array"] as? [Double] {
                self.xLabel.text = ("\(xyzArray[0])")
                self.yLabel.text = ("\(xyzArray[1])")
                self.zLabel.text = ("\(xyzArray[2])")
                //                retrieve xyz acceleration values from apple watch
                if self.xyzSwitch.isOn {
                    self.uploadXYZArray(xyzArray: xyzArray)
                }
                else{
                }
                //                upload xyz values if enabled
            }
            if let resultantXYZ = message["Resultant"] as? Double {
                let resultantRound = Double(round(1000*resultantXYZ)/1000)
                self.resultantLabel.text = ("\(resultantRound)")
                //                retrieve resultant acceleration value from apple watch
                if self.resultantSwitch.isOn {
                    self.uploadResultantAccel(resultantAccel: resultantRound)
                }
                else{
                }
                //                upload resultant values if enabled
            }
            if (message["Stop Pressed"] as? String) != nil {
                self.timer.invalidate()
                self.xLabel.text = "--"
                self.yLabel.text = "--"
                self.zLabel.text = "--"
                self.resultantLabel.text = "--"
                self.userDefaultsVitals.setValue("Stop", forKey: "Check Pressed")
                //                clear interface if user stopped monitoring on the apple watch
            }
        }
        DispatchQueue.main.async {
            let dataSwitchCheck = self.userDefaultsVitals.string(forKey: "Data Switch")
            //            retrieve state of ViewController.swift's data switch
            let viewController = ViewController()
            if let heartRate = message["hr"] as? String {
                let heartRateMessage = ("heart_rate:\(heartRate)")
                if dataSwitchCheck == "ON" {
                    viewController.uploadHeartBeatData(HRValue: heartRateMessage)
                }
            }
            
            if let SPO2 = message["spo2"] as? String {
                let spo2Message = ("blood_o2:\(SPO2)")
                if dataSwitchCheck == "ON"{
                    viewController.uploadSPO2Data(SPO2Value: spo2Message)
                }
            }
            
            if let noiseExpos = message["NoiseEx"] as? String {
                let longTermNEMessage = ("noise:\(noiseExpos)")
                if dataSwitchCheck == "ON"{
                    viewController.uploadLTNEData(LTNEValue: longTermNEMessage)
                }
            }
            
            if let sleepTime = message["SleepTime"] as? Double {
                let sleepMessage = ("sleep:\(sleepTime)")
                HealthDataManager.sharedInstance.retrieveSleep { result -> Void in
                    DispatchQueue.main.async {
                    }
                }
                if dataSwitchCheck == "ON"{
                    viewController.uploadSleepData(sleepValue: sleepMessage)
                }
            }
            if (message["Start Pressed"] as? String) != nil {
                if dataSwitchCheck == "ON" {
                    self.timer = Timer(fire: Date(), interval: (120.0/1.0),
                                       repeats: true, block: { (timer) in
                                        viewController.uploadLocationData()
                                       })
                    RunLoop.current.add(self.timer, forMode: .default)
                }
                self.userDefaultsVitals.setValue("Start", forKey: "Check Pressed")
            }
            //            retrieve physiological and location data from the apple watch and upload it in the background if the user requested to do so
        }
    }
}

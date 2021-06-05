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
    @IBOutlet var yLabel: UILabel!
    @IBOutlet var zLabel: UILabel!
    @IBOutlet var resultantLabel: UILabel!
    @IBOutlet weak var xyzSwitch: UISwitch!
    @IBOutlet weak var resultantSwitch: UISwitch!
    
    var session: WCSession?
    var biometricArray : [String] = []
    var resultSink: AnyCancellable?
//    initiate variable to signify result has been published to AWS
    var progressSink: AnyCancellable?
//    initiate variable to display uploading progress for upload to AWS
    let userDefaultsVitals = UserDefaults.standard
    var monitorXYZ = false
    var buttonCheck = false
    var monitorResultant = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureWatchKitSession()
    }
    
    func configureWatchKitSession(){
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }

    func uploadXYZArray(xyzArray: [Double]) {
        let secretKey = userDefaultsVitals.string(forKey: "Random Key")!
        let finalData = "\(returnFinalTimeStamp()),5,\(xyzArray[0]),\(xyzArray[1]),\(xyzArray[2])\n"
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
            }
    }
    
    func uploadResultantAccel(resultantAccel: Double) {
        let secretKey = userDefaultsVitals.string(forKey: "Random Key")!
        let finalData = "\(returnFinalTimeStamp()),5,\(resultantAccel)\n"
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
    }
    @IBAction func xyzButton(_ sender: Any) {
        if xyzSwitch.isOn{
            
        }
        else{
            
        }
    }
    @IBAction func resultantButton(_ sender: Any) {
        if resultantSwitch.isOn{
            
        }
        else{
            
        }
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
            if let xyzArray = message["Array"] as? [Double] {
                self.xLabel.text = ("\(xyzArray[0])")
                self.yLabel.text = ("\(xyzArray[1])")
                self.zLabel.text = ("\(xyzArray[2])")
                if self.xyzSwitch.isOn {
                    self.uploadXYZArray(xyzArray: xyzArray)
                }
                else{
                    print("NO UPLOADING XYZ")
                }
            }
            if let resultantXYZ = message["Resultant"] as? Double {
                let resultantRound = Double(round(1000*resultantXYZ)/1000)
                self.resultantLabel.text = ("\(resultantRound)")
                if self.resultantSwitch.isOn {
                self.uploadResultantAccel(resultantAccel: resultantRound)
                }
                else{
                    print("NO UPLOADING RESULTANT")
                }
            }
            if (message["Stop Pressed"] as? String) != nil {
                self.xLabel.text = "--"
                self.yLabel.text = "--"
                self.zLabel.text = "--"
                self.resultantLabel.text = "--"
            }
    }
}
}


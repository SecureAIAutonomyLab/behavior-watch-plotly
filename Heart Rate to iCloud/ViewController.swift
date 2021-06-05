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
import Amplify
import AmplifyPlugins
import Combine
import BackgroundTasks
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet var heartBeatiOS: UILabel!
//    set up heart beat label variable
    @IBOutlet var SPO2iOS: UILabel!
//    set up SPO2 label variable
    @IBOutlet var avgLongTermNE: UILabel!
//    set up long term noise label variable
    @IBOutlet var publishButton: UIButton!
//    set up refresh/publish button variable
    @IBOutlet var hoursSleptLabel: UILabel!
//    set up sleep label variable
    @IBOutlet var fullNameLabel: UILabel!
//    set up full name label variable
    @IBOutlet var appleIDLabel: UILabel!
//    set up apple ID label variable
    @IBOutlet var authButton: UIButton!
//    set up health data authorization button variable
    @IBOutlet var longitudeLatitudeLabel: UILabel!
//    set up long. and lat. label
    @IBOutlet weak var dataSwitch: UISwitch!
//    create AWS data sending switch
    @IBOutlet weak var hiddenUserButton: UIButton!
    @IBOutlet var userLabel: UILabel!
    let session2 = WCSession.default
//    set up second watch session variable
    var session: WCSession?
//    set up first watch session variable
    var clientId = "0000"
//    create dummy client variable to initiate clientID function later on
    let userDefaultsVitals = UserDefaults.standard
//    Access Shared Defaults Object
    var biometricArray : [String] = []
    // In your type's instance variables
    var resultSink: AnyCancellable?
//    initiate variable to signify result has been published to AWS
    var progressSink: AnyCancellable?
//    initiate variable to display uploading progress for upload to AWS
    var userName: String!
//    set up user name variable
    var appleID: String!
//    set up Apple ID variable
    var fullName: String!
//    set up full name variable

    override func viewDidLoad() {
        super.viewDidLoad()
//    Do any additional setup after loading the view.
        self.configureWatchKitSession()
//    Begin watch session
        hiddenUserButton.setTitle(userName, for: .normal)
//    set user name as user name from Apple ID sign
        fullNameLabel.text = fullName
//    set full name label as name from Apple ID sign in
        appleIDLabel.text = appleID
//    set full name label as
        let email2 = userDefaultsVitals.string(forKey: "Email")!
//     retrieve email from internal storage
        let fnValue2 = userDefaultsVitals.string(forKey: "Full Name")!
//     retrieve full name from internal storage
        let userName2 = email2.components(separatedBy: "@")[0]
//     make user name from apple ID
        hiddenUserButton.setTitle(userName2, for: .normal)
//     redefine user name label value
        appleIDLabel.text = email2
//     redefine apple ID label value
        fullNameLabel.text = fnValue2
//     redefine full name label value
        authButton.layer.cornerRadius = 10
//        curve authorization button corners with 10 pixel radius
        authButton.clipsToBounds = true
        AWSManagement.awsManagement.awsSetup()
        AWSManagement.awsManagement.getAWSClientId { (clientId, Error) in
//            print(clientId!)
        }
        AWSManagement.awsManagement.connectToAWSIoT(clientId: clientId)
        AWSManagement.awsManagement.registerSubscription()
        let biometricInputArray: [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        if biometricInputArray == [] {
            userDefaultsVitals.setValue(biometricArray, forKey: "Vitals Array6")
        }
    }

    func configureWatchKitSession(){
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    @IBAction func closeKeyboardPressed(_ sender: Any){
        let email2 = userDefaultsVitals.string(forKey: "Email")!
        let userName2 = email2.components(separatedBy: "@")[0]
        let data: [String: Any] = ["Name Label":"\(userName2)" as Any]
        self.session!.sendMessage(data, replyHandler: nil, errorHandler: nil)
    }
    
    @IBAction func publishButtonPressed(_ sender: UIButton) {
        AWSManagement.awsManagement.publishMessage(message: "hello", topic: "topicInitial")
        HealthDataManager.sharedInstance.retrieveSleep { result -> Void in
            DispatchQueue.main.async {
                let timeSlept = String(Int(result / 3600)) + "h " +
                String(Int(result.truncatingRemainder(dividingBy: 3600) / 60)) + "m " +
                String(Int(result.truncatingRemainder(dividingBy: 3600)
                            .truncatingRemainder(dividingBy: 60))) + "s"
//                self.hoursSleptLabel.text = String(timeSlept)
                }
//            print(self.returnFinalTimeStamp())
            }
        HealthDataManager.sharedInstance.retrieveSleepWithAuth() { result -> Void in DispatchQueue.main.async {
            print("authorization for sleep requested")
        }
        }
        HealthDataManager.sharedInstance.requestAuthorization { (success) in
            DispatchQueue.main.async {
                let message = success ? "Authorized health data access." : "Failed to authorize health data access."
                let alertController = UIAlertController(title: "Health Data", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
        HealthDataManager.sharedInstance.requestLocationAuthorization()
//        var biometricInputArray: [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
//        print("\(biometricInputArray.count) count")
//        biometricInputArray.removeLast()
//        userDefaultsVitals.set(biometricInputArray, forKey: "Vitals Array6")
        }
    
    @IBAction func toECGData(_ sender: Any) {
        performSegue(withIdentifier: "toECGData", sender: self)
    }
    
    class func getDateOnly(fromTimeStamp timestamp: TimeInterval) -> String {
      let dayTimePeriodFormatter = DateFormatter()
      dayTimePeriodFormatter.timeZone = TimeZone.current
      dayTimePeriodFormatter.dateFormat = "zMMMM/dd/yyyy HH:mm:ss:"
      return dayTimePeriodFormatter.string(from: Date(timeIntervalSinceNow: timestamp))
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
    
    func uploadHeartBeatData(HRValue: String) {
//        uploadLocationData()
        // upload location data at same intervals as Heart Beat Data
        let email2 = userDefaultsVitals.string(forKey: "Email")!
        let userName2 = email2.components(separatedBy: "@")[0]
        let secretKey = userDefaultsVitals.string(forKey: "Random Key")!
        let data: [String: Any] = ["Name Label":"\(userName2)" as Any]
        // transform Username into Data datatype [String: Any]
        self.session!.sendMessage(data, replyHandler: nil, errorHandler: nil)
        // send username to apple watch to update value
        let finalData = "\(returnFinalTimeStamp()),\(HRValue)\n"
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
        let HRData = finalArray.data(using: .utf8)!
        // transform finalArray into Data datatype to allow for AWS uploading
//        let storageOperation = Amplify.Storage.uploadData(key: userName, data: HRData)
        let storageOperation = Amplify.Storage.uploadData(key: "\(secretKey)", data: HRData)
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
    
    func uploadSPO2Data(SPO2Value: String) {
        let secretKey = userDefaultsVitals.string(forKey: "Random Key")!
        let finalData = "\(returnFinalTimeStamp()),\(SPO2Value)\n"
        var biometricInputArray: [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        biometricInputArray.append(finalData)
        userDefaultsVitals.set(biometricInputArray, forKey: "Vitals Array6")
        let newArray : [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        let finalArray = newArray.joined(separator: " ")
        let SPO2Data = finalArray.data(using: .utf8)!
//        let storageOperation = Amplify.Storage.uploadData(key: userName, data: SPO2Data)
        let storageOperation = Amplify.Storage.uploadData(key: "\(secretKey)", data: SPO2Data)
        progressSink = storageOperation
            .progressPublisher
            .sink { progress in print("Progress: \(progress)") }

        resultSink = storageOperation
            .resultPublisher
            .sink {
                if case let .failure(storageError) = $0 {
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                }
            }
            receiveValue: { data in
                print("Completed: \(data)")
            }
    }
    func uploadLTNEData(LTNEValue: String) {
        let secretKey = userDefaultsVitals.string(forKey: "Random Key")!
        let finalData = "\(returnFinalTimeStamp()),\(LTNEValue)\n"
        var biometricInputArray: [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        biometricInputArray.append(finalData)
        userDefaultsVitals.set(biometricInputArray, forKey: "Vitals Array6")
        let newArray : [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        let finalArray = newArray.joined(separator: " ")
        let LTNEData = finalArray.data(using: .utf8)!
//        let storageOperation = Amplify.Storage.uploadData(key: userName, data: LTNEData)
        let storageOperation = Amplify.Storage.uploadData(key: "\(secretKey)", data: LTNEData)
        progressSink = storageOperation
            .progressPublisher
            .sink { progress in print("Progress: \(progress)") }

        resultSink = storageOperation
            .resultPublisher
            .sink {
                if case let .failure(storageError) = $0 {
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                }
            }
            receiveValue: { data in
                print("Completed: \(data)")
            }
    }
    
    func uploadSleepData(sleepValue: String) {
        let secretKey = userDefaultsVitals.string(forKey: "Random Key")!
        let finalData = "\(returnFinalTimeStamp()),\(sleepValue)\n"
        var biometricInputArray: [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        biometricInputArray.append(finalData)
        userDefaultsVitals.set(biometricInputArray, forKey: "Vitals Array6")
        let newArray : [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        let finalArray = newArray.joined(separator: " ")
        let sleepData = finalArray.data(using: .utf8)!
//        let storageOperation = Amplify.Storage.uploadData(key: userName, data: sleepData)
        let storageOperation = Amplify.Storage.uploadData(key: "\(secretKey)", data: sleepData)
        progressSink = storageOperation
            .progressPublisher
            .sink { progress in print("Progress: \(progress)") }

        resultSink = storageOperation
            .resultPublisher
            .sink {
                if case let .failure(storageError) = $0 {
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                }
            }
            receiveValue: { data in
                print("Completed: \(data)")
            }
    }
    
    func uploadLocationData(){
        let secretKey = userDefaultsVitals.string(forKey: "Random Key")!
        longitudeLatitudeLabel.text =         HealthDataManager.sharedInstance.requestLocationAuthorization()
        let longitude = HealthDataManager.sharedInstance.requestLongitude()
        let latitude = HealthDataManager.sharedInstance.requestLatitude()
        let finalLocationData = ("\(returnFinalTimeStamp()),4,\(latitude),\(longitude)\n")
        var biometricInputArray: [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        biometricInputArray.append(finalLocationData)
        userDefaultsVitals.set(biometricInputArray, forKey: "Vitals Array6")
        let newArray : [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        let finalArray = newArray.joined(separator: " ")
        let locationData = finalArray.data(using: .utf8)!
//        let storageOperation = Amplify.Storage.uploadData(key: userName, data: locationData)
        let storageOperation = Amplify.Storage.uploadData(key: "\(secretKey)", data: locationData)
        progressSink = storageOperation
            .progressPublisher
            .sink { progress in print("Progress: \(progress)") }

        resultSink = storageOperation
            .resultPublisher
            .sink {
                if case let .failure(storageError) = $0 {
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                }
            }
            receiveValue: { data in
                print("Completed: \(data)")
            }

        let dataLO: [String: Any] = ["Longitude": longitude as Any]
        self.session!.sendMessage(dataLO, replyHandler: nil, errorHandler: nil)
        let dataLA: [String: Any] = ["Latitude": latitude as Any]
        self.session!.sendMessage(dataLA, replyHandler: nil, errorHandler: nil)
    }
    
    func uploadXYZArray(resultantXYZ: Double) {
        let secretKey = userDefaultsVitals.string(forKey: "Random Key")!
//        let finalData = "\(returnFinalTimeStamp()),\(userName),5,\(xyzArray[0]),\(xyzArray[1]),\(xyzArray[2])"
        let finalData = "\(returnFinalTimeStamp()),5,\(resultantXYZ)\n"
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
    
    @IBAction func goToAcclerometer(_ sender: Any) {
        
    }
    @IBAction func toggleIdentifier(_ sender: UIButton) {
        sender.isSelected.toggle()
        let email2 = userDefaultsVitals.string(forKey: "Email")!
        let userName2 = email2.components(separatedBy: "@")[0]
        let randomKey = userDefaultsVitals.string(forKey: "Random Key")
//        let buttonLabel = "\(sender.titleLabel!)"
        sender.setTitle(userName2, for: .normal)
        sender.setTitle(randomKey, for: .selected)
//        if buttonLabel != userName2 {
//            userLabel.text = "Secret Key:"
//        }
//        if buttonLabel == userName2 {
//            userLabel.text = "User:"
//        }
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
        
        DispatchQueue.main.async {
            if let heartRate = message["hr"] as? String {
                self.heartBeatiOS.text = ("\(heartRate) BPM")
//                let heartRateMessage = ("\(self.userNameLabel.text!),0,\(heartRate)")
                let heartRateMessage = ("0,\(heartRate)")
                AWSManagement.awsManagement.publishMessage(message: heartRateMessage, topic: "topicInitial")
                if self.dataSwitch.isOn{
                self.uploadHeartBeatData(HRValue: heartRateMessage)
                }
            }
            
            if let SPO2 = message["spo2"] as? String {
                self.SPO2iOS.text = ("\(SPO2)%")
//                let spo2Message = ("\(self.userNameLabel.text!),1,\(SPO2)")
                let spo2Message = ("1,\(SPO2)")
                AWSManagement.awsManagement.publishMessage(message: spo2Message, topic: "topicInitial")
                if self.dataSwitch.isOn{
                self.uploadSPO2Data(SPO2Value: spo2Message)
                }
            }
            
            if let noiseExpos = message["NoiseEx"] as? String {
                self.avgLongTermNE.text = ("\(noiseExpos) dB")
//                let longTermNEMessage = ("\(self.userNameLabel.text!),2,\(noiseExpos)")
                let longTermNEMessage = ("2,\(noiseExpos)")
                AWSManagement.awsManagement.publishMessage(message: longTermNEMessage, topic: "topicInitial")
                if self.dataSwitch.isOn{
                self.uploadLTNEData(LTNEValue: longTermNEMessage)
                }
            }
            
            if let sleepTime = message["SleepTime"] as? Double {
                let sleepMessage = ("3,\(sleepTime)")
                AWSManagement.awsManagement.publishMessage(message: sleepMessage, topic: "topicInitial")
                HealthDataManager.sharedInstance.retrieveSleep { result -> Void in
                    DispatchQueue.main.async {
                        let timeSlept = String(Int(result / 3600)) + "h " +
                        String(Int(result.truncatingRemainder(dividingBy: 3600) / 60)) + "m " +
                        String(Int(result.truncatingRemainder(dividingBy: 3600)
                                    .truncatingRemainder(dividingBy: 60))) + "s"
                        self.hoursSleptLabel.text = String(timeSlept)
                    }
                }
                if self.dataSwitch.isOn{
                self.uploadSleepData(sleepValue: sleepMessage)
                }
            }
//
//            if let resultantXYZ = message["Resultant"] as? Double {
//                let resultantRound = Double(round(1000*resultantXYZ)/1000)
//                self.accelerationLabel.text = ("\(resultantRound)")
//                self.uploadXYZArray(resultantXYZ: resultantRound)
//
//            }
            
                    if (message["Start Pressed"] as? String) != nil {
                        self.longitudeLatitudeLabel.text =         HealthDataManager.sharedInstance.requestLocationAuthorization()
                    }
            
                    if (message["Stop Pressed"] as? String) != nil {
                        self.heartBeatiOS.text = "--"
                        self.SPO2iOS.text = "--"
                        self.avgLongTermNE.text = "--"
                        self.hoursSleptLabel.text = "--"
                        self.longitudeLatitudeLabel.text = "--,--"
//                        self.accelerationLabel.text = "--"
                    }
            
        if let IDScreenCheck = message["Watch Display Activated"] as? String {
            
            if IDScreenCheck == "Activated"{
                let data: [String : Any]  = ["Load Main Watch Screen" : "Activate Screen" as Any]
                self.session?.sendMessage(data, replyHandler: nil, errorHandler: nil)
                }
            }
        }
    }
}



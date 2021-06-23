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
import GoogleSignIn
import NotificationCenter

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
    //    create button to reveal secret ID key
    @IBOutlet var userLabel: UILabel!
    //    create label to display User Name
    @IBOutlet var userGuideButton: UIButton!
    //    create button to allow user to navigate to user guide
    @IBOutlet var accelerationButton: UIButton!
    //    create button to allow user to navigate to acceleration data page
    @IBOutlet var refreshUserNameButton: UIButton!
    //    create a button to update the user name on the apple watch
    @IBOutlet var signOutButton: UIButton!
    //    create a button to sign out of Cloud Vitals
    @IBOutlet var uploadProgress: UIActivityIndicatorView!
    @IBOutlet var uploadingLabel: UILabel!
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
    var timer = Timer.init()
    //    create a timer for uploading location data at specified intervals
    var timer2 = Timer.init()
    //    create another timer for checking the state of the uploading switches
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //    Do any additional setup after loading the view.
        hiddenUserButton.setTitle(appleSignInCheck()[2], for: .normal)
        //     redefine user name label value
        appleIDLabel.text = appleSignInCheck()[0]
        //     redefine apple ID label value
        fullNameLabel.text = appleSignInCheck()[1]
        let biometricInputArray: [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        //        access app's data array
        authButton.layer.cornerRadius = 10
        //        curve authorization button corners with 10 pixel radius
        userGuideButton.layer.cornerRadius = 13
        //        curve user guide button corners with 13 pixel radius
        accelerationButton.layer.cornerRadius = 13
        //        curve acceleration page button corners with 13 pixel radius
        refreshUserNameButton.layer.cornerRadius = 10
        //        curve refresh user name button corners with 10 pixel radius
        signOutButton.layer.cornerRadius = 13
        //        curve sign out button corners with 13 pixel radius
        authButton.clipsToBounds = true
        //        make authorization button confined to subview
        if biometricInputArray == [] {
            userDefaultsVitals.setValue(biometricArray, forKey: "Vitals Array6")
        }
        //        check if the biometric array is empty and initialize it if it is
        dataSwitchCheck()
        //        check what state the switch should be in
        switchCheck()
        //        check what state apple watch swithces shoudl be in
        configureWatchKitSession()
        //    call watch session function
    }
    
    func configureWatchKitSession(){
        if WCSession.isSupported() {
            //            check if apple watch sessions are supported
            session = WCSession.default
            //            create variable and set it to default watch session config.
            session?.delegate = self
            session?.activate()
            //            begin session
        }
    }
    
    @IBAction func closeKeyboardPressed(_ sender: Any){
        let userName2 = appleSignInCheck()[2]
        //        retrieve username from internal storage
        let data: [String: Any] = ["Name Label":"\(userName2)" as Any]
        //        convert it to sendable data
        self.session!.sendMessage(data, replyHandler: nil, errorHandler: nil)
        //        send data to apple watch to refresh username
    }
    
    @IBAction func publishButtonPressed(_ sender: UIButton) {
        HealthDataManager.sharedInstance.retrieveSleepWithAuth() { result -> Void in DispatchQueue.main.async {
            print("authorization for sleep requested")
        }
        //        retrieve if authorized.
        }
        HealthDataManager.sharedInstance.requestAuthorization { (success) in
            DispatchQueue.main.async {
                let message = success ? "Authorized health data access." : "Failed to authorize health data access."
                let alertController = UIAlertController(title: "Health Data", message: message, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
            //            request authorization for sleep data
        }
        HealthDataManager.sharedInstance.requestLocationAuthorization()
        //        request authorization for location data
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        }
        //        initalize notification services and create notification with specific attributes
        
    }
    
    class func getDateOnly(fromTimeStamp timestamp: TimeInterval) -> String {
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.timeZone = TimeZone.current
        dayTimePeriodFormatter.dateFormat = "zMMMM/dd/yyyy HH:mm:ss:"
        return dayTimePeriodFormatter.string(from: Date(timeIntervalSinceNow: timestamp))
        //        get the current data and time with a specificied format
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
        //        get the milliseconds to add to the timestamp
    }
    
    func uploadHeartBeatData(HRValue: String) {
        let secretKey = userDefaultsVitals.string(forKey: "Random Key")!
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
        uploadingLabel.isHidden = false
        uploadProgress.startAnimating()
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
                self.uploadProgress.stopAnimating()
            }
    }
    
    func uploadSPO2Data(SPO2Value: String) {
        let secretKey = userDefaultsVitals.string(forKey: "Random Key")!
        //        retrieve secret key from internal storage
        let finalData = "\(returnFinalTimeStamp()),\(SPO2Value)\n"
        //        create string with timestamp and SPO2 value combined
        var biometricInputArray: [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        //        retrieve internally stored array of data
        biometricInputArray.append(finalData)
        //        add new collected data to the array
        userDefaultsVitals.set(biometricInputArray, forKey: "Vitals Array6")
        //        push the array back into the internal storage appending the old array
        let newArray : [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        //        retrieve updated array
        let finalArray = newArray.joined(separator: " ")
        //        separate array values with a "space" making it a CSV
        let SPO2Data = finalArray.data(using: .utf8)!
        //        convert CSV string into uploadable data
        let storageOperation = Amplify.Storage.uploadData(key: "\(secretKey)", data: SPO2Data)
        //        create uploading variable
        progressSink = storageOperation
            .progressPublisher
            .sink { progress in print("Progress: \(progress)") }
        //        monitor progress of upload
        uploadingLabel.isHidden = false
        uploadProgress.startAnimating()
        resultSink = storageOperation
            .resultPublisher
            .sink {
                if case let .failure(storageError) = $0 {
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                }
                //                handle any uploading errors
            }
            receiveValue: { data in
                print("Completed: \(data)")
                self.uploadingLabel.isHidden = true
                self.uploadProgress.stopAnimating()
            }
        //          runs when the upload is complete
    }
    
    func uploadLTNEData(LTNEValue: String) {
        let secretKey = userDefaultsVitals.string(forKey: "Random Key")!
        //        retrieve secret key from internal storage
        let finalData = "\(returnFinalTimeStamp()),\(LTNEValue)\n"
        //        create string with timestamp and long term noise exposure value combined
        var biometricInputArray: [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        biometricInputArray.append(finalData)
        //        retrieve internally stored data array and append it with new data
        userDefaultsVitals.set(biometricInputArray, forKey: "Vitals Array6")
        //        store updated array
        let newArray : [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        //        retrieve internally stored array
        let finalArray = newArray.joined(separator: " ")
        //        separate array values with a space making a CSV string
        let LTNEData = finalArray.data(using: .utf8)!
        //        configure string to be uploadable data
        let storageOperation = Amplify.Storage.uploadData(key: "\(secretKey)", data: LTNEData)
        //        create upload variable
        progressSink = storageOperation
            .progressPublisher
            .sink { progress in print("Progress: \(progress)") }
        //        monitor uploading progress
        uploadingLabel.isHidden = false
        uploadProgress.startAnimating()
        resultSink = storageOperation
            .resultPublisher
            .sink {
                if case let .failure(storageError) = $0 {
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                }
            }
            //            handle any errors while uploading
            receiveValue: { data in
                print("Completed: \(data)")
                self.uploadingLabel.isHidden = true
                self.uploadProgress.stopAnimating()
            }
        //        runs when the upload is complete
    }
    
    func uploadSleepData(sleepValue: String) {
        let secretKey = userDefaultsVitals.string(forKey: "Random Key")!
        //        retrieve stored secret key
        let finalData = "\(returnFinalTimeStamp()),\(sleepValue)\n"
        //        add timestamp to sleep value
        var biometricInputArray: [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        biometricInputArray.append(finalData)
        //        retrieve and append stored data array
        userDefaultsVitals.set(biometricInputArray, forKey: "Vitals Array6")
        //        store updated array
        let newArray : [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
        //        retrieve updated array
        let finalArray = newArray.joined(separator: " ")
        //        turn array into CSV
        let sleepData = finalArray.data(using: .utf8)!
        //        turn CSV into uploadable data
        let storageOperation = Amplify.Storage.uploadData(key: "\(secretKey)", data: sleepData)
        //        upload variable
        progressSink = storageOperation
            .progressPublisher
            .sink { progress in print("Progress: \(progress)") }
        //        monitor progress of upload
        uploadingLabel.isHidden = false
        uploadProgress.startAnimating()
        resultSink = storageOperation
            .resultPublisher
            .sink {
                if case let .failure(storageError) = $0 {
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                }
            }
            //            handle any uploading errors
            receiveValue: { data in
                print("Completed: \(data)")
                self.uploadingLabel.isHidden = true
                self.uploadProgress.stopAnimating()
            }
        //        run when upload is complete
    }
    
    func uploadLocationData() -> String{
        if dataSwitch.isOn{
            //            check if uploading is enabled
            let secretKey = userDefaultsVitals.string(forKey: "Random Key")!
            //            retrieve secret key
            let longitude = HealthDataManager.sharedInstance.requestLongitude()
            //            get longitude from HealthDataManager
            let latitude = HealthDataManager.sharedInstance.requestLatitude()
            //            get latitude from HealthDataManager
            let finalLocationData = ("\(returnFinalTimeStamp()),location:\(latitude) \(longitude)\n")
            //            add timestamp to location
            var biometricInputArray: [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
            biometricInputArray.append(finalLocationData)
            //            retrieve and append stored array
            userDefaultsVitals.set(biometricInputArray, forKey: "Vitals Array6")
            //            update array
            let newArray : [String] = userDefaultsVitals.object(forKey: "Vitals Array6") as? [String] ?? []
            //            retrieve updated array
            let finalArray = newArray.joined(separator: " ")
            //            turn into CSV
            let locationData = finalArray.data(using: .utf8)!
            //            turn CSV into uploadable data
            let storageOperation = Amplify.Storage.uploadData(key: "\(secretKey)", data: locationData)
            //            upload variable
            progressSink = storageOperation
                .progressPublisher
                .sink { progress in print("Progress: \(progress)") }
            //            monitor uploading progress
            uploadingLabel.isHidden = false
            uploadProgress.startAnimating()
            resultSink = storageOperation
                .resultPublisher
                .sink {
                    if case let .failure(storageError) = $0 {
                        print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                    }
                    //                    handle any uploading errors
                }
                receiveValue: { data in
                    print("Completed: \(data)")
                    self.uploadingLabel.isHidden = true
                    self.uploadProgress.stopAnimating()
                }
            //            run when upload is complete
        }
        return HealthDataManager.sharedInstance.requestLocationAuthorization()
        //        return location values
    }
    
    func dataSwitchCheck() {
        let dataSwitchCheck = userDefaultsVitals.string(forKey: "Data Switch")
        //        retrieve state of data switch
        if dataSwitchCheck == "ON" {
            dataSwitch.setOn(true, animated: true)
            //        if state is on turn switch on
        }
        else if dataSwitchCheck == "OFF" {
            dataSwitch.setOn(false, animated: true)
            //        if state is off turn switch off
        }
    }
    
    func appleSignInCheck() -> [String]{
        let appleSignInCheck = userDefaultsVitals.string(forKey: "Apple Sign In")!
        //        check if user signed in with apple ID
        if appleSignInCheck == "False"{
            let email2 = userDefaultsVitals.string(forKey: "Email")!
            //     retrieve email from internal storage
            ////        let email2 = "-------@gmail.com"
            //        ^^^ dummy email for testing
            let fnValue2 = userDefaultsVitals.string(forKey: "Full Name")!
            //     retrieve full name from internal storage
            ////        let fnValue2 = "first last"
            //        ^^^ dummy name for testing
            let userName2 = email2.components(separatedBy: "@")[0]
            //     make user name from login email
            ////        let userName2 = "-------"
            //     dummy user name for testing
            return [email2, fnValue2, userName2]
            //            return array of user authentication variables
        }
        if appleSignInCheck == "True"{
            let email2 = userDefaultsVitals.string(forKey: "Email Apple")!
            //     retrieve apple ID email from internal storage
            ////        let email2 = "-------@gmail.com"
            //        ^^^ dummy email for testing
            let fnValue2 = userDefaultsVitals.string(forKey: "Full Name Apple")!
            //     retrieve apple ID full name from internal storage
            ////        let fnValue2 = "first last"
            //        ^^^ dummy name for testing
            let userName2 = email2.components(separatedBy: "@")[0]
            //     make user name from apple ID
            ////        let userName2 = "-------"
            //     dummy user name for testing
            return [email2, fnValue2, userName2]
            //            return array of user authentication variables
        }
        return ["", "", ""]
        //        if none of the conditions are met return nil
    }
    
    func switchCheck() {
        self.timer = Timer(fire: Date(), interval: (1.0/5.0),
                           repeats: true, block: { (timer) in
                            //                            run timer at 5Hz checking for state of switches
                            let dataSwitchCheck = self.userDefaultsVitals.string(forKey: "Data Switch")
                            let xyzSwitchCheck = self.userDefaultsVitals.string(forKey: "XYZ Switch")
                            let resultantSwitchCheck = self.userDefaultsVitals.string(forKey: "Resultant Switch")
                            //                            retrieve the state of all three switches
                            if dataSwitchCheck == "ON" {
                                let dataSwitch: [String: Any] = ["Data Switch Check": "ON" as Any]
                                self.session!.sendMessage(dataSwitch, replyHandler: nil, errorHandler: nil)
                            }
                            if dataSwitchCheck == "OFF" {
                                let dataSwitch: [String: Any] = ["Data Switch Check": "OFF" as Any]
                                self.session!.sendMessage(dataSwitch, replyHandler: nil, errorHandler: nil)
                            }
                            if xyzSwitchCheck == "ON" {
                                let xyzSwitch: [String: Any] = ["XYZ Switch Check": "ON" as Any]
                                self.session!.sendMessage(xyzSwitch, replyHandler: nil, errorHandler: nil)
                            }
                            if xyzSwitchCheck == "OFF" {
                                let xyzSwitch: [String: Any] = ["XYZ Switch Check": "OFF" as Any]
                                self.session!.sendMessage(xyzSwitch, replyHandler: nil, errorHandler: nil)
                            }
                            if resultantSwitchCheck == "ON" {
                                let resultantSwitch: [String: Any] = ["Resultant Switch Check": "ON" as Any]
                                self.session!.sendMessage(resultantSwitch, replyHandler: nil, errorHandler: nil)
                            }
                            if resultantSwitchCheck == "OFF" {
                                let resultantSwitch: [String: Any] = ["Resultant Switch Check": "OFF" as Any]
                                self.session!.sendMessage(resultantSwitch, replyHandler: nil, errorHandler: nil)
                            }
                            //                            check the state of each switch and send a message to the appl watch with each switch state at 5Hz to keep interface updated
                           })
        RunLoop.current.add(self.timer, forMode: .default)
        //      run timer
    }
    
    @IBAction func goToAcclerometer(_ sender: Any) {
        //        runs when accelerometer button is pressed
    }
    
    @IBAction func toggleIdentifier(_ sender: UIButton) {
        sender.isSelected.toggle()
        //        make button have same function as a switch
        let userName2 = appleSignInCheck()[2]
        //        get username from sign in
        let randomKey = userDefaultsVitals.string(forKey: "Random Key")
        //        retrieve secret key
        sender.setTitle(userName2, for: .normal)
        sender.setTitle(randomKey, for: .selected)
        //        toggle between username and secret key when the username is pressed
    }
    
    @IBAction func sendDataSwitch(_ sender: Any) {
        if dataSwitch.isOn == true {
            userDefaultsVitals.setValue("ON", forKey: "Data Switch")
        }
        else if dataSwitch.isOn == false {
            userDefaultsVitals.setValue("OFF", forKey: "Data Switch")
        }
        //        change state of switch when it is pressed
    }
    
    @IBAction func checkForSignOut(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Sign Out?", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        //            create alert verifying if user wants to sign out
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in alertController.dismiss(animated: true, completion: nil)
            //            runs if user selects yes on the alert
            self.userDefaultsVitals.setValue("OUT", forKey: "Sign In")
            //            set state of app to signed out
            GIDSignIn.sharedInstance().signOut()
            //            sign out of google services if user signed in with google
            self.performSegue(withIdentifier: "signOutSegue", sender: self)
            //            head back to login screen
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        //        runs if user selects cancel on the alert
        self.present(alertController, animated: true, completion: nil)
        //        show alert
        
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
            //            run in main thread
            if let heartRate = message["hr"] as? String {
                //                check if message from apple watch is for heart rate
                let heartRateFormat = ("\(heartRate) BPM")
                self.heartBeatiOS.text = heartRateFormat
                print(heartRate)
                self.userDefaultsVitals.setValue(heartRateFormat, forKey: "Heart Rate")
                let heartRateMessage = ("heart_rate:\(heartRate)")
                //                retrieve and format data from apple watch
                if self.dataSwitch.isOn{
                    self.uploadHeartBeatData(HRValue: heartRateMessage)
                    //                    send value to upload function
                }
            }
            
            if let SPO2 = message["spo2"] as? String {
                //                check if message is for SPO2
                self.SPO2iOS.text = ("\(SPO2)%")
                let spo2Message = ("blood_o2:\(SPO2)")
                if self.dataSwitch.isOn{
                    self.uploadSPO2Data(SPO2Value: spo2Message)
                    //                    send spo2 value to upload function
                }
            }
            
            if let noiseExpos = message["NoiseEx"] as? String {
                //                check if message is for long term noise exposure
                self.avgLongTermNE.text = ("\(noiseExpos) dB")
                let longTermNEMessage = ("noise:\(noiseExpos)")
                if self.dataSwitch.isOn{
                    self.uploadLTNEData(LTNEValue: longTermNEMessage)
                    //                    send noise value to upload function
                }
            }
            
            if let sleepTime = message["SleepTime"] as? Double {
                //                check if message is for sleep
                let sleepMessage = ("sleep:\(sleepTime)")
                HealthDataManager.sharedInstance.retrieveSleep { result -> Void in
                    DispatchQueue.main.async {
                        let timeSlept = String(Int(result / 3600)) + "h " +
                            String(Int(result.truncatingRemainder(dividingBy: 3600) / 60)) + "m " +
                            String(Int(result.truncatingRemainder(dividingBy: 3600)
                                        .truncatingRemainder(dividingBy: 60))) + "s"
                        //                        format sleep data into --h --m --s (hours, minutes, seconds)
                        self.hoursSleptLabel.text = String(timeSlept)
                        //                        update interface with sleep data
                    }
                }
                
                if self.dataSwitch.isOn{
                    self.uploadSleepData(sleepValue: sleepMessage)
                    //                    if uploading is enabled send value to upload function
                }
            }
            
            if (message["Start Pressed"] as? String) != nil {
                //                check if user started monitoring on apple watch
                let userName2 = self.appleSignInCheck()[2]
                let longitude = HealthDataManager.sharedInstance.requestLongitude()
                let latitude = HealthDataManager.sharedInstance.requestLatitude()
                self.longitudeLatitudeLabel.text = ("\(longitude), \(latitude)")
                //                retrieve location and update phone's interface
                if self.dataSwitch.isOn{
                    self.timer = Timer(fire: Date(), interval: (120.0/1.0),
                                       repeats: true, block: { (timer) in
                                        self.longitudeLatitudeLabel.text = self.uploadLocationData()
                                        
                                        let dataLO: [String: Any] = ["Longitude": longitude as Any]
                                        self.session!.sendMessage(dataLO, replyHandler: nil, errorHandler: nil)
                                        let dataLA: [String: Any] = ["Latitude": latitude as Any]
                                        self.session!.sendMessage(dataLA, replyHandler: nil, errorHandler: nil)
                                        let data: [String: Any] = ["Name Label":"\(userName2)" as Any]
                                        // transform Username into Data datatype [String: Any]
                                        self.session!.sendMessage(data, replyHandler: nil, errorHandler: nil)
                                        // send username to apple watch to update value
                                       })
                    //                    send location to apple watch
                    RunLoop.current.add(self.timer, forMode: .default)
                    //                     run timer sending location every 2 minutes
                }
                self.userDefaultsVitals.setValue("Start", forKey: "Check Pressed")
                //                check for state of monitor button on the apple watch
            }
            
            if (message["Stop Pressed"] as? String) != nil {
                //                check user stopped monitoring data on apple watch
                self.timer.invalidate()
                self.heartBeatiOS.text = "--"
                self.SPO2iOS.text = "--"
                self.avgLongTermNE.text = "--"
                self.hoursSleptLabel.text = "--"
                self.longitudeLatitudeLabel.text = "--,--"
                self.userDefaultsVitals.setValue("Stop", forKey: "Check Pressed")
                //                clear interface if user wants to stop monitoring
            }
            
            if let IDScreenCheck = message["Watch Display Activated"] as? String {
                if IDScreenCheck == "Activated"{
                    let data: [String : Any]  = ["Load Main Watch Screen" : "Activate Screen" as Any]
                    self.session?.sendMessage(data, replyHandler: nil, errorHandler: nil)
                }
                //                check when user logs into phone or if they have previously logged in to login to apple watch app
            }
            
            let accelView = AccelerometerViewController()
            //            create variable for acclerometer view controller
            let xyzSwitchCheck = self.userDefaultsVitals.string(forKey: "XYZ Switch")
            let resultantSwitchCheck = self.userDefaultsVitals.string(forKey: "Resultant Switch")
            //            retrieve state of accelerometer uploading switches
            if let xyzArray = message["Array"] as? [Double] {
                if xyzSwitchCheck == "ON" {
                    accelView.uploadXYZArray(xyzArray: xyzArray)
                }
                else if xyzSwitchCheck == "OFF" {
                }
            }
            if let resultantXYZ = message["Resultant"] as? Double {
                let resultantRound = Double(round(1000*resultantXYZ)/1000)
                if resultantSwitchCheck == "ON" {
                    accelView.uploadResultantAccel(resultantAccel: resultantRound)
                }
                else if resultantSwitchCheck == "OFF" {
                }
            }
            //            upload acceleration values in the background if the accleration uploading switches are enabled
        }
    }
}



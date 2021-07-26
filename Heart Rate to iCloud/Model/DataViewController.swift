//
//  DataViewController.swift
//  Heart Rate to iCloud
//
//  Created by Victor Guzman on 6/25/21.
//

import UIKit
import HealthKit
import WatchConnectivity
import Amplify
import AmplifyPlugins
import Combine
import BackgroundTasks
import CoreLocation
import GoogleSignIn
import AdSupport
import AppTrackingTransparency
import UserNotifications

/// DESCRIPTION: The DataViewController class inherits the UITableViewController class which allows it to have a table like interface and access all properties of table like interfaces. The class handles displaying all of the data collected from the Apple Watch and calls methods to send the data to AWS. Extra heart beat data can also be presented through the class if the user selects the "moreHRDataPressed" button The class also handles navigating between other pages of Cloud Vitals.
class DataViewController: UITableViewController{
    
    @IBOutlet var heartBeatLabel: UILabel!
    @IBOutlet var SPO2iOS: UILabel!
    @IBOutlet var avgLongTermNE: UILabel!
    @IBOutlet var hoursSleptLabel: UILabel!
    @IBOutlet var xAccelLabel: UILabel!
    @IBOutlet var yAccelLabel: UILabel!
    @IBOutlet var zAccelLabel: UILabel!
    @IBOutlet var resultAccelLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var userGuideButton: UIButton!
    @IBOutlet var homeButton: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var restingHRLabel: UILabel!
    @IBOutlet var restingHRTitle: UILabel!
    @IBOutlet var hrvLabel: UILabel!
    @IBOutlet var ecgLabel: UILabel!
    @IBOutlet var showMoreHRDataButton: UIButton!
    @IBOutlet var remoteMonitor: UIButton!
    @IBOutlet var awsConnectionLabel: UIButton!
    var session: WCSession?
    var timer = Timer.init()
    var clearTimer = Timer.init()
    var uploadTimer = Timer.init()
    var hiddenHRData = true
    var awsData = AWSDataManager()
    let settings = SettingsViewController()
    let login = LoginDataManager()
    let dayChange = DayChangeManager()
    let userDefaultsVitals = UserDefaults.standard
    let imageDown = UIImage(systemName: "chevron.down")
    let imageUp = UIImage(systemName: "chevron.up")
    let imageConnected = UIImage(systemName: "checkmark.icloud.fill")
    let imageDisconnected = UIImage(systemName: "xmark.icloud.fill")
    
    /// DESCRIPTION: When the homescreen is loading the interfaced is configured with the following attributes. The navigation buttons are configured to have curved corners. The connection with the Apple Watch component is also established when the view is loading.
    override func viewDidLoad(){
        super.viewDidLoad()
        userGuideButton.layer.cornerRadius = 6
        homeButton.layer.cornerRadius = 6
        settingsButton.layer.cornerRadius = 6
        checkTableView()
        checkAWS()
        configureWatchKitSession()
    }
    
    /// DESCRIPTION: The configureWatchKitSession() allows the user to configure the connection between the iPhone and Apple Watch apps. It first checks if a session is supported and then gives it the default configuration if it is available.
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
    /// DESCRIPTION: The tableView function configures the top table view to hide and show the resting heart beat row in case the user decides they want to view extra heart beat data.
    /// PARAMS: The parameters for the table view method are the UITableView that is being configured and the index path of the section and row that is being configured in the table view.
    /// RETURNS: The tableView method returns a CGFloat that determines the height of table view cell that is being transformed by the function.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 2 && indexPath.row == 1 && hiddenHRData == true{
            return 0
        }
        else if indexPath.section == 2 && indexPath.row == 1 && hiddenHRData == false {
            return 45
        }
        if indexPath.section == 2 && indexPath.row == 2 && hiddenHRData == true{
            return 0
        }
        else if indexPath.section == 2 && indexPath.row == 2 && hiddenHRData == false {
            return 45
        }
        if indexPath.section == 2 && indexPath.row == 3 && hiddenHRData == true{
            return 0
        }
        else if indexPath.section == 2 && indexPath.row == 3 && hiddenHRData == false {
            return 45
        }
        return tableView.rowHeight
    }
    
    /// DESCRIPTION: When the chevron arrow next to the heart beat label is pressed this method is called and it checks whether the user wants to display extra heart beat info or hide that info based on the current state of the button. When either scenario occurs the method either hides the cells with the extra heart beat info or presents them to teh user through internal storage of variables. The image associated with the button is also changed to point either up or down.
    /// PARAMS: The sender parameter references the button that was pressed.
    @IBAction func moreHRDataPressed(_ sender: UIButton) {
        if hiddenHRData == true {
            showMoreHRDataButton.setImage(imageUp, for: .normal)
            userDefaultsVitals.set(1, forKey: "MORE HR")
            hiddenHRData = false
            tableView.reloadData()
        }
        else {
            showMoreHRDataButton.setImage(imageDown, for: .normal)
            userDefaultsVitals.set(0, forKey: "MORE HR")
            hiddenHRData = true
            tableView.reloadData()
        }
    }
    
    /// DESCRIPTION: This method is called when the large "Monitor" button is pressed. A bluetooth message is sent to the apple watch app and begins to monitor data from the watch. Once monitoring starts the button's label changes to say "Stop" alerting the user that they can stop the data monitoring witht the same button. When user presses "Stop" a timer loop runs for one secon to make sure no excess data remains on the interface.
    /// PARAMS: The sender parameter references the button that was pressed.
    @IBAction func remoteMonitoringPressed(_ sender: UIButton) {
        sender.isSelected.toggle()
        remoteMonitor.setTitle("Stop Monitoring", for: .selected)
        remoteMonitor.setTitle("Monitor Data", for: .normal)
        if remoteMonitor.isSelected {
            clearTimer.invalidate()
            let monitor: [String: Any] = ["Remote Monitor": "Monitor" as Any]
            session!.sendMessage(monitor, replyHandler: nil, errorHandler: nil)
            userDefaultsVitals.set("Run Location", forKey: "Location Loop")
            HealthDataManager.sharedInstance.ecgQuery { result -> Void in
                DispatchQueue.main.async {
                self.ecgLabel.text = result
                let ecgValue: [String: Any] = ["ECG": result as Any]
                self.session!.sendMessage(ecgValue, replyHandler: nil, errorHandler: nil)
                }
            }
            getLocation()
        }
        else {
            let monitor: [String: Any] = ["Remote Monitor": "Stop" as Any]
            session!.sendMessage(monitor, replyHandler: nil, errorHandler: nil)
            timer.invalidate()
            clearTimer = Timer(fire: Date(), interval: (1.0/100.0),
                               repeats: true, block: { (timer) in
                                self.clearDataFields()
                               })
            RunLoop.current.add(clearTimer, forMode: .default)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // Change `2.0` to the desired number of seconds.
                // Code you want to be delayed
                self.clearTimer.invalidate()
            }
            userDefaultsVitals.set("Stop Location", forKey: "Location Loop")
        }
        
    }
    
    /// DESCRIPTION: When this method is called all of the mutating labels on the interface are cleared to only represent "--". This is used once the user has decided to stop monitoring their data.
    func clearDataFields() {
        timer.invalidate()
        heartBeatLabel.text = "--"
        restingHRLabel.text = "--"
        hrvLabel.text = "--"
        ecgLabel.text = "--"
        SPO2iOS.text = "--"
        avgLongTermNE.text = "--"
        hoursSleptLabel.text = "--"
        longitudeLabel.text = "--"
        latitudeLabel.text = "--"
        xAccelLabel.text = "--"
        yAccelLabel.text = "--"
        zAccelLabel.text = "--"
        resultAccelLabel.text = "--"
    }
    
    /// DESCRIPTION: The getLocation method is used for getting the user's current location in decimal degrees coordinates. The method first checks whether the user has turned on the upload location switch in settings. Next the method gathers the location data from the HealthDataManager class to display on the interface and send to the apple watch via bluetooth. A RunLoop timer is created that updates the user's location every two minutes if they are still monitoring their data.
    func getLocation() {
        let locationSwitchCheck = userDefaultsVitals.string(forKey: "Location Switch")
        let uploadLocation = HealthDataManager.sharedInstance.requestLocationAuthorization()[0]
        let longitude = HealthDataManager.sharedInstance.requestLocationAuthorization()[1]
        let latitude = HealthDataManager.sharedInstance.requestLocationAuthorization()[2]
        self.remoteMonitor.setTitle("Stop Monitoring", for: .normal)
        self.remoteMonitor.setTitle("Stop Monitoring", for: .selected)  
        self.timer = Timer(fire: Date(), interval: (120.0/1.0),
                           repeats: true, block: { (timer) in
                            self.longitudeLabel.text = longitude
                            self.latitudeLabel.text = latitude
                            let dataLO: [String: Any] = ["Longitude": longitude as Any]
                            self.session!.sendMessage(dataLO, replyHandler: nil, errorHandler: nil)
                            let dataLA: [String: Any] = ["Latitude": latitude as Any]
                            self.session!.sendMessage(dataLA, replyHandler: nil, errorHandler: nil)
                            if locationSwitchCheck == "ON" {
                                self.awsData.uploadPhysiologicalData(vitalsValue: uploadLocation, ecgValue: ["NONE"], accelValue: ["NONE"])
                            }
                            if self.userDefaultsVitals.string(forKey: "Location Loop") == "Stop Location" {
                                timer.invalidate()
                            }
                           })
        //                    send location to apple watch
        RunLoop.current.add(self.timer, forMode: .default)
        //                     run timer sending location every 2 minutes
    }
    
    /// DESCRIPTION: This method is caused to check if the user successfully connect to AWS Amplify services. The cloud image at the top turns green if the connection is good and stays red if the connection is not successful. The title of the label also changes based on the status of the AWS connection.
    func checkAWS() {
        if userDefaultsVitals.bool(forKey: "Amplify") == true {
            awsConnectionLabel.setImage(imageConnected, for: .normal)
            awsConnectionLabel.tintColor = #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
            awsConnectionLabel.setTitle("Connected to AWS", for: .normal)
        }
        else {
            awsConnectionLabel.setImage(imageDisconnected, for: .normal)
            awsConnectionLabel.tintColor = #colorLiteral(red: 0.93564713, green: 0.2231650352, blue: 0.1551090479, alpha: 1)
            awsConnectionLabel.setTitle("Not Connected to AWS", for: .normal)
        }
    }
    
    /// DESCRIPTION: This method is called when the app loads up to check if in a previous session the user had left the extra heart beat info table cells in view or hidden. Depending on the scenario the data interface will either load with the cells hidden or in view.
    func checkTableView() {
        if userDefaultsVitals.integer(forKey: "MORE HR") == 0 {
            hiddenHRData = true
            showMoreHRDataButton.setImage(imageDown, for: .normal)
            tableView.reloadData()
        }
        else if userDefaultsVitals.integer(forKey: "MORE HR") == 1 {
            hiddenHRData = false
            showMoreHRDataButton.setImage(imageUp, for: .normal)
            tableView.reloadData()
        }
    }
}

/// DESCRIPTION: The extension to the DataViewController class contains all of the available methods from the UIViewController class and now it conforms to the WCSessionDelegate protocol. The extension is mainly responsible for handling the incoming data stream from the apple watch. Most of the data is the physiological data that is collected by the apple watch but the rest is mainly 
extension DataViewController: WCSessionDelegate {
    
    /// DESCRIPTION: The sessionDidBecomInactive method is called when the bluetooth communication between the iPhone and the Apple Watch becomes innactive which means there is no live communication occuing between the two devices regarding the app.
    /// PARAMS: The parameter of this method is the Watch Connectivity Session between the iPhone and the Apple Watch.
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    /// DESCRIPTION: The sessionDidDeactivate method is called when the communication between the apple watch app and the iPhone app fails or it is shut off.
    /// PARAMS: The parameter of this method is the Watch Connectivity Session between the iPhone and the Apple Watch.
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    /// DESCRIPTION: The redeclaration of the session method is called when the Watch Connectivity session is established between the iPhone and the apple watch.
    /// PARAMS: The parameters for this method are the Watch Connectivity session itself, the state at which the session is in, and any error that may occur during the app's attempt to create this session.
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?){
    }
    
    /// DESCRIPTION: This redeclaration of the session method is called when a message from the apple watch is sent through the watch connectivity pipeline and received by the iPhone. Here the message can be processed and even displayed on the interface. This method is responsible for handling all of the physiological, acceleration, and location data that is being transmitted by the apple watch. The moment any piece of data is received it is displayed on the interface in real time and updates whenever the data changes. The method also sends the data to the AWSDataManager to upload the data to the cloud if their respective uploading switches are enabled. That same data is also stored locally so as to not overwrite any data that is already in the cloud. Smaller arrays of each type of data are also internally stored to present the data on the built dashboard of Cloud Vitals. Whether the user has selected to start or stop monitoring is also checked in this method because a message from the watch is sent to the iPhone when the user stops or starts monitoring their data on the watch.
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        var heartBeatArray: [String] = []
        var timeStampArray1: [String] = []
        var bloodO2Array: [String] = []
        var timeStampArray2: [String] = []
        var noiseExposArray: [String] = []
        var timeStampArray3: [String] = []
        var sleepArray: [String] = []
        var timeStampArray4: [String] = []
        var rhrArray: [String] = []
        var timeStampArray5: [String] = []
        var hrvArray: [String] = []
        var timeStampArray6: [String] = []
        var xArray: [String] = []
        var yArray: [String] = []
        var zArray: [String] = []
        var resultantArray: [String] = []
        var timeStampArray7: [String] = []
        var timeStampArray8: [String] = []
        var xyzUpload: [String] = []
        var resultantUpload: [String] = []
        let timeStamp = TimeStampCreator()
        let hbSwitchCheck = userDefaultsVitals.string(forKey: "HB Switch")
        let restingHRSwitchCheck = userDefaultsVitals.string(forKey: "RHR Switch")
        let hrvSwitchCheck = userDefaultsVitals.string(forKey: "HRV Switch")
        let spo2SwitchCheck = userDefaultsVitals.string(forKey: "SPO2 Switch")
        let noiseSwitchCheck = userDefaultsVitals.string(forKey: "Noise Switch")
        let sleepSwitchCheck = userDefaultsVitals.string(forKey: "Sleep Switch")
        let xyzSwitchCheck = userDefaultsVitals.string(forKey: "XYZ Switch")
        let resultantSwitchCheck = userDefaultsVitals.string(forKey: "Resultant Switch")
        let ecgSwitchCheck = userDefaultsVitals.string(forKey: "ECG Switch")
        let newHRArray = userDefaultsVitals.stringArray(forKey: "HR Array")
        let newSPO2Array = userDefaultsVitals.stringArray(forKey: "SPO2 Array")
        let newNoiseArray = userDefaultsVitals.stringArray(forKey: "NE Array")
        let newSleepArray = userDefaultsVitals.stringArray(forKey: "Sleep Array")
        let newRHRArray = userDefaultsVitals.stringArray(forKey: "RHR Array")
        let newHRVArray = userDefaultsVitals.stringArray(forKey: "HRV Array")
        let newXArray = userDefaultsVitals.stringArray(forKey: "X Array")
        let newRArray = userDefaultsVitals.stringArray(forKey: "R Array")
        var newXYZUploadArray = userDefaultsVitals.stringArray(forKey: "XYZ Upload")
        var newRUploadArray = userDefaultsVitals.stringArray(forKey: "R Upload")
        let ecgUpload = userDefaultsVitals.stringArray(forKey: "ECG Upload")
        
        //        retrieve state of data switch
        DispatchQueue.main.async {
            //            run in main thread
            if let heartRate = message["hr"] as? String {
                //                check if message from apple watch is for heart rate
                let heartRateFormat = ("\(heartRate) BPM")
                self.heartBeatLabel.text = heartRateFormat
                self.userDefaultsVitals.setValue(heartRateFormat, forKey: "Heart Rate")
                let heartRateMessage = ("heart_rate:\(heartRate)")
                //                retrieve and format data from apple watch
                if hbSwitchCheck == "ON" {
                    let timeStampHR = TimeStampCreator.getDateOnly(fromTimeStamp: 0.0).1
                    self.awsData.uploadPhysiologicalData(vitalsValue: heartRateMessage, ecgValue: ["NONE"], accelValue: ["NONE"])
                    if newHRArray == nil {
                        heartBeatArray.append(heartRate)
                        timeStampArray1.append(timeStampHR)
                        self.userDefaultsVitals.set(heartBeatArray, forKey: "HR Array")
                        self.userDefaultsVitals.set(timeStampArray1, forKey: "TS1")
                    }
                    else {
                        var newHRArray = self.userDefaultsVitals.stringArray(forKey: "HR Array")!
                        var newTS1Array = self.userDefaultsVitals.stringArray(forKey: "TS1")!
                        newHRArray.append(heartRate)
                        newTS1Array.append(timeStampHR)
                        self.userDefaultsVitals.set(newHRArray, forKey: "HR Array")
                        self.userDefaultsVitals.set(newTS1Array, forKey: "TS1")
                    }
                    //                    send value to upload function
                }
            }
            
            if let SPO2 = message["spo2"] as? String {
                //                check if message is for SPO2
                self.SPO2iOS.text = ("\(SPO2)%")
                let spo2Message = ("blood_o2:\(SPO2)")
                if spo2SwitchCheck == "ON" {
                    self.awsData.uploadPhysiologicalData(vitalsValue: spo2Message, ecgValue: ["NONE"], accelValue: ["NONE"])
                    let timeStampSPO2 = TimeStampCreator.getDateOnly(fromTimeStamp: 0.0).1
                    if newSPO2Array == nil {
                        bloodO2Array.append(SPO2)
                        timeStampArray2.append(timeStampSPO2)
                        self.userDefaultsVitals.set(bloodO2Array, forKey: "SPO2 Array")
                        self.userDefaultsVitals.set(timeStampArray2, forKey: "TS2")
                    }
                    else {
                        var newSPO2Array = self.userDefaultsVitals.stringArray(forKey: "SPO2 Array")!
                        var newTS2Array = self.userDefaultsVitals.stringArray(forKey: "TS2")!
                        newSPO2Array.append(SPO2)
                        newTS2Array.append(timeStampSPO2)
                        self.userDefaultsVitals.set(newSPO2Array, forKey: "SPO2 Array")
                        self.userDefaultsVitals.set(newTS2Array, forKey: "TS2")
                        print("STORED")
                    }
                }
            }
            
            if let noiseExpos = message["NoiseEx"] as? String {
                //                check if message is for long term noise exposure
                self.avgLongTermNE.text = ("\(noiseExpos) dB")
                let longTermNEMessage = ("noise:\(noiseExpos)")
                if noiseSwitchCheck == "ON" {
                    self.awsData.uploadPhysiologicalData(vitalsValue: longTermNEMessage, ecgValue: ["NONE"], accelValue: ["NONE"])
                    let timeStampNE = TimeStampCreator.getDateOnly(fromTimeStamp: 0.0).1
                    if newNoiseArray == nil {
                        noiseExposArray.append(noiseExpos)
                        timeStampArray3.append(timeStampNE)
                        self.userDefaultsVitals.set(noiseExposArray, forKey: "NE Array")
                        self.userDefaultsVitals.set(timeStampArray3, forKey: "TS3")
                    }
                    else {
                        var newNoiseArray = self.userDefaultsVitals.stringArray(forKey: "NE Array")!
                        var newTimeStampArray3 = self.userDefaultsVitals.stringArray(forKey: "TS3")!
                        newNoiseArray.append(noiseExpos)
                        newTimeStampArray3.append(timeStampNE)
                        self.userDefaultsVitals.set(newNoiseArray, forKey: "NE Array")
                        self.userDefaultsVitals.set(newTimeStampArray3, forKey: "TS3")
                    }
                    
                }
            }
            
            if let sleepTime = message["SleepTime"] as? Double {
                //                check if message is for sleep
                let sleepInHours = sleepTime/3600
                HealthDataManager.sharedInstance.getHealthKitSleep { result -> Void in
                    DispatchQueue.main.async {
                        let timeSlept = String(Int(result / 3600)) + "h " +
                            String(Int(result.truncatingRemainder(dividingBy: 3600) / 60)) + "m " +
                            String(Int(result.truncatingRemainder(dividingBy: 3600)
                                        .truncatingRemainder(dividingBy: 60))) + "s"
                        //                        format sleep data into --h --m --s (hours, minutes, seconds)
                        self.hoursSleptLabel.text = String(timeSlept)
                        //                        update interface with sleep data
                        
                        if sleepSwitchCheck == "ON" {
                            self.dayChange.checkDayChange()
                            let dayChange = self.userDefaultsVitals.bool(forKey: "Day Change")
                            if dayChange == true {
                                //                                self.awsData.uploadPhysiologicalData(vitalsValue: sleepMessage)
                                let sleepTimeStamp = TimeStampCreator.getDateOnly(fromTimeStamp: 0.0).3
                                if newSleepArray == nil {
                                    sleepArray.append("\(sleepInHours)")
                                    timeStampArray4.append(sleepTimeStamp)
                                    self.userDefaultsVitals.set(sleepArray, forKey: "Sleep Array")
                                    self.userDefaultsVitals.set(timeStampArray4, forKey: "TS4")
                                }
                                else {
                                    var newSleepArray = self.userDefaultsVitals.stringArray(forKey: "Sleep Array")!
                                    var newTimeStampArray4 = self.userDefaultsVitals.stringArray(forKey: "TS4")!
                                    newSleepArray.append("\(sleepInHours)")
                                    newTimeStampArray4.append(sleepTimeStamp)
                                    print("REMOVING STUFF")
                                    self.userDefaultsVitals.set(newSleepArray, forKey: "Sleep Array")
                                    self.userDefaultsVitals.set(newTimeStampArray4, forKey: "TS4")
                                }
                            }
                        }
                    }
                }
            }
            
            
            if let restingHR = message["restingHR"] as? String {
                let restingHRFormat = ("\(restingHR) BPM")
                self.restingHRLabel.text = restingHRFormat
                let restingHRMessage = ("resting_hr:\(restingHR)")
                
                if restingHRSwitchCheck == "ON" {
                    self.awsData.uploadPhysiologicalData(vitalsValue: restingHRMessage, ecgValue: ["NONE"], accelValue: ["NONE"])
                    let rhrTimeStamp = TimeStampCreator.getDateOnly(fromTimeStamp: 0.0).1
                    if newRHRArray == nil {
                        rhrArray.append(restingHR)
                        timeStampArray5.append(rhrTimeStamp)
                        self.userDefaultsVitals.set(rhrArray, forKey: "RHR Array")
                        self.userDefaultsVitals.set(timeStampArray5, forKey: "TS5")
                        print("SHOULD NOT SHOW")
                        
                    }
                    else {
                        var newRHRArray = self.userDefaultsVitals.stringArray(forKey: "RHR Array")!
                        var newTS5Array = self.userDefaultsVitals.stringArray(forKey: "TS5")!
                        newRHRArray.append(restingHR)
                        newTS5Array.append(rhrTimeStamp)
                        self.userDefaultsVitals.set(newRHRArray, forKey: "RHR Array")
                        self.userDefaultsVitals.set(newTS5Array, forKey: "TS5")
                    }
                }
            }
            
            if let hrvValue = message["hrv"] as? String {
                let hrvFormat = ("\(hrvValue) ms")
                self.hrvLabel.text = hrvFormat
                let hrvMessage = ("hrv:\(hrvValue)")
                if hrvSwitchCheck == "ON" {
                    self.awsData.uploadPhysiologicalData(vitalsValue: hrvMessage, ecgValue: ["NONE"], accelValue: ["NONE"])
                    let hrvTimeStamp = TimeStampCreator.getDateOnly(fromTimeStamp: 0.0).1
                    if newHRVArray == nil {
                        hrvArray.append(hrvValue)
                        timeStampArray6.append(hrvTimeStamp)
                        self.userDefaultsVitals.set(hrvArray, forKey: "HRV Array")
                        self.userDefaultsVitals.set(timeStampArray6, forKey: "TS6")
                    }
                    else {
                        var newHRVArray = self.userDefaultsVitals.stringArray(forKey: "HRV Array")!
                        var newTimeStampArray6 = self.userDefaultsVitals.stringArray(forKey: "TS6")!
                        newHRVArray.append(hrvValue)
                        newTimeStampArray6.append(hrvTimeStamp)
                        self.userDefaultsVitals.set(newHRVArray, forKey: "HRV Array")
                        self.userDefaultsVitals.set(newTimeStampArray6, forKey: "TS6")
                        
                    }
                }
            }
            
            if let xyzArray = message["Array"] as? [Double] {
                self.xAccelLabel.text = ("\(xyzArray[0])")
                self.yAccelLabel.text = ("\(xyzArray[1])")
                self.zAccelLabel.text = ("\(xyzArray[2])")
                //                retrieve xyz acceleration values from apple watch
                let xyzFormat = "xyz_acc:\(xyzArray[0]) \(xyzArray[1]) \(xyzArray[2])"
                if xyzSwitchCheck == "ON" {
                    let xyzTimeStamp = timeStamp.returnFinalTimeStamp().1
                    let finalXYZFormat = "\(timeStamp.returnFinalTimeStamp().0),\(xyzFormat)\n"
                    if newXYZUploadArray == nil {
                        xArray.append("\(xyzArray[0])")
                        yArray.append("\(xyzArray[1])")
                        zArray.append("\(xyzArray[2])")
                        timeStampArray7.append(xyzTimeStamp)
                        xyzUpload.append(finalXYZFormat)
                        self.userDefaultsVitals.set(xArray, forKey: "X Array")
                        self.userDefaultsVitals.set(yArray, forKey: "Y Array")
                        self.userDefaultsVitals.set(zArray, forKey: "Z Array")
                        self.userDefaultsVitals.set(timeStampArray7, forKey: "TS7")
                        self.userDefaultsVitals.set(xyzUpload, forKey: "XYZ Upload")
                        print(xyzUpload)
                        
                    }
                    else {
                        var newXArray = self.userDefaultsVitals.stringArray(forKey: "X Array")!
                        var newYArray = self.userDefaultsVitals.stringArray(forKey: "Y Array")!
                        var newZArray = self.userDefaultsVitals.stringArray(forKey: "Z Array")!
                        var newTimeStamp7 = self.userDefaultsVitals.stringArray(forKey: "TS7")!
                        var newXYZUploadArray = self.userDefaultsVitals.stringArray(forKey: "XYZ Upload")!
                        newXArray.append("\(xyzArray[0])")
                        newYArray.append("\(xyzArray[1])")
                        newZArray.append("\(xyzArray[2])")
                        newTimeStamp7.append(xyzTimeStamp)
                        newXYZUploadArray.append(finalXYZFormat)
                        self.userDefaultsVitals.set(newXArray, forKey: "X Array")
                        self.userDefaultsVitals.set(newYArray, forKey: "Y Array")
                        self.userDefaultsVitals.set(newZArray, forKey: "Z Array")
                        self.userDefaultsVitals.set(newTimeStamp7, forKey: "TS7")
                        self.userDefaultsVitals.set(newXYZUploadArray, forKey: "XYZ Upload")
                        print("NEXT")
                    }
                }
                //                upload xyz values if enabled
            }
            
            if let resultantXYZ = message["Resultant"] as? Double {
                let resultantRound = Double(round(1000*resultantXYZ)/1000)
                self.resultAccelLabel.text = ("\(resultantRound)")
                //                retrieve resultant acceleration value from apple watch
                let resultantFormat = "resultant_acc:\(resultantRound)"
                if resultantSwitchCheck == "ON" {
                    let rTimeStamp = timeStamp.returnFinalTimeStamp().1
                    let finalRFormat = "\(timeStamp.returnFinalTimeStamp().0),\(resultantFormat)\n"
                    if newRUploadArray == nil {
                        resultantArray.append("\(resultantXYZ)")
                        timeStampArray8.append(rTimeStamp)
                        resultantUpload.append(finalRFormat)
                        self.userDefaultsVitals.set(resultantArray, forKey: "R Array")
                        self.userDefaultsVitals.set(timeStampArray8, forKey: "TS8")
                        self.userDefaultsVitals.set(resultantUpload, forKey: "R Upload")
                    }
                    else {
                        var newRArray = self.userDefaultsVitals.stringArray(forKey: "R Array")!
                        var newTimeStampArray8 = self.userDefaultsVitals.stringArray(forKey: "TS8")!
                        var newResultantUpload = self.userDefaultsVitals.stringArray(forKey: "R Upload")!
                        newRArray.append("\(resultantXYZ)")
                        newTimeStampArray8.append(rTimeStamp)
                        newResultantUpload.append(finalRFormat)
                        self.userDefaultsVitals.set(newRArray, forKey: "R Array")
                        self.userDefaultsVitals.set(newTimeStampArray8, forKey: "TS8")
                        self.userDefaultsVitals.set(newResultantUpload, forKey: "R Upload")
                    }
                }
                //                upload resultant values if enabled
            }
            
            if (message["Start Pressed"] as? String) != nil {
                //                check if user started monitoring on apple watch
                //                check for state of monitor button on the apple watch
                self.getLocation()
                HealthDataManager.sharedInstance.ecgQuery { result -> Void in
                    DispatchQueue.main.async {
                    self.ecgLabel.text = result
                    let dataECG: [String: Any] = ["ECG": result as Any]
                    self.session!.sendMessage(dataECG, replyHandler: nil, errorHandler: nil)
                        if ecgSwitchCheck == "ON" {
                            self.awsData.uploadPhysiologicalData(vitalsValue: "NONE", ecgValue: ecgUpload!, accelValue: ["NONE"])
                        }
                    }
                }
                if xyzSwitchCheck == "ON" && newXArray != nil {
                    self.userDefaultsVitals.setValue("Start", forKey: "Check Pressed")
                    var newXArray = self.userDefaultsVitals.stringArray(forKey: "X Array")!
                    var newYArray = self.userDefaultsVitals.stringArray(forKey: "Y Array")!
                    var newZArray = self.userDefaultsVitals.stringArray(forKey: "Z Array")!
                    var newTimeStamp7 = self.userDefaultsVitals.stringArray(forKey: "TS7")!
                    newXArray.removeAll()
                    newYArray.removeAll()
                    newZArray.removeAll()
                    newTimeStamp7.removeAll()
                    self.userDefaultsVitals.set(newXArray, forKey: "X Array")
                    self.userDefaultsVitals.set(newYArray, forKey: "Y Array")
                    self.userDefaultsVitals.set(newZArray, forKey: "Z Array")
                    self.userDefaultsVitals.set(newTimeStamp7, forKey: "TS7")
                }
                
                if resultantSwitchCheck == "ON" && newRArray != nil {
                    self.userDefaultsVitals.setValue("Start", forKey: "Check Pressed")
                    var newRArray = self.userDefaultsVitals.stringArray(forKey: "R Array")!
                    var newTimeStamp8 = self.userDefaultsVitals.stringArray(forKey: "TS8")!
                    newRArray.removeAll()
                    newTimeStamp8.removeAll()
                    self.userDefaultsVitals.set(newRArray, forKey: "R Array")
                    self.userDefaultsVitals.set(newTimeStamp8, forKey: "TS8")
                }
            }
            
            if (message["Stop Pressed"] as? String) != nil {
                //                check user stopped monitoring data on apple watch
                self.clearDataFields()
                self.userDefaultsVitals.setValue("Stop", forKey: "Check Pressed")
                self.remoteMonitor.setTitle("Monitor Data", for: .selected)
                self.remoteMonitor.setTitle("Monitor Data", for: .normal)
                if xyzSwitchCheck == "ON" {
                    self.awsData.uploadPhysiologicalData(vitalsValue: "NONE", ecgValue: ["NONE"], accelValue: newXYZUploadArray!)
                    newXYZUploadArray!.removeAll()
                    self.userDefaultsVitals.set(newXYZUploadArray!, forKey: "XYZ Upload")
                }
                if resultantSwitchCheck == "ON" {
                    self.awsData.uploadPhysiologicalData(vitalsValue: "NONE", ecgValue: ["NONE"], accelValue: newRUploadArray!)
                    newRUploadArray!.removeAll()
                    self.userDefaultsVitals.set(newRUploadArray!, forKey: "R Upload")
                }

            }
            
            if let IDScreenCheck = message["Watch Display Activated"] as? String {
                if IDScreenCheck == "Activated"{
                    let data: [String : Any]  = ["Load Main Watch Screen" : "Activate Screen" as Any]
                    self.session?.sendMessage(data, replyHandler: nil, errorHandler: nil)
                }
                //                check when user logs into phone or if they have previously logged in to login to apple watch app
            }
        }
    }
}



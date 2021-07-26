//
//  AWSDataManager.swift
//  Heart Rate to iCloud
//
//  Created by Victor Guzman on 6/25/21.
//

import Foundation
import Amplify
import AmplifyPlugins
import Combine

struct AWSDataManager {
    
    let loginData = LoginDataManager()
    let timeStamp = TimeStampCreator()
    let userDefaultsData = UserDefaults.standard
    var biometricArray : [String] = []
    var finalData = ""
    var resultSink: AnyCancellable?
    var progressSink: AnyCancellable?
    
    
    mutating func uploadPhysiologicalData(vitalsValue: String, ecgValue: [String], accelValue: [String]) {
        let username = loginData.loginInfo()[2]
        let uuid = userDefaultsData.string(forKey: "UUID")!
        var biometricInputArray: [String] = userDefaultsData.object(forKey: "Vitals Array6") as? [String] ?? []
        if biometricInputArray == [] {
            userDefaultsData.setValue(biometricArray, forKey: "Vitals Array6")
        }
        if vitalsValue != "NONE" {
            finalData = "\(timeStamp.returnFinalTimeStamp().0),\(vitalsValue)\n"
            // create final data string with heartbeat value and timestamp
        }
        if ecgValue != ["NONE"] {
            let ecgTimeStamp = userDefaultsData.string(forKey: "ECG TS")!
            let ecgValueString = ecgValue.joined(separator: " " )
            let finalECGString = "\(ecgTimeStamp)\n \(ecgValueString)"
            finalData = finalECGString
            print("uploading")
        }
        if accelValue != ["NONE"] {
            let finalAccelString = accelValue.joined(separator: " ")
            finalData = finalAccelString
        }
        biometricInputArray.append(finalData)
        //        biometricInputArray.removeLast()
        // append final data to biometric array
        userDefaultsData.setValue(biometricInputArray, forKey: "Vitals Array6")
        // put new biometric array back into iPhone storage
        let newArray : [String] = userDefaultsData.object(forKey: "Vitals Array6") as! [String]
        // retrieve biometric array once again in order to pass it on to AWS
        let finalArray = newArray.joined(separator: " ")
        // join array values with commas
        let HRData = finalArray.data(using: .utf8)!
        // transform finalArray into Data datatype to allow for AWS uploading
        //        let storageOperation = Amplify.Storage.uploadData(key: userName, data: HRData)
        //        let storageOperation = Amplify.Storage.uploadData(key: "\(secretKey)", data: HRData)
        let storageOperation = Amplify.Storage.uploadData(key: "\(uuid)", data: HRData)
        //upload new biometric array to AWS S3 bucket
        progressSink = storageOperation
            .progressPublisher
            .sink { progress in print("Progress: \(progress)") }
        // monitor upload progress
        //        userDefaultsData.setValue(true, forKey: "Upload")
        resultSink = storageOperation
            .resultPublisher
            .sink {
                if case let .failure(storageError) = $0 {
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                    // check for upload errors
                }
                if case .finished = $0 {
                    print("DONE UPLOADING DATA")
                }
            }
            receiveValue: { data in
                print("Completed: \(data)")
                // check for upload completion
            }
        userDefaultsData.setValue(false, forKey: "Upload")
        
    }
    
    //    DESCRIPTION: Configure the connection to amazon's amplify services and add authorization and storage plugins for AWS. Provides feedback on the success or failure of the operation notifying user if their connection to AWS was successful or not
    func configureAmplify() {
        //        let models = AmplifyModels()
        //        let dataStorePlugin = AWSDataStorePlugin(modelRegistration: models)
        //        let apiPlugin = AWSAPIPlugin(modelRegistration: models)
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            //        add Amplify cognito plug in
            try Amplify.add(plugin: AWSS3StoragePlugin())
            //         add S3 storage plugin
            //            try Amplify.add(plugin: apiPlugin)
            //            try Amplify.add(plugin: dataStorePlugin)
            try Amplify.configure()
            //        configure AWS Amplify services
            print("Initialized Amplify");
            userDefaultsData.set(true, forKey: "Amplify")
        } catch {
            // simplified error handling for the tutorial
            print("Could not initialize Amplify: \(error)")
            userDefaultsData.set(false, forKey: "Amplify")
        }
        Amplify.Logging.logLevel = .info
    }
    
}

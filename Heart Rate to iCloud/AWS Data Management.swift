//
//  AWS Data Management.swift
//  Heart Rate to iCloud
//
//  Created by vctrg on 2/20/21.
//

import Foundation
import AWSIoT
import WatchConnectivity

class AWSManagement {
    static let awsManagement = AWSManagement()
    func awsSetup() {
    let credentials = AWSCognitoCredentialsProvider(regionType:.USEast2, identityPoolId: "us-east-2:95766fb6-9b9b-43be-8486-45c4bd0e46e1")
    let configuration = AWSServiceConfiguration(region:.USEast2, credentialsProvider: credentials)
        
        // Initialising AWS IoT And IoT DataManager
        AWSIoT.register(with: configuration!, forKey: "kAWSIoT")  // Same configuration var as above
        let iotEndPoint = AWSEndpoint(urlString: "wss://a477k40eorch1-ats.iot.us-east-2.amazonaws.com/mqtt") // Access from AWS IoT Core --> Settings
        let iotDataConfiguration = AWSServiceConfiguration(region:.USEast2,     // Use AWS typedef .Region
                                                           endpoint: iotEndPoint,
                                                           credentialsProvider: credentials)  // credentials is the same var as created above
            
        AWSIoTDataManager.register(with: iotDataConfiguration!, forKey: "kDataManager")

        // Access the AWSDataManager instance as follows:
        let dataManager = AWSIoTDataManager(forKey: "kDataManager")
        let clientId = "clientId"
        getAWSClientId { (clientId, Error) in
            print("\(clientId ?? "error")")
        }
    }
    
    func getAWSClientId(completion: @escaping (_ clientId: String?,_ error: Error? ) -> Void){
        // Depending on your scope you may still have access to the original credentials var
        let credentials = AWSCognitoCredentialsProvider(regionType:.USEast2, identityPoolId: "us-east-2:95766fb6-9b9b-43be-8486-45c4bd0e46e1")
        
        credentials.getIdentityId().continueWith(block: { (task:AWSTask<NSString>) -> Any? in
            if let error = task.error as NSError? {
                print("Failed to get client Id => \(error)")
                completion(nil, error)
                return nil //required by AWSTask Closure
            }
            let clientId = task.result! as String
            print("Got client ID => \(clientId)")
            completion(clientId, nil)
            return nil
        })
    }
    
    func connectToAWSIoT(clientId: String!) {
        func mqttEventCallback(_ status: AWSIoTMQTTStatus){
            switch status {
            case .connecting: print("Connecting to AWS IoT")
            case .connected: print("Connected to AWS IoT")
            // register subscriptions here
            // publish a boot message if required
            case .connectionError: print("AWS IoT connection error")
            case .connectionRefused: print("AWS IoT connection refused")
            case .protocolError: print("AWS IoT protocol error")
            case .disconnected: print("AWS IoT disconnected")
            case .unknown: print("AWS IoT unknown state")
            default: print("Error - unknown MQTT state")
            }
        }
        //ensure connection gets performed background thread (so as not to block the UI)
        DispatchQueue.global(qos: .background).async {
            do {
                print("Attempting to connect to IoT device gateway with ID = \(clientId ?? "error")")
                let dataManager = AWSIoTDataManager(forKey: "kDataManager")
                dataManager.connectUsingWebSocket(withClientId: clientId, cleanSession: true, statusCallback: mqttEventCallback)
                
            } catch {
                print("Error, failed to connect to device gateway => \(error)")
            }
        }
    }
    
    func registerSubscription() {
        func messageReceived(payload: Data){
            let payloadDictionary = jsonDataToDict(jsonData: payload)
            print("Message received: \(payloadDictionary)")
            
            //handle message event here...
        }
        
        let topicArray = ["topicInitial", "topicTwo", "topicThree"]
        let dataManager = AWSIoTDataManager(forKey: "kDataManager")
        
        for topic in topicArray {
            print("Registering subscription to => \(topic)")
            dataManager.subscribe(toTopic: topic, qoS: .messageDeliveryAttemptedAtLeastOnce, messageCallback: messageReceived)
        }
    }
    
    func jsonDataToDict(jsonData: Data?) -> Dictionary <String, Any> {
        do{
            let jsonDict = try JSONSerialization.jsonObject(with: jsonData!, options: [])
            let convertedDict = jsonDict as! [String: Any]
            return convertedDict
        } catch {
            //couldn't get json
            print(error.localizedDescription)
            return [:]
        }
    }
    
    func publishMessage(message: String!, topic: String!) {
        let dataManager = AWSIoTDataManager(forKey: "kDataManager")
        dataManager.publishString(message, onTopic: topic, qoS: .messageDeliveryAttemptedAtLeastOnce) //set qos as needed
        print("publishing")
    }
}


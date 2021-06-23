//
//  HealthDataManager.swift
//  Heart Rate to iCloudTests
//
//  Created by vctrg on 2/6/21.
//

import Foundation
import HealthKit
import WatchConnectivity
import UIKit
import CoreLocation

class HealthDataManager {
    
    static let sharedInstance = HealthDataManager()
    
    var healthStore: HKHealthStore?
//    variable to access health store
    var observerQuery: HKObserverQuery?
    var observerQuery2: HKObserverQuery?
    var observerQuery3: HKObserverQuery?
    var observerQuery4: HKObserverQuery?
//    variables for different observer queries
    var session = WCSession.default
//    watch session variable
    let heartRateUnit = HKUnit(from: "count/min")
    let SPO2Unit = HKUnit(from: "%")
    let NoiseEXUnit = HKUnit(from: "dBASPL")
    let UVEXUnit = HKUnit(from: "count")
//    variables for different units of measurement for the vitals
    var locationManager = CLLocationManager()
//    variabel to access location services
    
    func initialize() -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return false
//            check if health data is available and guard against crashing if it is not
        }
        healthStore = HKHealthStore()
        return true
    }
    
    func requestAuthorization(completion: @escaping ((Bool) -> Void)) { //request authorization for quantityType biometrics
        let healthDataTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!,HKObjectType.quantityType(forIdentifier: .restingHeartRate)!])
//        define data that you want to request authorization for
        
        healthStore?.requestAuthorization(toShare: nil, read: healthDataTypes, completion: { (success, error) in
            if !success {
                print("Error getting autorization for heart rate, SPO2, and noise exposure data")
            }
//            handle any errors here
            completion(success)
        })
    }
    
    func retrieveSleepWithAuth(completion: @escaping (Double) -> ()) {
        
        let typestoRead = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
        ])
        
        let typestoShare = Set([
            HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!
        ])
//        request to read and write sleep data
        healthStore?.requestAuthorization(toShare: typestoShare, read: typestoRead) { (success, error) -> Void in
            if success == false {
                NSLog(" Display not allowed")
            } else {
                self.retrieveSleep(completion: completion)
            }
        }
//         handle any errors when requesting sleep data
    }
    
    func requestLocationAuthorization() -> String {
        var longitude = ""
        var latitude = ""
        locationManager.requestWhenInUseAuthorization()
        var currentLoc: CLLocation!
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
        CLLocationManager.authorizationStatus() == .authorizedAlways) {
           currentLoc = locationManager.location
            latitude = String(format: "%.6f", currentLoc.coordinate.latitude)
            longitude = String(format: "%.6f", currentLoc.coordinate.longitude)
        }
        return("\(latitude), \(longitude)")
    }
//    request authorization for location data
    func requestLongitude() -> String {
        var longitude = ""
        locationManager.requestWhenInUseAuthorization()
        var currentLoc: CLLocation!
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
        CLLocationManager.authorizationStatus() == .authorizedAlways) {
           currentLoc = locationManager.location
            longitude = String(format: "%.6f", currentLoc.coordinate.longitude)
        }
        return("\(longitude)")
    }
//    get longitude from location services
    func requestLatitude() -> String {
        var latitude = ""
        locationManager.requestWhenInUseAuthorization()
        var currentLoc: CLLocation!
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
        CLLocationManager.authorizationStatus() == .authorizedAlways) {
           currentLoc = locationManager.location
            latitude = String(format: "%.6f", currentLoc.coordinate.latitude)
        }
        return("\(latitude)")
    }
//    get latitude from location services
    func observeHeartRateSamples(_ newHeartRate: ((Double) -> (Void))?) {
        let heartRateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)
//        assign variable to heart rate quantity type
        if let observerQuery = observerQuery {
            healthStore?.stop(observerQuery)
        }
        
        observerQuery = HKObserverQuery(sampleType: heartRateSampleType!, predicate: nil) { (_, _, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
        
            self.fetchLatestHeartRateSample { (sample) in
                guard let sample = sample else {
                    return
                }
                
                DispatchQueue.main.async {
                    let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
                    newHeartRate?(heartRate)
                }
            }
        }
        if let query = observerQuery {
            healthStore?.execute(query)
        }
    }
    
    func observeSPO2Samples(_ newSPO2: ((Double) -> (Void))?) {
        let SPO2SampleType = HKObjectType.quantityType(forIdentifier: .oxygenSaturation)
        
        if let observerQuery2S = observerQuery2 {
            healthStore?.stop(observerQuery2S)
        }
        
        
        observerQuery2 = HKObserverQuery(sampleType: SPO2SampleType!, predicate: nil) { (_, _, error) in
                if let error = error {
                    print("Error \(error.localizedDescription)")
                }
            self.fetchLatestSPO2Samples { (sample) in
                guard let sample = sample else{
                    return
                }
                DispatchQueue.main.async {
                    let SPO2 = sample.quantity.doubleValue(for: self.SPO2Unit)
                    newSPO2?(SPO2)
                }
            }
        }
        
        if let query2 = observerQuery2 {
            healthStore?.execute(query2)
        }
    }

    
    func observeEnvAudioSamples(_ newNoise: ((Double) -> (Void))?) {
        let NoiseEXSampleType = HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)
        
        if let observerQueryN = observerQuery3 {
            healthStore?.stop(observerQueryN)
        }
        
        
        observerQuery3 = HKObserverQuery(sampleType: NoiseEXSampleType!, predicate: nil) { (_, _, error) in
                if let error = error {
                    print("Error \(error.localizedDescription)")
                }
            self.fetchLatestNoiseEXSamples{ (sample) in
                guard let sample = sample else{
                    return
                }
                
                DispatchQueue.main.async {
                    let NoiseEX = sample.quantity.doubleValue(for: self.NoiseEXUnit)
                    newNoise?(NoiseEX)
                }
            }
        }
        
        if let query3 = observerQuery3 {
            healthStore?.execute(query3)
        }
    }

    
    func fetchLatestHeartRateSample(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
            completionHandler(nil)
            return
        }
                
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: sampleType,
                                  predicate: predicate,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: [sortDescriptor]) { (_, results, error) in
                                    if let error = error {
                                        print("Error: \(error.localizedDescription)")
                                        return
                                    }
            if results?.isEmpty == false {
                                    completionHandler(results?[0] as? HKQuantitySample)
            }
        }
        healthStore?.execute(query)
    }
    
    func fetchLatestSPO2Samples(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation) else {
            completionHandler(nil)
            return
        }
        
        let predicate2 = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor2 = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query2 = HKSampleQuery(sampleType: sampleType,
                                  predicate: predicate2,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: [sortDescriptor2]) { (_, results, error) in
                                    if let error = error {
                                        print("Error: \(error.localizedDescription)")
                                        return
                                    }
            if results?.isEmpty == false{
                                    completionHandler(results?[0] as? HKQuantitySample)
            }
        }
        
        healthStore?.execute(query2)
    }
    
    func fetchLatestNoiseEXSamples(completionHandler: @escaping (_ sample3: HKQuantitySample?) -> Void) {
        guard let sampleType3 = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.environmentalAudioExposure) else {
            completionHandler(nil)
            return
        }
        
        let predicate3 = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor3 = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query3 = HKSampleQuery(sampleType: sampleType3,
                                  predicate: predicate3,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: [sortDescriptor3]) { (_, results, error) in
                                    if let error = error {
                                        print("Error: \(error.localizedDescription)")
                                        return
                                    }
            if results?.isEmpty == false {
                                    completionHandler(results?[0] as? HKQuantitySample)
            }
            if results?.isEmpty == true {
//                let resultsVC = ViewController()
//                resultsVC.avgLongTermNE.text = "No Noise Data"
            }
        }
        healthStore?.execute(query3)
    }

    
    func retrieveSleep(completion: @escaping (Double) -> ()) {
        let healthStore = HKHealthStore()
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.strictEndDate)
        
        // first, we define the object type we want
        if let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) {
            
            // Use a sortDescriptor to get the recent data first
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
            
            // we create our query with a block completion to execute
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 200, sortDescriptors: [sortDescriptor]) { (query, tmpResult, error) -> Void in
                
                if error != nil {
                    return
                }
                
                var totalSeconds : Double = 0
                var finalTime : Double = 0
                if let result = tmpResult {
                    for item in result {
                        if let sample = item as? HKCategorySample {
                            
                            let timeInterval = sample.endDate.timeIntervalSince(sample.startDate)
                            let isInteger = floor(timeInterval) == timeInterval
                            if isInteger == true && totalSeconds <= 43200 && timeInterval >= 60{
                            totalSeconds = (totalSeconds + timeInterval)
                            finalTime = (totalSeconds - timeInterval)
//                            print(finalTime)
                            print(totalSeconds)
//                            print(timeInterval)
                            }
                        }
                    }
                }
                    if totalSeconds <= 43200 {
                        let result = totalSeconds
                        completion(result)
                    }
                    else {
                        let result = finalTime
                        completion(result)
                    }
                }
            // finally, we execute our query
            healthStore.execute(query)
        }
    }
    
}


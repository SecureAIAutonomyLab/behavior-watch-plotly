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
    var observerQuery5: HKObserverQuery?
    var observerQuery6: HKStatisticsQuery?
    //    variables for different observer queries
    var session = WCSession.default
    //    watch session variable
    var locationManager = CLLocationManager()
    //    variabel to access location services
    let heartRateUnit = HKUnit(from: "count/min")
    let hrvUnit = HKUnit(from: "count")
    let SPO2Unit = HKUnit(from: "%")
    let NoiseEXUnit = HKUnit(from: "dBASPL")
    let UVEXUnit = HKUnit(from: "count")
    let userDataDefaults = UserDefaults.standard
    let dateFormatter = DateFormatter()
    //    variables for different units of measurement for the vitals
    
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
        if #available(iOS 14.0, *) {
            let healthDataTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!,HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,(HKElectrocardiogramType.electrocardiogramType())])
            //        define data that you want to request authorization for
            healthStore?.requestAuthorization(toShare: nil, read: healthDataTypes, completion: { (success, error) in
                if !success {
                    print("Error getting autorization for heart rate, SPO2, and noise exposure data")
                }
                //            handle any errors here
                completion(success)
            })
        }
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
                self.getHealthKitSleep(completion: completion)
            }
        }
        //         handle any errors when requesting sleep data
    }
    
    func requestLocationAuthorization() -> [String] {
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
        return(["location:\(latitude) \(longitude)", longitude, latitude])
    }
    
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
    
    func observeRestingHeartRate(_ restingHR: ((Double) -> (Void))?) {
        let restingHeartRateSampleType = HKObjectType.quantityType(forIdentifier: .restingHeartRate)
        //        assign variable to heart rate quantity type
        if let observerQueryRHR = observerQuery5 {
            healthStore?.stop(observerQueryRHR)
        }
        
        observerQuery5 = HKObserverQuery(sampleType: restingHeartRateSampleType!, predicate: nil) { (_, _, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            self.fetchLatestRestingHR { (sample) in
                guard let sample = sample else {
                    return
                }
                
                DispatchQueue.main.async {
                    let restingHeartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
                    restingHR?(restingHeartRate)
                }
            }
        }
        if let query5 = observerQuery5{
            healthStore?.execute(query5)
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
    
    func fetchLatestRestingHR(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void) {
        guard let sampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.restingHeartRate) else {
            completionHandler(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query5 = HKSampleQuery(sampleType: sampleType,
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
        healthStore?.execute(query5)
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
    
    func getHealthKitSleep(completion: @escaping (Double) -> ()) {
        let healthStore = HKHealthStore()
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        // Get all samples from the last 24 hours
        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-1.0 * 60.0 * 60.0 * 24.0)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        // Sleep query
        let sleepQuery = HKSampleQuery(
            sampleType: HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis)!,
            predicate: predicate,
            limit: 0,
            sortDescriptors: [sortDescriptor]){ (query, results, error) -> Void in
            if error != nil {return}
            // Sum the sleep time
            var secondsSleepAggr = 0.0
            if let result = results {
                for item in result {
                    if let sample = item as? HKCategorySample {
                        if sample.value == HKCategoryValueSleepAnalysis.asleep.rawValue && sample.startDate >= startDate {
                            let sleepTime = sample.endDate.timeIntervalSince(sample.startDate)
                            let secondsBetweenDates = sleepTime
                            secondsSleepAggr += secondsBetweenDates
                        }
                    }
                }
                print(secondsSleepAggr)
                completion(secondsSleepAggr)
                //                                            self.sleep = Double(String(format: "%.1f", minutesSleepAggr / 60))!
                //                                            print("HOURS: \(String(describing: self.sleep))")
            }
        }
        // Execute our query
        healthStore.execute(sleepQuery)
    }
    
    
    func sdnnQuery() {
        guard let heartRateVar = HKSampleType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRateVariabilitySDNN) else{
            fatalError("*** Unable to get the step count type ***")
        }
        
        let calendar = NSCalendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        
        guard let startDate = calendar.date(from: components) else {
            fatalError("*** Unable to create the start date ***")
        }
        
        guard let endDate = calendar.date(byAdding: .day, value: 2, to: startDate) else {
            fatalError("*** Unable to create the end date ***")
        }
        
        let today = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictEndDate)
        
        let query = HKStatisticsQuery(quantityType: heartRateVar, quantitySamplePredicate: today, options: .mostRecent) { (query, statisticsOrNil, errorOrNil) in
            
            guard let statistics = statisticsOrNil else {
                // Handle any errors here.
                return
            }
            
            let test = statistics.mostRecentQuantity()
            let heartRateVariability = test!.doubleValue(for: HKUnit.second())
            
            // Update your app here.
            
            // The results come back on an anonymous background queue.
            // Dispatch to the main queue before modifying the UI.
            DispatchQueue.main.async {
                // Update the UI here.
                let heartRateVarRound = Double(round(1000*heartRateVariability))
                self.userDataDefaults.set(heartRateVarRound, forKey: "HRV")
                print(heartRateVariability)
            }
        }
        healthStore?.execute(query)
        
    }
    
    func ecgQuery(completion: @escaping (String) -> ()) {
        if #available(iOS 14.0, *) {
            dateFormatter.dateFormat = "MM/dd/yy-HH:mm:ss"
            let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast,end: Date(),options: .strictEndDate)
            let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
            let ecgQuery = HKSampleQuery(sampleType: HKObjectType.electrocardiogramType(), predicate: predicate, limit: 1, sortDescriptors: [sortDescriptor]){ (query, samples, error) in
                guard let samples = samples,
                      let mostRecentSample = samples.first as? HKElectrocardiogram else {
                    return
                }
                let averageHR = mostRecentSample.averageHeartRate?.doubleValue(for: self.heartRateUnit)
                let timestamp = mostRecentSample.startDate
                let timeStampECG = self.dateFormatter.string(from: timestamp)
                self.userDataDefaults.set(timeStampECG, forKey: "ECG TS")
                self.userDataDefaults.set(averageHR, forKey: "ECG HR")
                let classification = mostRecentSample.classification.rawValue
                switch classification {
                case 0:
                    completion("Not Set")
                case 1:
                    completion("Sinus Rythym")
                case 2:
                    completion("Atrial Fibrillation")
                case 3:
                    completion("Inconclusive Low HR")
                case 4:
                    completion("Inconclusive High HR")
                case 5:
                    completion("Inconclusive Poor Reading")
                case 6:
                    completion("Inconclusive Other")
                case 100:
                    completion("Unrecognized")
                default:
                    completion("NO DATA")
                }
                var ecgSamples = [String] ()
                var timeArray = [String] ()
                var uploadECGArray = [String] ()
                let query = HKElectrocardiogramQuery(mostRecentSample) { (query, result) in
                    
                    switch result {
                    
                    case .error(let error):
                        print("error: ", error)
                        
                    case .measurement(let value):
                        let sample = value.quantity(for: .appleWatchSimilarToLeadI)!.doubleValue(for: HKUnit.volt())
                        let time = value.timeSinceSampleStart
                        let sampleRound = Double(round(sample*1000000000)/1000)
                        let timeRound = Double(round(time*1000)/1000)
                        ecgSamples.append("\(sampleRound)")
                        timeArray.append("\(time)")
                        uploadECGArray.append("\(timeRound),ecg:\(sampleRound)\n")
                        
                    case .done:
                        self.userDataDefaults.set(ecgSamples, forKey: "ECG Array")
                        self.userDataDefaults.set(timeArray, forKey: "ECG Time")
                        self.userDataDefaults.set(uploadECGArray, forKey: "ECG Upload")
                        print("done")
                    }
                }
                self.healthStore?.execute(query)
            }
            healthStore?.execute(ecgQuery)
        }
    }
    
}


//
//  HealthDataManager.swift
//  Heart Rate to iCloudTests
//
//  Created by vctrg on 2/6/21.
//

import Foundation
import HealthKit

class HealthDataManager {
    
    static let sharedInstance = HealthDataManager()
    
    var healthStore: HKHealthStore?
    var observerQuery: HKObserverQuery?
    var observerQuery2: HKObserverQuery?
    var observerQuery3: HKObserverQuery?
    var ecgQuery: HKSampleQuery?
    let heartRateUnit = HKUnit(from: "count/min")
    let SPO2Unit = HKUnit(from: "%")
    let NoiseEXUnit = HKUnit(from: "dBASPL")
    
    func initialize() -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("Health data not available")
            return false
        }
        
        healthStore = HKHealthStore()
        
        return true
    }
    
    func requestAuthorization(completion: @escaping ((Bool) -> Void)) {
        let healthDataTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,HKObjectType.quantityType(forIdentifier: .oxygenSaturation)!,HKObjectType.quantityType(forIdentifier: .environmentalAudioExposure)!])
        let ecgType = Set([HKObjectType.electrocardiogramType()])
        
        healthStore?.requestAuthorization(toShare: nil, read: healthDataTypes, completion: { (success, error) in
            if !success {
                print("Error getting autorization for heart rate, SPO2, and noise exposure data")
            }
            completion(success)
        })
        healthStore?.requestAuthorization(toShare: nil, read: ecgType, completion: { (success, error) in
            if !success {
                print("Error getting ECG Data")
            }
            completion(success)
        })
    }
    
    func observeHeartRateSamples(_ newHeartRate: ((Double) -> (Void))?) {
        let heartRateSampleType = HKObjectType.quantityType(forIdentifier: .heartRate)
        
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
    
    func observeECGsamples(_ newECG: ((String) -> (Void))?) {
        let ecgSampleType = HKObjectType.electrocardiogramType()
        
        if let ECGQ = ecgQuery {
        healthStore?.stop(ECGQ)
        }
        
        ecgQuery = HKSampleQuery(sampleType: ecgSampleType, predicate: nil, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (_, _, error) in
                if let error = error {
                    print("Error \(error.localizedDescription)")
                }
            self.fetchLatestECGSamples{ (sample) in
                guard sample == sample else{
                    return
                }
                
                DispatchQueue.main.async {
                    let ecgData = String()
                    newECG?(ecgData)
                }
            }
        }
        
        if let queryECG = ecgQuery {
            healthStore?.execute(queryECG)
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
                                    
                                    completionHandler(results?[0] as? HKQuantitySample)
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
                                    
                                    completionHandler(results?[0] as? HKQuantitySample)
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
                                    
                                    completionHandler(results?[0] as? HKQuantitySample)
        }
        
        healthStore?.execute(query3)
    }
    
    func fetchLatestECGSamples(completionHandler: @escaping (_ sample: HKQuantitySample?) -> Void) {
        
        let sampleType = HKObjectType.electrocardiogramType()
        
        let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let ecgquery = HKSampleQuery(sampleType: sampleType,
                                  predicate: predicate,
                                  limit: Int(HKObjectQueryNoLimit),
                                  sortDescriptors: [sortDescriptor]) { (_, results, error) in
                                    if let error = error {
                                        print("Error: \(error.localizedDescription)")
                                        return
                                    }
            completionHandler(results?[0] as? HKQuantitySample)

        }
        healthStore?.execute(ecgquery)
    }
    
    func newECGQuery() {
                let predicate = HKQuery.predicateForSamples(withStart: Date.distantPast,end: Date.distantFuture,options: .strictEndDate)
                let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
                let ecgQuery = HKSampleQuery(sampleType: HKObjectType.electrocardiogramType(), predicate: predicate, limit: 0, sortDescriptors: [sortDescriptor]){ (query, samples, error) in
                    guard let samples = samples,
                        let mostRecentSample = samples.first as? HKElectrocardiogram else {
                        return
                    }
                    print("hellOOOOOO \(mostRecentSample)")
                    var ecgSamples = [(Double,Double)] ()
                    let query = HKElectrocardiogramQuery(mostRecentSample) { (query, result) in
                      
                        switch result {
                        case .error(let error):
                            print("error: ", error)
                            
                        case .measurement(let value):
                            print("value: ", value)
                            let sample = (value.quantity(for: .appleWatchSimilarToLeadI)!.doubleValue(for: HKUnit.volt()) , value.timeSinceSampleStart)
                            ecgSamples.append(sample)
                            
                        case .done:
                            print("done")
                            
                        }
                    }
                    self.healthStore!.execute(query)
                    print(query)
                }
            healthStore?.execute(ecgQuery)
        print(ecgQuery)
    }


}

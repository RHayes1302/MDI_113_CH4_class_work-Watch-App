//
//  HeartRateViewModel.swift
//  MDI_113_CH4_class_work
//
//  Created by Ramone Hayes on 2/26/26.
//

import Foundation
import HealthKit
import Combine

class HeartRateViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentHearthRate: Int = 0
    @Published var isMonitoring: Bool = false
    @Published var errorMessage: String?
    @Published var authorizationStatus: String = "Not Determined"
    
    // MARK: - Private Properties
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKQuery?
    
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let heartRateUnit = HKUnit.count().unitDivided(by: .minute()) // count is the quantity value divided by minute (Beats Per Minute BPMs)
    
    init() {
        checkAuthorizationStatus()
    }
    
    deinit {
        stopMonitoring()
    }
    
    //MARK: - Auth
    private func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "health kit is not available"
            return
        }
        
        let status = healthStore.authorizationStatus(for: heartRateType)
        
        switch status {
        case .notDetermined:
            self.authorizationStatus = "Not Determined"
        case .sharingDenied:
            self.authorizationStatus = "Denied"
            errorMessage = "Pleas enable heart rate in settings to access this feature"
        case .sharingAuthorized:
            self.authorizationStatus = "Authorized"
        @unknown default:
            self.authorizationStatus = "Unknown"
        }
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "health kit is not available"
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { [weak self] success, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    self.authorizationStatus = "Authorized"
                    self.errorMessage = nil
                } else {
                    self.errorMessage = "Authorization Failed"
                }
            }
        }
    }
    
    // MARK: - Public Methods
    func startMonitorinHeartRate() {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "health kit is not available"
            return
        }
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processSamples(samples: samples, error: error)
        }
        
        query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processSamples(samples: samples, error: error)
        }
        
        heartRateQuery = query
        healthStore.execute(query)
        isMonitoring = true
    }
    
    private func processSamples(samples: [HKSample]?, error: Error?) {
        guard let samples = samples as? [HKQuantitySample], let sample = samples.last else {
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error while getting the samples"
                }
            }
            return
        }
        
        let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit) // double represented in bpms
        
        DispatchQueue.main.async {
            self.currentHearthRate = Int(heartRate)
            self.errorMessage = nil
        }
    }
    
    func stopMonitoring() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
        
        isMonitoring = false
    }
}

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
    @Published var currentHeartRate: Int = 0
    @Published var isMonitoring: Bool = false
    @Published var errorMessage: String?
    @Published var authorizationStatus: String = "Not Determined"
    
    // MARK: - Private Properties
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKQuery?
    
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
    
    init() {
        checkAuthorizationStatus()
    }
    
    deinit {
        stopMonitoring()
    }
    
    // MARK: - Auth
    private func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit is not available"
            return
        }
        
        let status = healthStore.authorizationStatus(for: heartRateType)
        
        switch status {
        case .notDetermined:
            authorizationStatus = "Not Determined"
        case .sharingDenied:
            authorizationStatus = "Denied"
            errorMessage = "Please enable heart rate in settings to access this feature"
        case .sharingAuthorized:
            authorizationStatus = "Authorized"
        @unknown default:
            authorizationStatus = "Unknown"
        }
    }
    
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit is not available"
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.authorizationStatus = "Authorized"
                    self?.errorMessage = nil
                    self?.startMonitoringHeartRate() // FIX: auto-start after authorization
                } else {
                    self?.errorMessage = "Authorization Failed"
                }
            }
        }
    }
    
    // MARK: - Public Methods
    func startMonitoringHeartRate() {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit is not available"
            return
        }
        
        // Shared handler used for both initial fetch and live updates
        let handler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = { [weak self] _, samples, _, _, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let samples = samples as? [HKQuantitySample], let sample = samples.last else { return }
            
            let heartRate = sample.quantity.doubleValue(for: self.heartRateUnit)
            
            DispatchQueue.main.async {
                self.currentHeartRate = Int(heartRate)
                self.errorMessage = nil
            }
        }
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit,
            resultsHandler: handler
        )
        
        // FIX: updateHandler fires every time a new heart rate sample arrives
        query.updateHandler = handler
        
        heartRateQuery = query
        healthStore.execute(query)
        
        DispatchQueue.main.async {
            self.isMonitoring = true
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

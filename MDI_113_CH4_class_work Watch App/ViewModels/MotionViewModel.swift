import Foundation
import Combine
import CoreMotion

class MotionViewModel: ObservableObject {
    // MARK: - Published Props
    // TODO: Add Data Smothing with Avg window function
    //
    @Published var accelerationX: Double = 0.0
    @Published var accelerationY: Double = 0.0
    @Published var accelerationZ: Double = 0.0
    
    @Published var rotationX: Double = 0.0
    @Published var rotationY: Double = 0.0
    @Published var rotationZ: Double = 0.0
    
    @Published var isTracking: Bool = false
    @Published var trackingError: String?
    
    // MARK: - Private Props
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    
    init() {
        setupMotionManager()
    }
    
    deinit {
        stopTracking()
    }
    
    func setupMotionManager() {
        motionManager.deviceMotionUpdateInterval = 0.1 // 10hz
        
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .userInteractive
    }
    
    
    func startTracking() {
        guard motionManager.isDeviceMotionAvailable else {
            trackingError = "Motion Data is Not Available"
            return
        }
        
        motionManager.startDeviceMotionUpdates(to: queue) { [weak self] motionData, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.trackingError = error.localizedDescription
                }
                
                return
            }
            
            guard let data = motionData else { return }
            
            DispatchQueue.main.async {
                self.accelerationX = data.userAcceleration.x
                self.accelerationY = data.userAcceleration.y
                self.accelerationZ = data.userAcceleration.z
                
                self.rotationX = data.rotationRate.x
                self.rotationX = data.rotationRate.y
                self.rotationX = data.rotationRate.z
                
                self.isTracking = true
                self.trackingError = nil
            }
        }
    }
    
    func stopTracking() {
        motionManager.stopDeviceMotionUpdates()
        isTracking = false
    }

}

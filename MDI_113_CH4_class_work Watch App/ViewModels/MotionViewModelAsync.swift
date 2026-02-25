import Foundation
import Combine
import CoreMotion

// This file is the same as motion view model but using async tasks instead of dispatch queues
//

@MainActor
class MotionViewModelAsync: ObservableObject {
    // MARK: - Published Props
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
    private var trackingTask: Task<Void, Never>?
    
    init() {
        setupMotionManager()
    }
    
    func setupMotionManager() {
        motionManager.deviceMotionUpdateInterval = 0.1 // 10hz
    }
    
    // MARK: - Public Methods
    func startTracking() {
        guard motionManager.isDeviceMotionAvailable else {
            trackingError = "Motion Data is Not Available"
            return
        }
        
        trackingTask = Task {
            do {
                for await motionData in motionUpdates() {
                    accelerationX = motionData.userAcceleration.x
                    accelerationY = motionData.userAcceleration.y
                    accelerationZ = motionData.userAcceleration.z
                    
                    rotationX = motionData.rotationRate.x
                    rotationY = motionData.rotationRate.y
                    rotationZ = motionData.rotationRate.z
                    
                    isTracking = true
                    trackingError = nil
                }
            }
        }
    }
    
    func stopTracking() {
        trackingTask?.cancel()
        trackingTask = nil
        motionManager.stopDeviceMotionUpdates()
        isTracking = false
    }
    
    // MARK: - AsyncStream with Continuation
    private func motionUpdates() -> AsyncStream<CMDeviceMotion> {
        AsyncStream { continuation in
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 1
            queue.qualityOfService = .userInteractive
            
            motionManager.startDeviceMotionUpdates(to: queue) { [weak self] motionData, error in
                if let error = error {
                    Task { @MainActor [weak self] in
                        self?.trackingError = error.localizedDescription
                    }
                    continuation.finish()
                    return
                }
                
                guard let data = motionData else { return }
                continuation.yield(data) // returining = yield in this sintax
            }
            
            continuation.onTermination = { [weak self] _ in
                self?.motionManager.stopDeviceMotionUpdates()
            }
        }
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}


import Foundation
import HealthKit
import Combine

// MARK: - SleepData Model
struct SleepData {
    let remSleepSeconds: TimeInterval
    let deepSleepSeconds: TimeInterval
    let coreSleepSeconds: TimeInterval
    let totalSleepSeconds: TimeInterval
    let awakenings: Int
    let sleepScore: Int
    
    // Helper computed properties for display
    var formattedRemSleep: String {
        let hours = Int(remSleepSeconds) / 3600
        let minutes = (Int(remSleepSeconds) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    var formattedDeepSleep: String {
        let hours = Int(deepSleepSeconds) / 3600
        let minutes = (Int(deepSleepSeconds) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    var formattedCoreSleep: String {
        let hours = Int(coreSleepSeconds) / 3600
        let minutes = (Int(coreSleepSeconds) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    var formattedTotalSleep: String {
        let hours = Int(totalSleepSeconds) / 3600
        let minutes = (Int(totalSleepSeconds) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
}

// MARK: - MovementData Model
struct MovementData {
    let stepCount: Int
    let standHours: Int
    let activeEnergyBurned: Double // in kilocalories
    let exerciseMinutes: Int
    let walkingDistance: Double // in meters
    let flightsClimbed: Int
    let movementScore: Int
    
    // Helper computed properties for display
    var formattedActiveEnergy: String {
        return String(format: "%.0f kcal", activeEnergyBurned)
    }
    
    var formattedWalkingDistance: String {
        let kilometers = walkingDistance / 1000
        return String(format: "%.2f km", kilometers)
    }
}

// MARK: - Manager Class
class Manager: ObservableObject {
    // MARK: - Published Properties
    @Published var sleepData: SleepData?
    @Published var movementData: MovementData?
    @Published var sleepArtData: ArtData?
    @Published var movementArtData: ArtData?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Private Properties
    private let sleepProcessor = Sleep()
    private let curatorAI = CuratorAI()
    
    // MARK: - Public Methods
    
    /// Loads sleep and movement data and generates artwork
    func loadSleepData() {
        isLoading = true
        errorMessage = ""
        
        // Request HealthKit authorization first
        sleepProcessor.requestHealthAuthorization { [weak self] success in
            guard success else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "Failed to authorize HealthKit access"
                }
                return
            }
            
            // Fetch sleep data
            self?.sleepProcessor.fetchSleepData { sleepData in
                DispatchQueue.main.async {
                    if let sleepData = sleepData {
                        self?.sleepData = sleepData
                        self?.generateSleepArtwork(for: sleepData)
                    }
                }
            }
            
            // Fetch movement data
            self?.sleepProcessor.fetchMovementData { movementData in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let movementData = movementData {
                        self?.movementData = movementData
                        self?.generateMovementArtwork(for: movementData)
                    } else if self?.sleepData == nil {
                        self?.errorMessage = "Failed to fetch health data"
                    }
                }
            }
        }
    }
    
    /// Refreshes the data
    func refreshData() {
        loadSleepData()
    }
    
    // MARK: - Private Methods
    
    /// Generates artwork based on sleep data
    private func generateSleepArtwork(for sleepData: SleepData) {
        curatorAI.generateSleepArtwork(from: sleepData) { [weak self] artData in
            DispatchQueue.main.async {
                self?.sleepArtData = artData
            }
        }
    }
    
    /// Generates artwork based on movement data
    private func generateMovementArtwork(for movementData: MovementData) {
        curatorAI.generateMovementArtwork(from: movementData) { [weak self] artData in
            DispatchQueue.main.async {
                self?.movementArtData = artData
            }
        }
    }
}



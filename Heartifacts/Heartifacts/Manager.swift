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

// MARK: - StressData Model
struct StressData {
    let heartRateVariability: Double? // ms
    let restingHeartRate: Double? // bpm
    let heartRateSamples: [HKQuantitySample]
    let mindfulnessMinutes: Double? // minutes
    let stressLevel: Double? // 0-10 scale if available
    let collectionDate: Date
}

// MARK: - MovementData Model
struct MovementData {
    let steps: Int
    let activeEnergyBurned: Double? // kcal
    let exerciseMinutes: Double? // minutes
    let standHours: Int? // hours
    let walkingDistance: Double? // meters
    let flightsClimbed: Int?
    let collectionDate: Date
}

// MARK: - CombinedHealthData Model
struct CombinedHealthData {
    let sleepData: SleepData?
    let stressData: StressData?
    let movementData: MovementData?
    let collectionDate: Date
}

// MARK: - Manager Class
class Manager: ObservableObject {
    // MARK: - Published Properties
    @Published var sleepData: SleepData?
    @Published var stressData: StressData?
    @Published var movementData: MovementData?
    @Published var combinedHealthData: CombinedHealthData?
    @Published var sleepArtData: ArtData?
    @Published var movementArtData: ArtData?
    @Published var stressArtData: ArtData?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Private Properties
    private let healthDataProcessor = HealthDataProcessor()
    private let curatorAI = CuratorAI()
    
    // MARK: - Public Methods
    
    /// Loads sleep data and generates artwork
    func loadSleepData() {
        isLoading = true
        errorMessage = ""
        
        // Request HealthKit authorization first
        healthDataProcessor.requestHealthAuthorization { [weak self] success in
            guard success else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "Failed to authorize HealthKit access"
                }
                return
            }
            
            // Fetch sleep data
            self?.healthDataProcessor.fetchSleepData { sleepData in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let sleepData = sleepData {
                        self?.sleepData = sleepData
                        // Generate sleep artwork only
                        self?.curatorAI.generateSleepArtwork(from: sleepData) { artData in
                            DispatchQueue.main.async {
                                self?.sleepArtData = artData
                            }
                        }
                    } else {
                        self?.errorMessage = "Failed to fetch sleep data"
                    }
                }
            }
        }
    }
    
    /// Loads stress data
    func loadStressData() {
        healthDataProcessor.fetchStressData { [weak self] stressData in
            DispatchQueue.main.async {
                self?.stressData = stressData
            }
        }
    }
    
    /// Loads movement data
    func loadMovementData() {
        healthDataProcessor.fetchMovementData { [weak self] movementData in
            DispatchQueue.main.async {
                self?.movementData = movementData
            }
        }
    }
    
    /// Loads all health data (sleep, stress, movement)
    func loadAllHealthData() {
        isLoading = true
        errorMessage = ""
        
        // Request HealthKit authorization for all data types
        healthDataProcessor.requestHealthAuthorization { [weak self] success in
            guard success else {
                DispatchQueue.main.async {
                    self?.isLoading = false
                    self?.errorMessage = "Failed to authorize HealthKit access"
                }
                return
            }
            
            // Fetch all health data in parallel
            self?.healthDataProcessor.fetchAllHealthData { combinedData in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let combinedData = combinedData {
                        self?.sleepData = combinedData.sleepData
                        self?.stressData = combinedData.stressData
                        self?.movementData = combinedData.movementData
                        self?.combinedHealthData = combinedData
                        
                        // Generate all types of artwork
                        self?.generateAllArtwork(combinedData: combinedData)
                    } else {
                        self?.errorMessage = "Failed to fetch health data"
                    }
                }
            }
        }
    }
    
    /// Refreshes the data
    func refreshData() {
        loadAllHealthData()
    }
    
    // MARK: - Private Methods
    
    /// Generates all types of artwork based on available data
    private func generateAllArtwork(combinedData: CombinedHealthData) {
        // Generate sleep artwork
        if let sleepData = combinedData.sleepData {
            curatorAI.generateSleepArtwork(from: sleepData) { [weak self] artData in
                DispatchQueue.main.async {
                    self?.sleepArtData = artData
                }
            }
        }
        
        // Generate movement artwork
        if let movementData = combinedData.movementData {
            curatorAI.generateMovementArtwork(from: movementData) { [weak self] artData in
                DispatchQueue.main.async {
                    self?.movementArtData = artData
                }
            }
        }
        
        // Generate stress artwork
        if let stressData = combinedData.stressData {
            curatorAI.generateStressArtwork(from: stressData) { [weak self] artData in
                DispatchQueue.main.async {
                    self?.stressArtData = artData
                }
            }
        }
    }
}



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

// MARK: - Manager Class
class Manager: ObservableObject {
    // MARK: - Published Properties
    @Published var sleepData: SleepData?
    @Published var aiMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Private Properties
    private let sleepProcessor = Sleep()
    private let curatorAI = CuratorAI()
    
    // MARK: - Public Methods
    
    /// Loads sleep data and generates AI message
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
                    self?.isLoading = false
                    
                    if let sleepData = sleepData {
                        self?.sleepData = sleepData
                        self?.generateAIMessage(for: sleepData)
                    } else {
                        self?.errorMessage = "Failed to fetch sleep data"
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
    
    /// Generates AI message based on sleep data
    private func generateAIMessage(for sleepData: SleepData) {
        let hours = Int(sleepData.totalSleepSeconds) / 3600
        let minutes = (Int(sleepData.totalSleepSeconds) % 3600) / 60
        
        let prompt = """
        My sleep score was \(sleepData.sleepScore). I slept for \(hours) hours and \(minutes) minutes, and I woke up \(sleepData.awakenings) times. 
        REM Sleep: \(sleepData.formattedRemSleep), Deep Sleep: \(sleepData.formattedDeepSleep), Core Sleep: \(sleepData.formattedCoreSleep).
        Generate a short, encouraging message for me based on this sleep data.
        """
        
        curatorAI.generateAIMessage(from: prompt) { [weak self] message in
            DispatchQueue.main.async {
                self?.aiMessage = message
            }
        }
    }
}

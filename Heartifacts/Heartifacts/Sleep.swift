import Foundation
import HealthKit

// MARK: - Sleep Class
class Sleep {
    private let healthStore = HKHealthStore()
    
    // MARK: - Public Methods (Called by Manager)
    
    /// Requests HealthKit authorization for sleep data
    func requestHealthAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            completion(false)
            return
        }
        
        let typesToRead: Set<HKObjectType> = [HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { success, error in
            if success {
                print("HealthKit authorization successful")
                completion(true)
            } else {
                print("HealthKit authorization failed: \(error?.localizedDescription ?? "unknown error")")
                completion(false)
            }
        }
    }
    
    /// Fetches and processes sleep data from HealthKit
    func fetchSleepData(completion: @escaping (SleepData?) -> Void) {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let calendar = Calendar.current
        let now = Date()
        
        let startOfPreviousNight = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now.addingTimeInterval(-86400))!
        let endOfPreviousNight = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfPreviousNight, end: endOfPreviousNight, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] query, samples, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Sleep data query error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let samples = samples as? [HKCategorySample] else {
                print("No sleep samples found")
                completion(nil)
                return
            }
            
            let sleepData = self.processSleepSamples(samples)
            completion(sleepData)
        }
        
        healthStore.execute(query)
    }
    
    // MARK: - Private Methods
    
    /// Processes sleep samples and returns SleepData
    private func processSleepSamples(_ samples: [HKCategorySample]) -> SleepData {
        var remSleepSeconds: TimeInterval = 0
        var deepSleepSeconds: TimeInterval = 0
        var coreSleepSeconds: TimeInterval = 0
        var awakenings = 0
        
        print("Processing \(samples.count) sleep samples")
        
        for sample in samples {
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            let value = sample.value
            
            switch value {
            case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                remSleepSeconds += duration
                
            case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                coreSleepSeconds += duration
                
            case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                deepSleepSeconds += duration
                
            case HKCategoryValueSleepAnalysis.awake.rawValue:
                awakenings += 1
                
            default:
                break
            }
        }
        
        let totalSleepSeconds = deepSleepSeconds + coreSleepSeconds + remSleepSeconds
        let sleepScore = calculateSleepScore(totalSleep: totalSleepSeconds, awakenings: awakenings)
        
        print("Sleep totals - REM: \(remSleepSeconds/3600)h, Deep: \(deepSleepSeconds/3600)h, Core: \(coreSleepSeconds/3600)h, Total: \(totalSleepSeconds/3600)h, Awakenings: \(awakenings)")
        
        return SleepData(
            remSleepSeconds: remSleepSeconds,
            deepSleepSeconds: deepSleepSeconds,
            coreSleepSeconds: coreSleepSeconds,
            totalSleepSeconds: totalSleepSeconds,
            awakenings: awakenings,
            sleepScore: sleepScore
        )
    }
    
    /// Calculates sleep score based on duration and awakenings
    private func calculateSleepScore(totalSleep: TimeInterval, awakenings: Int) -> Int {
        let hoursOfSleep = totalSleep / 3600
        var score = (hoursOfSleep / 8.0) * 80 // Score out of 80 for sleep duration
        score -= Double(awakenings * 5) // Penalize for waking up
        return max(0, min(100, Int(score)))
    }
}

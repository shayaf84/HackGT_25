import Foundation
import HealthKit

// MARK: - HealthDataProcessor Class
class HealthDataProcessor {
    private let healthStore = HKHealthStore()
    
    // MARK: - Public Methods (Called by Manager)
    
    /// Requests HealthKit authorization for all health data types
    func requestHealthAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            completion(false)
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            // Sleep data
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            
            // Stress data
            HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.categoryType(forIdentifier: .mindfulSession)!,
            
            // Movement data
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .appleStandTime)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .flightsClimbed)!
        ]
        
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
    
    /// Fetches and processes stress data from HealthKit
    func fetchStressData(completion: @escaping (StressData?) -> Void) {
        let now = Date()
        let startOf24h = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        
        // Collect heart rate variability (if available)
        collectHeartRateVariability(from: startOf24h, to: now) { [weak self] hrv in
            // Collect resting heart rate
            self?.collectRestingHeartRate(from: startOf24h, to: now) { restingHR in
                // Collect heart rate samples
                self?.collectHeartRateSamples(from: startOf24h, to: now) { heartRateSamples in
                    // Collect mindfulness minutes
                    self?.collectMindfulnessMinutes(from: startOf24h, to: now) { mindfulness in
                        // Collect stress level (if available)
                        self?.collectStressLevel(from: startOf24h, to: now) { stressLevel in
                            let stressData = StressData(
                                heartRateVariability: hrv,
                                restingHeartRate: restingHR,
                                heartRateSamples: heartRateSamples,
                                mindfulnessMinutes: mindfulness,
                                stressLevel: stressLevel,
                                collectionDate: now
                            )
                            completion(stressData)
                        }
                    }
                }
            }
        }
    }
    
    /// Fetches and processes movement data from HealthKit
    func fetchMovementData(completion: @escaping (MovementData?) -> Void) {
        let now = Date()
        let startOf24h = Calendar.current.date(byAdding: .hour, value: -24, to: now)!
        
        // Collect steps
        collectSteps(from: startOf24h, to: now) { [weak self] steps in
            // Collect active energy burned
            self?.collectActiveEnergyBurned(from: startOf24h, to: now) { activeEnergy in
                // Collect exercise minutes
                self?.collectExerciseMinutes(from: startOf24h, to: now) { exerciseMinutes in
                    // Collect stand hours
                    self?.collectStandHours(from: startOf24h, to: now) { standHours in
                        // Collect walking distance
                        self?.collectWalkingDistance(from: startOf24h, to: now) { walkingDistance in
                            // Collect flights climbed
                            self?.collectFlightsClimbed(from: startOf24h, to: now) { flightsClimbed in
                                let movementData = MovementData(
                                    steps: steps,
                                    activeEnergyBurned: activeEnergy,
                                    exerciseMinutes: exerciseMinutes,
                                    standHours: standHours,
                                    walkingDistance: walkingDistance,
                                    flightsClimbed: flightsClimbed,
                                    collectionDate: now
                                )
                                completion(movementData)
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Fetches all health data (sleep, stress, movement) in parallel
    func fetchAllHealthData(completion: @escaping (CombinedHealthData?) -> Void) {
        let group = DispatchGroup()
        var sleepData: SleepData?
        var stressData: StressData?
        var movementData: MovementData?
        
        // Fetch sleep data
        group.enter()
        fetchSleepData { data in
            sleepData = data
            group.leave()
        }
        
        // Fetch stress data
        group.enter()
        fetchStressData { data in
            stressData = data
            group.leave()
        }
        
        // Fetch movement data
        group.enter()
        fetchMovementData { data in
            movementData = data
            group.leave()
        }
        
        // Wait for all data to be fetched
        group.notify(queue: .main) {
            let combinedData = CombinedHealthData(
                sleepData: sleepData,
                stressData: stressData,
                movementData: movementData,
                collectionDate: Date()
            )
            completion(combinedData)
        }
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
    
    // MARK: - Stress Data Collection Methods
    
    /// Collects heart rate variability data - calculates 24-hour average
    private func collectHeartRateVariability(from startDate: Date, to endDate: Date, completion: @escaping (Double?) -> Void) {
        guard let hrvType = HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Get all HRV samples in the 24-hour period and calculate average
        let sampleQuery = HKSampleQuery(sampleType: hrvType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, error in
            if let error = error {
                print("HRV query error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                print("No HRV samples found in 24-hour period")
                completion(nil)
                return
            }
            
            print("Found \(samples.count) HRV samples in 24h")
            
            // Calculate average HRV from all samples
            let totalHRV = samples.reduce(0.0) { total, sample in
                total + sample.quantity.doubleValue(for: HKUnit.secondUnit(with: .milli))
            }
            let averageHRV = totalHRV / Double(samples.count)
            print("24h Average HRV: \(averageHRV) ms")
            completion(averageHRV)
        }
        healthStore.execute(sampleQuery)
    }
    
    /// Collects resting heart rate data - calculates 24-hour average
    private func collectRestingHeartRate(from startDate: Date, to endDate: Date, completion: @escaping (Double?) -> Void) {
        guard let restingHRType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate) else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Get all resting heart rate samples in the 24-hour period and calculate average
        let sampleQuery = HKSampleQuery(sampleType: restingHRType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, error in
            if let error = error {
                print("Resting HR query error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let samples = samples as? [HKQuantitySample], !samples.isEmpty else {
                print("No resting HR samples found in 24-hour period")
                completion(nil)
                return
            }
            
            print("Found \(samples.count) resting HR samples in 24h")
            
            // Calculate average resting heart rate from all samples
            let totalHR = samples.reduce(0.0) { total, sample in
                total + sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            }
            let averageHR = totalHR / Double(samples.count)
            print("24h Average Resting HR: \(averageHR) bpm")
            completion(averageHR)
        }
        healthStore.execute(sampleQuery)
    }
    
    /// Collects heart rate samples
    private func collectHeartRateSamples(from startDate: Date, to endDate: Date, completion: @escaping ([HKQuantitySample]) -> Void) {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            completion([])
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            let heartRateSamples = samples as? [HKQuantitySample] ?? []
            completion(heartRateSamples)
        }
        healthStore.execute(query)
    }
    
    /// Collects mindfulness minutes
    private func collectMindfulnessMinutes(from startDate: Date, to endDate: Date, completion: @escaping (Double?) -> Void) {
        guard let mindfulType = HKCategoryType.categoryType(forIdentifier: .mindfulSession) else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: mindfulType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            let totalMinutes = samples?.reduce(0) { total, sample in
                total + sample.endDate.timeIntervalSince(sample.startDate) / 60
            } ?? 0
            completion(totalMinutes)
        }
        healthStore.execute(query)
    }
    
    /// Collects stress level (if available)
    private func collectStressLevel(from startDate: Date, to endDate: Date, completion: @escaping (Double?) -> Void) {
        // Note: Stress level is not directly available in HealthKit
        // This would need to be calculated from other metrics or user input
        completion(nil)
    }
    
    // MARK: - Movement Data Collection Methods
    
    /// Collects steps data
    private func collectSteps(from startDate: Date, to endDate: Date, completion: @escaping (Int) -> Void) {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let steps = Int(result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)
            completion(steps)
        }
        healthStore.execute(query)
    }
    
    /// Collects active energy burned
    private func collectActiveEnergyBurned(from startDate: Date, to endDate: Date, completion: @escaping (Double?) -> Void) {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let energy = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie())
            completion(energy)
        }
        healthStore.execute(query)
    }
    
    /// Collects exercise minutes
    private func collectExerciseMinutes(from startDate: Date, to endDate: Date, completion: @escaping (Double?) -> Void) {
        guard let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: exerciseType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let minutes = result?.sumQuantity()?.doubleValue(for: HKUnit.minute())
            completion(minutes)
        }
        healthStore.execute(query)
    }
    
    /// Collects stand hours
    private func collectStandHours(from startDate: Date, to endDate: Date, completion: @escaping (Int?) -> Void) {
        guard let standType = HKQuantityType.quantityType(forIdentifier: .appleStandTime) else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: standType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let hours = Int(result?.sumQuantity()?.doubleValue(for: HKUnit.hour()) ?? 0)
            completion(hours)
        }
        healthStore.execute(query)
    }
    
    /// Collects walking distance
    private func collectWalkingDistance(from startDate: Date, to endDate: Date, completion: @escaping (Double?) -> Void) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let distance = result?.sumQuantity()?.doubleValue(for: HKUnit.meter())
            completion(distance)
        }
        healthStore.execute(query)
    }
    
    /// Collects flights climbed
    private func collectFlightsClimbed(from startDate: Date, to endDate: Date, completion: @escaping (Int?) -> Void) {
        guard let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: flightsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let flights = Int(result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)
            completion(flights)
        }
        healthStore.execute(query)
    }
}

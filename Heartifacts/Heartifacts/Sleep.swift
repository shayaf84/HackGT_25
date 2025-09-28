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
    
    // MARK: - Movement Data Methods
    
    /// Fetches movement data from HealthKit
    func fetchMovementData(completion: @escaping (MovementData?) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let group = DispatchGroup()
        var stepCount = 0
        var standHours = 0
        var activeEnergyBurned = 0.0
        var exerciseMinutes = 0
        var walkingDistance = 0.0
        var flightsClimbed = 0
        
        // Fetch step count
        group.enter()
        fetchSteps(from: startOfDay, to: now) { steps in
            stepCount = steps
            group.leave()
        }
        
        // Fetch stand hours
        group.enter()
        fetchStandHours(from: startOfDay, to: now) { hours in
            standHours = hours
            group.leave()
        }
        
        // Fetch active energy burned
        group.enter()
        fetchActiveEnergy(from: startOfDay, to: now) { energy in
            activeEnergyBurned = energy
            group.leave()
        }
        
        // Fetch exercise minutes
        group.enter()
        fetchExerciseMinutes(from: startOfDay, to: now) { minutes in
            exerciseMinutes = minutes
            group.leave()
        }
        
        // Fetch walking distance
        group.enter()
        fetchWalkingDistance(from: startOfDay, to: now) { distance in
            walkingDistance = distance
            group.leave()
        }
        
        // Fetch flights climbed
        group.enter()
        fetchFlightsClimbed(from: startOfDay, to: now) { flights in
            flightsClimbed = flights
            group.leave()
        }
        
        group.notify(queue: .main) {
            let movementScore = self.calculateMovementScore(
                stepCount: stepCount,
                standHours: standHours,
                activeEnergy: activeEnergyBurned,
                exerciseMinutes: exerciseMinutes,
                walkingDistance: walkingDistance,
                flightsClimbed: flightsClimbed
            )
            
            let movementData = MovementData(
                stepCount: stepCount,
                standHours: standHours,
                activeEnergyBurned: activeEnergyBurned,
                exerciseMinutes: exerciseMinutes,
                walkingDistance: walkingDistance,
                flightsClimbed: flightsClimbed,
                movementScore: movementScore
            )
            
            completion(movementData)
        }
    }
    
    // MARK: - Private Movement Data Fetching Methods
    
    private func fetchSteps(from startDate: Date, to endDate: Date, completion: @escaping (Int) -> Void) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let steps = Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            completion(steps)
        }
        healthStore.execute(query)
    }
    
    private func fetchStandHours(from startDate: Date, to endDate: Date, completion: @escaping (Int) -> Void) {
        guard let standType = HKCategoryType.categoryType(forIdentifier: .appleStandHour) else {
            completion(0)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: standType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
            let hours = samples?.count ?? 0
            completion(hours)
        }
        healthStore.execute(query)
    }
    
    private func fetchActiveEnergy(from startDate: Date, to endDate: Date, completion: @escaping (Double) -> Void) {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(0)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let energy = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
            completion(energy)
        }
        healthStore.execute(query)
    }
    
    private func fetchExerciseMinutes(from startDate: Date, to endDate: Date, completion: @escaping (Int) -> Void) {
        guard let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime) else {
            completion(0)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: exerciseType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let minutes = Int(result?.sumQuantity()?.doubleValue(for: .minute()) ?? 0)
            completion(minutes)
        }
        healthStore.execute(query)
    }
    
    private func fetchWalkingDistance(from startDate: Date, to endDate: Date, completion: @escaping (Double) -> Void) {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(0)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let distance = result?.sumQuantity()?.doubleValue(for: .meter()) ?? 0
            completion(distance)
        }
        healthStore.execute(query)
    }
    
    private func fetchFlightsClimbed(from startDate: Date, to endDate: Date, completion: @escaping (Int) -> Void) {
        guard let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) else {
            completion(0)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: flightsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let flights = Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            completion(flights)
        }
        healthStore.execute(query)
    }
    
    private func calculateMovementScore(stepCount: Int, standHours: Int, activeEnergy: Double, exerciseMinutes: Int, walkingDistance: Double, flightsClimbed: Int) -> Int {
        var score = 0
        
        // Step count scoring (0-30 points)
        if stepCount >= 10000 { score += 30 }
        else if stepCount >= 8000 { score += 25 }
        else if stepCount >= 6000 { score += 20 }
        else if stepCount >= 4000 { score += 15 }
        else if stepCount >= 2000 { score += 10 }
        else { score += 5 }
        
        // Stand hours scoring (0-20 points)
        if standHours >= 12 { score += 20 }
        else if standHours >= 10 { score += 15 }
        else if standHours >= 8 { score += 10 }
        else if standHours >= 6 { score += 5 }
        
        // Active energy scoring (0-25 points)
        if activeEnergy >= 500 { score += 25 }
        else if activeEnergy >= 400 { score += 20 }
        else if activeEnergy >= 300 { score += 15 }
        else if activeEnergy >= 200 { score += 10 }
        else if activeEnergy >= 100 { score += 5 }
        
        // Exercise minutes scoring (0-15 points)
        if exerciseMinutes >= 60 { score += 15 }
        else if exerciseMinutes >= 45 { score += 12 }
        else if exerciseMinutes >= 30 { score += 10 }
        else if exerciseMinutes >= 15 { score += 5 }
        
        // Walking distance bonus (0-10 points)
        if walkingDistance >= 5000 { score += 10 }
        else if walkingDistance >= 3000 { score += 7 }
        else if walkingDistance >= 1000 { score += 5 }
        
        return min(100, score)
    }
}

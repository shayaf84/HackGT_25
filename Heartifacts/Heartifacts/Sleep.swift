import SwiftUI
import HealthKit

struct SleepView : View {
    @State private var remSleepSeconds: TimeInterval = 0
    @State private var deepSleepSeconds: TimeInterval = 0
    @State private var coreSleepSeconds: TimeInterval = 0
    @State private var awakenings = 0
    @State private var totalSleepSeconds: TimeInterval = 0
    @State private var processDataCallCount = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("REM Sleep: \(fmt(remSleepSeconds))")
            Text("Deep Sleep: \(fmt(deepSleepSeconds))")
            Text("Core Sleep: \(fmt(coreSleepSeconds))")
            Text("Total Sleep: \(fmt(totalSleepSeconds))")
            Text("Awakenings: \(awakenings)")
            Text("ProcessData calls: \(processDataCallCount)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .onAppear { requestHealthAuthorization()}
    }
    
    
    
    
    let healthStore = HKHealthStore()
    
    
    func requestHealthAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        let typesToRead: Set<HKObjectType> = [HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!]
        
        healthStore.requestAuthorization(toShare: [], read: typesToRead) {
            (success, error) in
            if success {
                fetchSleepData()
            } else {
                print("HealthKit authorization failed")
            }
        }
    }
    
    func fetchSleepData() {
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let calendar = Calendar.current
        let now = Date()
        
        let startOfPreviousNight = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: now.addingTimeInterval(-86400))!
        
        let endOfPreviousNight = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: now)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfPreviousNight, end: endOfPreviousNight, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) {
            (query, samples, error) in
            guard let samples = samples as? [HKCategorySample] else { return }
            processData(samples: samples)
            
        }
        healthStore.execute(query)
        
    }
    
    func processData(samples: [HKCategorySample]) {
        processDataCallCount += 1
        print("=== processData called #\(processDataCallCount) with \(samples.count) samples ===")
        
        // Reset counters before processing new data
        remSleepSeconds = 0
        deepSleepSeconds = 0
        coreSleepSeconds = 0
        awakenings = 0
        totalSleepSeconds = 0
        
        // Remove the restrictive filter - include all sleep data sources
        print("Found \(samples.count) sleep samples")
        
        for sample in samples {
            let source = sample.sourceRevision.source.bundleIdentifier
            let duration = sample.endDate.timeIntervalSince(sample.startDate)
            let value = sample.value
            
            print("Sample: \(sample.startDate) - \(sample.endDate) | Duration: \(duration/3600)h | Value: \(value) | Source: \(source)")
            
            switch value {
            case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
                self.remSleepSeconds += duration
                print("  -> Added to REM: \(duration/3600)h (total now: \(self.remSleepSeconds/3600)h)")
                
            case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
                self.coreSleepSeconds += duration
                print("  -> Added to Core: \(duration/3600)h (total now: \(self.coreSleepSeconds/3600)h)")
                
            case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
                self.deepSleepSeconds += duration
                print("  -> Added to Deep: \(duration/3600)h (total now: \(self.deepSleepSeconds/3600)h)")
                
            case HKCategoryValueSleepAnalysis.awake.rawValue:
                self.awakenings += 1
                print("  -> Added awakening (total now: \(self.awakenings))")
                
            default:
                print("  -> Unknown sleep type: \(value)")
                break
            }
        }
        self.totalSleepSeconds = deepSleepSeconds + coreSleepSeconds + remSleepSeconds
        
        print("Sleep totals - REM: \(remSleepSeconds), Deep: \(deepSleepSeconds), Core: \(coreSleepSeconds), Total: \(totalSleepSeconds)")
        
        // Update UI on main thread
        DispatchQueue.main.async {
            self.remSleepSeconds = self.remSleepSeconds
            self.deepSleepSeconds = self.deepSleepSeconds
            self.coreSleepSeconds = self.coreSleepSeconds
            self.totalSleepSeconds = self.totalSleepSeconds
            self.awakenings = self.awakenings
        }
    }
    
    private func fmt(_ seconds: TimeInterval) -> String {
            let f = DateComponentsFormatter()
            f.allowedUnits = [.hour, .minute]
            f.unitsStyle = .abbreviated
            f.zeroFormattingBehavior = .dropAll
            return f.string(from: seconds) ?? "0m"
    }

    

}

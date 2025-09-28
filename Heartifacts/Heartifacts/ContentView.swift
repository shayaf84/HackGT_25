import SwiftUI
import HealthKit

struct ContentView: View {
    // MARK: - Manager Integration
    @StateObject private var manager = Manager()
    
    // MARK: - Steps Data (keeping existing functionality)
    @State private var stepToday: Int = 0
    @State private var step24h: Int = 0
    @State private var debugText: String = ""
    private let healthStore = HKHealthStore()

    var body: some View {
        VStack(spacing: 16) {
            Text("Heartifacts")
                .font(.title)
            
            // Manager Loading State
            if manager.isLoading {
                Text("Loading...")
            }
            
            // Manager Error State
            if !manager.errorMessage.isEmpty {
                Text("Error: \(manager.errorMessage)")
                    .foregroundColor(.red)
            }
            
            // Manager Sleep Data
            if let sleepData = manager.sleepData {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sleep Data:")
                        .font(.headline)
                    Text("REM Sleep: \(sleepData.formattedRemSleep)")
                    Text("Deep Sleep: \(sleepData.formattedDeepSleep)")
                    Text("Core Sleep: \(sleepData.formattedCoreSleep)")
                    Text("Total Sleep: \(sleepData.formattedTotalSleep)")
                    Text("Awakenings: \(sleepData.awakenings)")
                    Text("Sleep Score: \(sleepData.sleepScore)")
                }
            }
            
            // Generated Artwork
            if let artData = manager.artData {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Museum Artifact")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // Artwork Image
                    AsyncImage(url: URL(string: artData.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                            .shadow(radius: 8)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.5)
                            )
                    }
                    .frame(maxHeight: 500)
                    
                    // Artwork Details
                    VStack(alignment: .leading, spacing: 8) {
                        Text(artData.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(artData.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.horizontal, 8)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
            
            // Steps Data
            VStack(alignment: .leading, spacing: 8) {
                Text("Steps:")
                    .font(.headline)
                Text("Today: \(stepToday)")
                Text("Last 24h: \(step24h)")
            }
            
            // Debug Text
            if !debugText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Debug:")
                        .font(.headline)
                    ScrollView {
                        Text(debugText)
                            .font(.caption)
                    }
                    .frame(height: 100)
                }
            }
            
            // Refresh Button
            Button("Refresh") {
                manager.refreshData()
                requestHealthKitAuth()
            }
        }
        .padding()
        .onAppear {
            manager.loadSleepData()
            requestHealthKitAuth()
        }
    }

    private func requestHealthKitAuth() {
        guard HKHealthStore.isHealthDataAvailable() else {
            append("HealthKit not available")
            return
        }
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else { return }
        let readTypes: Set = [stepType]

        healthStore.requestAuthorization(toShare: [], read: readTypes) { success, error in
            if !success {
                append("Authorization failed: \(error?.localizedDescription ?? "unknown")")
                return
            }
            fetchTodaySteps()
            fetchLast24hSteps()
            dumpSomeStepSamples(limit: 5)
        }
    }

    private func fetchTodaySteps() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let cal = Calendar.current
        let start = cal.startOfDay(for: Date())
        let end = Date()
        append("TODAY window: \(start) → \(end)")

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let q = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let error = error { self.append("Today stats error: \(error.localizedDescription)") }
            let total = Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            DispatchQueue.main.async { self.stepToday = total }
            self.append("Today total = \(total)")
        }
        healthStore.execute(q)
    }

    private func fetchLast24hSteps() {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let end = Date()
        let start = Calendar.current.date(byAdding: .hour, value: -24, to: end)!
        append("24H window: \(start) → \(end)")

        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        let q = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            if let error = error { self.append("24h stats error: \(error.localizedDescription)") }
            let total = Int(result?.sumQuantity()?.doubleValue(for: .count()) ?? 0)
            DispatchQueue.main.async { self.step24h = total }
            self.append("24h total = \(total)")
        }
        healthStore.execute(q)
    }

    private func dumpSomeStepSamples(limit: Int) {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -7, to: end)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        let q = HKSampleQuery(sampleType: stepType, predicate: predicate, limit: limit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { _, samples, error in
            if let error = error { self.append("SampleQuery error: \(error.localizedDescription)") }
            guard let samples = samples as? [HKQuantitySample] else { self.append("No samples"); return }
            for s in samples {
                let v = s.quantity.doubleValue(for: .count())
                self.append("Sample: \(Int(v)) steps | \(s.startDate) – \(s.endDate)")
            }
        }
        healthStore.execute(q)
    }

    private func append(_ line: String) {
        DispatchQueue.main.async { self.debugText += line + "\n" }
    }
}

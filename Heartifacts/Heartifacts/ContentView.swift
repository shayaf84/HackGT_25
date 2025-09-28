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
        ScrollView {
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
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
            }
            
            // Manager Stress Data
            if let stressData = manager.stressData {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Stress & Recovery Data:")
                        .font(.headline)
                    
                    if let hrv = stressData.heartRateVariability {
                        Text("Heart Rate Variability: \(String(format: "%.1f", hrv)) ms")
                            .foregroundColor(hrv > 30 ? .green : hrv > 20 ? .orange : .red)
                    } else {
                        Text("Heart Rate Variability: Not available")
                            .foregroundColor(.gray)
                    }
                    
                    if let restingHR = stressData.restingHeartRate {
                        Text("Resting Heart Rate: \(String(format: "%.0f", restingHR)) bpm")
                    }
                    
                    if let mindfulness = stressData.mindfulnessMinutes {
                        Text("Mindfulness: \(String(format: "%.1f", mindfulness)) min")
                    }
                    
                    Text("Heart Rate Samples: \(stressData.heartRateSamples.count)")
                    
                    if let stressLevel = stressData.stressLevel {
                        Text("Stress Level: \(String(format: "%.1f", stressLevel))/10")
                    } else {
                        Text("Stress Level: Not available")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.green.opacity(0.1))
                )
            }
            
            // Manager Movement Data
            if let movementData = manager.movementData {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Movement Data:")
                        .font(.headline)
                    
                    Text("Steps: \(movementData.steps)")
                    
                    if let activeEnergy = movementData.activeEnergyBurned {
                        Text("Active Energy: \(String(format: "%.0f", activeEnergy)) kcal")
                    }
                    
                    if let exerciseMinutes = movementData.exerciseMinutes {
                        Text("Exercise: \(String(format: "%.0f", exerciseMinutes)) min")
                    }
                    
                    if let standHours = movementData.standHours {
                        Text("Stand Hours: \(standHours)")
                    }
                    
                    if let walkingDistance = movementData.walkingDistance {
                        Text("Walking Distance: \(String(format: "%.2f", walkingDistance/1000)) km")
                    }
                    
                    if let flights = movementData.flightsClimbed {
                        Text("Flights Climbed: \(flights)")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                )
            }
            
            // Combined Health Data Summary
            if let combinedData = manager.combinedHealthData {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Health Summary:")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Sleep Score")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(combinedData.sleepData?.sleepScore ?? 0)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(combinedData.sleepData?.sleepScore ?? 0 >= 80 ? .green : .orange)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("Steps")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(combinedData.movementData?.steps ?? 0)")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("HRV")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if let hrv = combinedData.stressData?.heartRateVariability {
                                Text("\(String(format: "%.0f", hrv))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(hrv > 30 ? .green : .orange)
                            } else {
                                Text("N/A")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.purple.opacity(0.1))
                )
            }
            
            // Sleep Artwork
            if let artData = manager.sleepArtData {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sleep Artifact")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    // Artwork Image
                    AsyncImage(url: URL(string: artData.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                            .shadow(radius: 8)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.5)
                            )
                    }
                    .frame(maxHeight: 400)
                    
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
                        .fill(Color.blue.opacity(0.1))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
            
            // Movement Artwork
            if let artData = manager.movementArtData {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Movement Artifact")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    // Artwork Image
                    AsyncImage(url: URL(string: artData.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                            .shadow(radius: 8)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.5)
                            )
                    }
                    .frame(maxHeight: 400)
                    
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
                        .fill(Color.orange.opacity(0.1))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
            
            // Stress Artwork
            if let artData = manager.stressArtData {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Stress & Recovery Artifact")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    // Artwork Image
                    AsyncImage(url: URL(string: artData.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(12)
                            .shadow(radius: 8)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(1.5)
                            )
                    }
                    .frame(maxHeight: 400)
                    
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
                        .fill(Color.green.opacity(0.1))
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
            
            // Legacy Steps Data (keeping for comparison)
            VStack(alignment: .leading, spacing: 8) {
                Text("Legacy Steps Data:")
                    .font(.headline)
                Text("Today: \(stepToday)")
                Text("Last 24h: \(step24h)")
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
            
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
        }
        .onAppear {
            manager.loadAllHealthData()
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

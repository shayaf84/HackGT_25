import SwiftUI
import HealthKit

struct ContentView: View {
    @State private var stepToday: Int = 0
    @State private var step24h: Int = 0
    @State private var debugText: String = ""
    private let healthStore = HKHealthStore()

    var body: some View {
        VStack(spacing: 16) {
            Text("Steps Today: \(stepToday)").font(.title2).bold()
            Text("Steps Last 24h: \(step24h)").font(.title3)
            ScrollView { Text(debugText).font(.caption.monospaced()).padding(.horizontal) }
        }
        .padding()
        .onAppear { requestHealthKitAuth() }
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

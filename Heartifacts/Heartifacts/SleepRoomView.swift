import HealthKit

let healthStore = HKHealthStore()

func requestHealthKitAuthorization() {
    let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
    healthStore.requestAuthorization(toShare: nil, read: Set([sleepType])) { (success, error) in
        if !success {
            print("Authorization failed!")
        }
    }
}

import SwiftUI

struct SleepRoomView: View {
    // State to hold the message from the AI
    @State private var curatorMessage = "Analyzing your sleep..."

    // Create an instance of your AI
    private let curator = CuratorAI()

    var body: some View {
        VStack(spacing: 20) {
            Text("Heartifacts 🌙")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(curatorMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)

        }
        .padding()
        .onAppear {
            // This is where you trigger the entire process
            curator.analyzeSleep { (message) in
                self.curatorMessage = message
            }
        }
    }
}

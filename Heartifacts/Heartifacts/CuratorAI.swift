import Foundation
import HealthKit

// MARK: - OpenAI Data Models (Required for API communication)
struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
}
struct OpenAIMessage: Codable {
    let role: String
    let content: String
}
struct OpenAIResponse: Codable {
    let choices: [Choice]
}
struct Choice: Codable {
    let message: OpenAIMessage
}


class CuratorAI {
    //
    // ----------------- PASTE YOUR KEY HERE -----------------
    //
    private let apiKey = "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"
    //
    // -------------------------------------------------------
    //
    
    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    // This is the main function you'll call from your view.
    func analyzeSleep(completion: @escaping (String) -> Void) {
        fetchSleepData { (samples) in
            guard let samples = samples, !samples.isEmpty else {
                completion("Could not retrieve sleep data.")
                return
            }
            
            let (score, totalSleep, wakeCount) = self.calculateSleepScore(sleepSamples: samples)
            let hours = Int(totalSleep) / 3600
            let minutes = (Int(totalSleep) % 3600) / 60
            let prompt = "My sleep score was \(score). I slept for \(hours) hours and \(minutes) minutes, and I woke up \(wakeCount) times. Generate a short, encouraging message for me based on this."
            
            self.generateAIMessage(from: prompt, completion: completion)
        }
    }
    
    // This private function handles the actual OpenAI API call.
    private func generateAIMessage(from prompt: String, completion: @escaping (String) -> Void) {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: [
                OpenAIMessage(role: "system", content: "You are a helpful museum curator AI. You analyze health data and provide friendly, encouraging feedback. Keep your responses concise, positive, and under 40 words."),
                OpenAIMessage(role: "user", content: prompt)
            ]
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            DispatchQueue.main.async { completion("Error creating request.") }
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion("API Error.")
                    return
                }
                
                do {
                    let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                    if let messageContent = openAIResponse.choices.first?.message.content {
                        completion(messageContent)
                    } else {
                        completion("Could not parse the curator's message.")
                    }
                } catch {
                    completion("Error decoding response.")
                }
            }
        }
        task.resume()
    }
    
    // This helper function gets data from HealthKit.
    private func fetchSleepData(completion: @escaping ([HKCategorySample]?) -> Void) {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            completion(nil)
            return
        }
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, samples, error) in
            completion(samples as? [HKCategorySample])
        }
        healthStore.execute(query)
    }
    
    // This helper function creates a simple score.
    private func calculateSleepScore(sleepSamples: [HKCategorySample]) -> (score: Int, totalSleep: TimeInterval, wakeCount: Int) {
        var totalSleepTime: TimeInterval = 0
        var wakeUpCount = 0
        
        for sample in sleepSamples {
            // Convert the sample's integer value into a readable sleep stage
            guard let sleepValue = HKCategoryValueSleepAnalysis(rawValue: sample.value) else { continue }
            
            // Use a switch statement to handle all sleep stages
            switch sleepValue {
            case .asleepCore, .asleepDeep, .asleepREM, .asleepUnspecified:
                // Add to total sleep time if the user is in any asleep state
                totalSleepTime += sample.endDate.timeIntervalSince(sample.startDate)
            case .awake:
                // Count the number of times the user woke up
                wakeUpCount += 1
            case .inBed:
                // We can ignore the .inBed time for this calculation
                break
            @unknown default:
                // Handle any future cases Apple might add
                break
            }
        }
        
        let hoursOfSleep = totalSleepTime / 3600
        var score = (hoursOfSleep / 8.0) * 80 // Score out of 80 for sleep duration
        score -= Double(wakeUpCount * 5) // Penalize for waking up
        return (score: max(0, min(100, Int(score))), totalSleep: totalSleepTime, wakeCount: wakeUpCount)
    }
}

import Foundation

// MARK: - DALL-E API Models

struct DALLERequest: Codable {
    let model: String
    let prompt: String
    let n: Int
    let size: String
    let quality: String
    let style: String
}

struct DALLEResponse: Codable {
    let data: [DALLEImage]
    let created: Int
}

struct DALLEImage: Codable {
    let url: String
    let revised_prompt: String?
}

struct APIErrorResponse: Codable {
    let error: APIError
}

struct APIError: Codable {
    let message: String
    let type: String?
    let code: String?
}

// MARK: - ArtData Model
struct ArtData {
    let title: String
    let description: String
    let imageURL: String
    let sleepScore: Int
    let generatedDate: Date
}

// MARK: - CuratorAI Class
class CuratorAI {
    // MARK: - Private Properties
    private let apiKey: String
    private let dalleURL = URL(string: "https://api.openai.com/v1/images/generations")!
    
    // MARK: - Initialization
    init() {
        // Load API key from Config.plist
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let key = plist["OpenAI_API_Key"] as? String {
            self.apiKey = key
        } else {
            // Fallback for development - replace with your actual key
            self.apiKey = "YOUR_API_KEY_HERE"
            print("⚠️ WARNING: Could not load API key from Config.plist. Using placeholder.")
        }
    }
    
    // MARK: - Public Methods (Called by Manager)
    
    /// Generates artwork based on sleep data
    func generateSleepArtwork(from sleepData: SleepData, completion: @escaping (ArtData?) -> Void) {
        let prompt = createSleepPrompt(from: sleepData)
        generateArtwork(prompt: prompt, category: "Sleep", sleepScore: sleepData.sleepScore, completion: completion)
    }
    
    /// Generates artwork based on movement data
    func generateMovementArtwork(from movementData: MovementData, completion: @escaping (ArtData?) -> Void) {
        let prompt = createMovementPrompt(from: movementData)
        generateArtwork(prompt: prompt, category: "Movement", sleepScore: 0, completion: completion)
    }
    
    /// Generates artwork based on stress data
    func generateStressArtwork(from stressData: StressData, completion: @escaping (ArtData?) -> Void) {
        let prompt = createStressPrompt(from: stressData)
        generateArtwork(prompt: prompt, category: "Stress & Recovery", sleepScore: 0, completion: completion)
    }
    
    // MARK: - Private Methods
    
    /// Creates a detailed prompt for sleep data
    private func createSleepPrompt(from sleepData: SleepData) -> String {
        let totalHours = sleepData.totalSleepSeconds / 3600
        let remHours = sleepData.remSleepSeconds / 3600
        let deepHours = sleepData.deepSleepSeconds / 3600
        let coreHours = sleepData.coreSleepSeconds / 3600
        
        let sleepQuality = sleepData.sleepScore >= 80 ? "excellent" : sleepData.sleepScore >= 60 ? "good" : "poor"
        let awakenings = sleepData.awakenings
        
        return """
        Create a beautiful, ethereal digital artwork representing sleep and rest. The piece should embody the concept of peaceful slumber and nocturnal tranquility. 
        
        Sleep Data: \(String(format: "%.1f", totalHours)) hours total sleep, \(String(format: "%.1f", remHours))h REM, \(String(format: "%.1f", deepHours))h deep, \(String(format: "%.1f", coreHours))h core sleep, \(awakenings) awakenings, \(sleepQuality) quality.
        
        Visual style: Soft, dreamy colors with blues, purples, and silvers. Abstract forms suggesting clouds, waves, or gentle flowing patterns. Ethereal, otherworldly atmosphere. Museum-quality digital art with sophisticated composition and lighting.
        
        The artwork should feel like a window into the subconscious mind during rest, with flowing, organic shapes that suggest the different stages of sleep. Use a palette of deep midnight blues, soft lavender, and shimmering silver highlights.
        """
    }
    
    /// Creates a detailed prompt for movement data
    private func createMovementPrompt(from movementData: MovementData) -> String {
        let steps = movementData.steps
        let energy = movementData.activeEnergyBurned ?? 0
        let exercise = movementData.exerciseMinutes ?? 0
        
        let activityLevel = steps > 10000 ? "highly active" : steps > 5000 ? "moderately active" : "low activity"
        
        return """
        Create a dynamic, energetic digital artwork representing physical movement and vitality. The piece should capture the essence of human motion and energy.
        
        Movement Data: \(steps) steps, \(String(format: "%.0f", energy)) calories burned, \(String(format: "%.0f", exercise)) minutes exercise, \(activityLevel) day.
        
        Visual style: Bold, energetic colors with oranges, reds, and golds. Dynamic, flowing lines suggesting motion and energy. Abstract forms representing footsteps, heartbeats, or energy waves. Museum-quality digital art with strong composition and vibrant lighting.
        
        The artwork should feel alive and energetic, with flowing lines and dynamic shapes that suggest movement, growth, and vitality. Use a palette of warm oranges, bright reds, and golden yellows with energetic, flowing compositions.
        """
    }
    
    /// Creates a detailed prompt for stress data
    private func createStressPrompt(from stressData: StressData) -> String {
        let hrv = stressData.heartRateVariability ?? 0
        let restingHR = stressData.restingHeartRate ?? 0
        let mindfulness = stressData.mindfulnessMinutes ?? 0
        
        let stressLevel = hrv > 30 ? "low stress" : hrv > 20 ? "moderate stress" : "high stress"
        
        return """
        Create a calming, meditative digital artwork representing stress relief and inner peace. The piece should embody tranquility, balance, and emotional well-being.
        
        Stress Data: \(String(format: "%.1f", hrv)) ms HRV, \(String(format: "%.0f", restingHR)) bpm resting HR, \(String(format: "%.1f", mindfulness)) min mindfulness, \(stressLevel) level.
        
        Visual style: Calming, zen-like colors with greens, teals, and soft whites. Gentle, flowing patterns suggesting breathing, meditation, or natural harmony. Abstract forms representing balance and inner peace. Museum-quality digital art with serene composition and soft lighting.
        
        The artwork should feel peaceful and restorative, with gentle curves and soft gradients that suggest breathing, meditation, and emotional balance. Use a palette of soft greens, calming teals, and pure whites with flowing, organic compositions.
        """
    }
    
    /// Makes the actual API call to DALL-E
    private func generateArtwork(prompt: String, category: String, sleepScore: Int, completion: @escaping (ArtData?) -> Void) {
        // Check if API key is configured
        if apiKey == "YOUR_API_KEY_HERE" {
            print("⚠️ API key not configured. Please set up Config.plist with your OpenAI API key.")
            completion(nil)
            return
        }
        
        let request = DALLERequest(
            model: "dall-e-3",
            prompt: prompt,
            n: 1,
            size: "1024x1024",
            quality: "hd",
            style: "vivid"
        )
        
        var urlRequest = URLRequest(url: dalleURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            print("Error encoding request: \(error)")
                completion(nil) 
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("API Error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw API Response: \(responseString)")
            }
            
            // Check HTTP status code
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("API returned error status: \(httpResponse.statusCode)")
                    completion(nil)
                    return
                }
            }
            
            do {
                let response = try JSONDecoder().decode(DALLEResponse.self, from: data)
                
                if let imageData = response.data.first {
                        let artData = ArtData(
                        title: "\(category) Artifact",
                        description: self.createDescription(for: category, sleepScore: sleepScore),
                            imageURL: imageData.url,
                        sleepScore: sleepScore,
                            generatedDate: Date()
                        )
                    
                    DispatchQueue.main.async {
                        completion(artData)
                    }
                } else {
                    print("No image data in response")
                    completion(nil)
                }
            } catch {
                print("Error decoding response: \(error)")
                
                // Try to decode as error response
                if let errorResponse = try? JSONDecoder().decode(APIErrorResponse.self, from: data) {
                    print("API Error Response: \(errorResponse)")
                }
                
                completion(nil)
            }
        }.resume()
    }
    
    /// Creates a description for the artwork
    private func createDescription(for category: String, sleepScore: Int) -> String {
        switch category {
        case "Sleep":
            if sleepScore >= 80 {
                return "A masterpiece of restful tranquility, capturing the essence of deep, restorative sleep with ethereal beauty and peaceful harmony."
            } else if sleepScore >= 60 {
                return "A gentle representation of sleep's embrace, showing the delicate balance between rest and wakefulness in soft, flowing forms."
        } else {
                return "An abstract exploration of sleep's challenges, revealing the complex patterns of rest and restoration in dreamlike imagery."
            }
        case "Movement":
            return "A dynamic celebration of human vitality, capturing the energy and rhythm of physical activity in bold, flowing compositions."
        case "Stress & Recovery":
            return "A meditative journey into inner peace, representing the delicate balance of stress and recovery through calming, harmonious forms."
        default:
            return "A unique digital artifact representing your personal health journey, created through the intersection of data and artistic vision."
        }
    }
}

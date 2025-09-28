import Foundation

// MARK: - DALL-E Data Models
struct DALLERequest: Codable {
    let model: String
    let prompt: String
    let n: Int
    let size: String
    let response_format: String
}

struct DALLEImageResponse: Codable {
    let data: [DALLEImageData]
}

struct DALLEImageData: Codable {
    let url: String
    let revised_prompt: String?
}

// MARK: - ArtData Model
struct ArtData {
    let imageURL: String
    let title: String
    let description: String
    let sleepScore: Int
    let generatedDate: Date
}

// MARK: - CuratorAI Class
class CuratorAI {
    // MARK: - Private Properties
    private let apiKey = "API_KEY"
    private let dalleURL = URL(string: "https://api.openai.com/v1/images/generations")!
    
    // MARK: - Public Methods (Called by Manager)
    
    /// Generates artwork based on sleep data
    func generateSleepArtwork(from sleepData: SleepData, completion: @escaping (ArtData?) -> Void) {
        let prompt = createArtPrompt(from: sleepData)
        
        var request = URLRequest(url: dalleURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = DALLERequest(
            model: "dall-e-3",
            prompt: prompt,
            n: 1,
            size: "1024x1024",
            response_format: "url"
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            DispatchQueue.main.async { 
                completion(nil) 
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                
                do {
                    let dalleResponse = try JSONDecoder().decode(DALLEImageResponse.self, from: data)
                    if let imageData = dalleResponse.data.first {
                        let artData = ArtData(
                            imageURL: imageData.url,
                            title: self.generateArtTitle(from: sleepData),
                            description: self.generateArtDescription(from: sleepData),
                            sleepScore: sleepData.sleepScore,
                            generatedDate: Date()
                        )
                        completion(artData)
                    } else {
                        completion(nil)
                    }
                } catch {
                    print("DALL-E API Error: \(error)")
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    /// Generates artwork based on movement data
    func generateMovementArtwork(from movementData: MovementData, completion: @escaping (ArtData?) -> Void) {
        let prompt = createMovementArtPrompt(from: movementData)
        
        var request = URLRequest(url: dalleURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = DALLERequest(
            model: "dall-e-3",
            prompt: prompt,
            n: 1,
            size: "1024x1024",
            response_format: "url"
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            DispatchQueue.main.async { 
                completion(nil) 
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                
                do {
                    let dalleResponse = try JSONDecoder().decode(DALLEImageResponse.self, from: data)
                    if let imageData = dalleResponse.data.first {
                        let artData = ArtData(
                            imageURL: imageData.url,
                            title: self.generateMovementArtTitle(from: movementData),
                            description: self.generateMovementArtDescription(from: movementData),
                            sleepScore: 0, // Movement data doesn't have a score, using 0 as placeholder
                            generatedDate: Date()
                        )
                        completion(artData)
                    } else {
                        completion(nil)
                    }
                } catch {
                    print("DALL-E API Error: \(error)")
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    /// Generates artwork based on stress and mindfulness data
    func generateStressArtwork(from stressData: StressData, completion: @escaping (ArtData?) -> Void) {
        let prompt = createStressArtPrompt(from: stressData)
        
        var request = URLRequest(url: dalleURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = DALLERequest(
            model: "dall-e-3",
            prompt: prompt,
            n: 1,
            size: "1024x1024",
            response_format: "url"
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            DispatchQueue.main.async { 
                completion(nil) 
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                
                do {
                    let dalleResponse = try JSONDecoder().decode(DALLEImageResponse.self, from: data)
                    if let imageData = dalleResponse.data.first {
                        let artData = ArtData(
                            imageURL: imageData.url,
                            title: self.generateStressArtTitle(from: stressData),
                            description: self.generateStressArtDescription(from: stressData),
                            sleepScore: 0, // Stress data doesn't have a score, using 0 as placeholder
                            generatedDate: Date()
                        )
                        completion(artData)
                    } else {
                        completion(nil)
                    }
                } catch {
                    print("DALL-E API Error: \(error)")
                    completion(nil)
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Private Methods
    
    /// Creates an art prompt based on sleep data
    private func createArtPrompt(from sleepData: SleepData) -> String {
        let hours = Int(sleepData.totalSleepSeconds) / 3600
        let minutes = (Int(sleepData.totalSleepSeconds) % 3600) / 60
        
        var prompt = "A museum-quality artwork representing sleep data. Do not use words in any part of the image"
        
        // Base the art style on sleep quality
        if sleepData.sleepScore >= 80 {
            prompt += "Create a vibrant, energetic painting with bright colors and flowing lines, representing excellent sleep quality. Make lucious landscapes with beautiful scenes and heaven-like qualities. "
        } else if sleepData.sleepScore >= 60 {
            prompt += "Create a balanced, harmonious artwork with warm colors and gentle curves, representing good sleep quality. "
        } else {
            prompt += "Create a more subdued, contemplative piece with cooler tones and fragmented elements, representing sleep that needs improvement. Add natural disaster elements such as asteroids and volcanoes. "
        }
        
        // Add specific elements based on sleep data
        prompt += "Include visual elements representing: "
        prompt += "\(hours) hours and \(minutes) minutes of sleep, "
        prompt += "\(sleepData.awakenings) awakenings, "
        prompt += "REM sleep (\(sleepData.formattedRemSleep)), deep sleep (\(sleepData.formattedDeepSleep)), and core sleep (\(sleepData.formattedCoreSleep)). "
        
        prompt += "The artwork should be museum-worthy, abstract or semi-abstract, and suitable for display in a health and wellness museum. "
        prompt += "Use artistic techniques like brushstrokes, color gradients, and symbolic representations of sleep stages. Use redder, more orange hues for a lack of sleep and green hues for good sleep"
        
        return prompt
    }
    
    /// Generates an art title based on sleep data
    private func generateArtTitle(from sleepData: SleepData) -> String {
        let hours = Int(sleepData.totalSleepSeconds) / 3600
        
        if sleepData.sleepScore >= 80 {
            return "Tranquil Dreams - \(hours) Hours"
        } else if sleepData.sleepScore >= 60 {
            return "Restful Night - \(hours) Hours"
        } else {
            return "Seeking Serenity - \(hours) Hours"
        }
    }
    
    /// Generates an art description based on sleep data
    private func generateArtDescription(from sleepData: SleepData) -> String {
        let hours = Int(sleepData.totalSleepSeconds) / 3600
        let minutes = (Int(sleepData.totalSleepSeconds) % 3600) / 60
        
        var description = "Sleep Score: \(sleepData.sleepScore)/100\n"
        description += "Total Sleep: \(hours)h \(minutes)m\n"
        description += "REM: \(sleepData.formattedRemSleep) | Deep: \(sleepData.formattedDeepSleep) | Core: \(sleepData.formattedCoreSleep)\n"
        description += "Awakenings: \(sleepData.awakenings)\n\n"
        
        if sleepData.sleepScore >= 80 {
            description += "This artwork celebrates excellent sleep quality with vibrant, flowing elements representing deep restorative rest."
        } else if sleepData.sleepScore >= 60 {
            description += "This piece reflects good sleep patterns with balanced, harmonious visual elements."
        } else {
            description += "This contemplative work represents sleep that could benefit from improved habits and routines."
        }
        
        return description
    }
    
    /// Creates an art prompt based on movement data
    private func createMovementArtPrompt(from movementData: MovementData) -> String {
        var prompt = "A museum-quality artwork representing movement and activity data. Do not use words in any part of the image. Make sure the image includes imagery of running, walking, stairs, energy, and anything movement related. "
        
        // Base the art style on movement quality
        if movementData.steps >= 10000 {
            prompt += "Create a vibrant, energetic painting with bright colors and dynamic movement, representing excellent activity levels. Show powerful athletes, mountain climbers, and energetic scenes with flowing motion and strength. "
        } else if movementData.steps >= 5000 {
            prompt += "Create a balanced, harmonious artwork with warm colors and gentle movement, representing good activity levels. Show people walking, light exercise, and moderate activity with smooth, flowing lines. "
        } else {
            prompt += "Create a more subdued, static piece with cooler tones and limited movement, representing activity that needs improvement. Show sedentary scenes, stillness, and lack of motion with fragmented, disconnected elements. "
        }
        
        // Add specific elements based on movement data
        prompt += "Include visual elements representing: "
        prompt += "\(movementData.steps) steps taken, "
        if let standHours = movementData.standHours {
            prompt += "\(standHours) hours standing, "
        }
        if let activeEnergy = movementData.activeEnergyBurned {
            prompt += "\(String(format: "%.0f", activeEnergy)) calories burned, "
        }
        if let exerciseMinutes = movementData.exerciseMinutes {
            prompt += "\(String(format: "%.0f", exerciseMinutes)) minutes of exercise, "
        }
        if let walkingDistance = movementData.walkingDistance {
            prompt += "\(String(format: "%.2f", walkingDistance/1000)) km walked, "
        }
        if let flights = movementData.flightsClimbed {
            prompt += "\(flights) flights climbed. "
        }
        
        prompt += "The artwork should be museum-worthy and suitable for display in a contemporary or modern art museum. Make the art more minimalistic without too much complexity and do not use words or numbers or other written elements. "
        prompt += "Use artistic techniques like brushstrokes, color gradients, and symbolic representations of movement and energy. Use green and blue hues for good movement and red/orange hues for poor movement."
        
        return prompt
    }
    
    /// Generates an art title based on movement data
    private func generateMovementArtTitle(from movementData: MovementData) -> String {
        if movementData.steps >= 10000 {
            return "Powerful Motion - \(movementData.steps) Steps"
        } else if movementData.steps >= 5000 {
            return "Active Day - \(movementData.steps) Steps"
        } else {
            return "Seeking Energy - \(movementData.steps) Steps"
        }
    }
    
    /// Generates an art description based on movement data
    private func generateMovementArtDescription(from movementData: MovementData) -> String {
        var description = "Steps: \(movementData.steps)\n"
        if let standHours = movementData.standHours {
            description += "Stand Hours: \(standHours)\n"
        }
        if let activeEnergy = movementData.activeEnergyBurned {
            description += "Active Energy: \(String(format: "%.0f", activeEnergy)) kcal\n"
        }
        if let exerciseMinutes = movementData.exerciseMinutes {
            description += "Exercise: \(String(format: "%.0f", exerciseMinutes)) min\n"
        }
        if let walkingDistance = movementData.walkingDistance {
            description += "Walking Distance: \(String(format: "%.2f", walkingDistance/1000)) km\n"
        }
        if let flights = movementData.flightsClimbed {
            description += "Flights Climbed: \(flights)\n"
        }
        description += "\n"
        
        if movementData.steps >= 10000 {
            description += "This artwork celebrates excellent activity levels with vibrant, dynamic elements representing powerful movement and energy."
        } else if movementData.steps >= 5000 {
            description += "This piece reflects good activity patterns with balanced, harmonious visual elements representing healthy movement."
        } else {
            description += "This contemplative work represents activity that could benefit from increased movement and exercise."
        }
        
        return description
    }
    
    /// Creates an art prompt based on stress and mindfulness data
    private func createStressArtPrompt(from stressData: StressData) -> String {
        var prompt = "A museum-quality artwork representing stress, recovery, and mindfulness data. Do not use words in any part of the image. Focus on heart rate, breathing, meditation, and emotional states. "
        
        // Determine art style based on HRV and mindfulness
        let hasGoodHRV = stressData.heartRateVariability ?? 0 > 30
        let hasMindfulness = (stressData.mindfulnessMinutes ?? 0) > 10
        
        if hasGoodHRV && hasMindfulness {
            prompt += "Create a serene, peaceful artwork with cool blues, greens, and soft purples, representing excellent stress management and mindfulness. Show calm waters, gentle clouds, and meditative scenes with flowing, organic shapes. "
        } else if hasGoodHRV || hasMindfulness {
            prompt += "Create a balanced artwork with mixed warm and cool tones, representing moderate stress management. Show transitional scenes between chaos and calm, with some stability and some tension. "
        } else {
            prompt += "Create a more intense, chaotic artwork with warmer, more aggressive colors like reds and oranges, representing high stress and need for mindfulness. Show turbulent scenes, stormy weather, and fragmented, anxious elements. "
        }
        
        // Add specific elements based on stress data
        prompt += "Include visual elements representing: "
        if let hrv = stressData.heartRateVariability {
            prompt += "Heart rate variability of \(String(format: "%.1f", hrv)) ms, "
        }
        if let restingHR = stressData.restingHeartRate {
            prompt += "resting heart rate of \(String(format: "%.0f", restingHR)) bpm, "
        }
        if let mindfulness = stressData.mindfulnessMinutes {
            prompt += "\(String(format: "%.1f", mindfulness)) minutes of mindfulness, "
        }
        prompt += "and overall stress levels. "
        
        prompt += "The artwork should be museum-worthy and suitable for display in a wellness and mental health museum. "
        prompt += "Use artistic techniques like color psychology, organic shapes, and symbolic representations of heart rhythms and breathing patterns. Focus on the emotional and physiological aspects of stress and recovery."
        
        return prompt
    }
    
    /// Generates an art title based on stress data
    private func generateStressArtTitle(from stressData: StressData) -> String {
        let hasGoodHRV = stressData.heartRateVariability ?? 0 > 30
        let hasMindfulness = (stressData.mindfulnessMinutes ?? 0) > 10
        
        if hasGoodHRV && hasMindfulness {
            return "Inner Peace - \(String(format: "%.0f", stressData.heartRateVariability ?? 0))ms HRV"
        } else if hasGoodHRV || hasMindfulness {
            return "Balanced Mind - \(String(format: "%.0f", stressData.heartRateVariability ?? 0))ms HRV"
        } else {
            return "Seeking Calm - \(String(format: "%.0f", stressData.heartRateVariability ?? 0))ms HRV"
        }
    }
    
    /// Generates an art description based on stress data
    private func generateStressArtDescription(from stressData: StressData) -> String {
        var description = ""
        
        if let hrv = stressData.heartRateVariability {
            description += "HRV: \(String(format: "%.1f", hrv)) ms\n"
        }
        if let restingHR = stressData.restingHeartRate {
            description += "Resting HR: \(String(format: "%.0f", restingHR)) bpm\n"
        }
        if let mindfulness = stressData.mindfulnessMinutes {
            description += "Mindfulness: \(String(format: "%.1f", mindfulness)) min\n"
        }
        description += "Heart Rate Samples: \(stressData.heartRateSamples.count)\n\n"
        
        let hasGoodHRV = stressData.heartRateVariability ?? 0 > 30
        let hasMindfulness = (stressData.mindfulnessMinutes ?? 0) > 10
        
        if hasGoodHRV && hasMindfulness {
            description += "This artwork celebrates excellent stress management and mindfulness practices with serene, flowing elements representing inner peace and recovery."
        } else if hasGoodHRV || hasMindfulness {
            description += "This piece reflects balanced stress management with mixed visual elements representing both challenges and moments of calm."
        } else {
            description += "This contemplative work represents stress levels that could benefit from mindfulness practices and stress management techniques."
        }
        
        return description
    }
}

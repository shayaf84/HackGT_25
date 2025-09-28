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
    private let apiKey = "apikey"
    private let dalleURL = URL(string: "https://api.openai.com/v1/images/generations")!
    
    // MARK: - Public Methods (Called by Manager)
    
    /// Generates artwork based on sleep data
    func generateSleepArtwork(from sleepData: SleepData, completion: @escaping (ArtData?) -> Void) {
        let prompt = createSleepArtPrompt(from: sleepData)
        
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
                            sleepScore: movementData.movementScore,
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
    private func createSleepArtPrompt(from sleepData: SleepData) -> String {
        let hours = Int(sleepData.totalSleepSeconds) / 3600
        let minutes = (Int(sleepData.totalSleepSeconds) % 3600) / 60
        
        var prompt = "A museum-quality artwork representing sleep data. Do not use ANY WORDS OR NUMBERS in any part of the image. Make sure the image includes imagery of beds, sheep, clouds, and anything sleep related. "
        
        // Base the art style on sleep quality
        if sleepData.sleepScore >= 80 {
            prompt += "Create a vibrant, energetic painting with bright colors and flowing lines, repre senting excellent sleep quality. Make lucious landscapes with beautiful scenes and heaven-like qualities. "
        } else if sleepData.sleepScore >= 60 {
            prompt += "Create a balanced, harmonious artwork with warm colors and gentle curves, representing good sleep quality. "
        } else {
            prompt += "Create a more subdued, contemplative piece with cooler tones and fragmented elements, representing sleep that needs improvement. Add natural disaster elements such as asteroids and volcanoes. DO NOT INCLUDE IMAGES OF DEATH AND UPSETTING IMAGES. "
        }
        
        // Add specific elements based on sleep data
        prompt += "Include visual elements representing: "
        prompt += "\(hours) hours and \(minutes) minutes of sleep, "
        prompt += "\(sleepData.awakenings) awakenings, "
        prompt += "REM sleep (\(sleepData.formattedRemSleep)), deep sleep (\(sleepData.formattedDeepSleep)), and core sleep (\(sleepData.formattedCoreSleep)). "
        
        prompt += "The artwork should be museum-worthy and suitable for display in a contemporary or modern art museum. Make the art more minimalistic without too much complexity and do not use words or nubmers or other written elements. "
        prompt += "Use artistic techniques like brushstrokes, color gradients, and symbolic representations of sleep stages. Use redder, more orange hues for a lack of sleep and green hues for good sleep "
        
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
        var prompt = "A museum-quality artwork representing movement and activity data. Do not use ANY WORDS OR NUMBERS in any part of the image. Make sure the image includes imagery of running, walking, stairs, energy, and anything movement related. "
        
        // Base the art style on movement quality
        if movementData.movementScore >= 80 {
            prompt += "Create a vibrant, energetic painting with bright colors and dynamic movement, representing excellent activity levels. Show powerful athletes, mountain climbers, and energetic scenes with flowing motion and strength. "
        } else if movementData.movementScore >= 60 {
            prompt += "Create a balanced, harmonious artwork with warm colors and gentle movement, representing good activity levels. Show people walking, light exercise, and moderate activity with smooth, flowing lines. "
        } else {
            prompt += "Create a more subdued, static piece with cooler tones and limited movement, representing activity that needs improvement. Show sedentary scenes, stillness, and lack of motion with fragmented, disconnected elements. "
        }
        
        // Add specific elements based on movement data
        prompt += "Include visual elements representing: "
        prompt += "\(movementData.stepCount) steps taken, "
        prompt += "\(movementData.standHours) hours standing, "
        prompt += "\(movementData.formattedActiveEnergy) burned, "
        prompt += "\(movementData.exerciseMinutes) minutes of exercise, "
        prompt += "\(movementData.formattedWalkingDistance) walked, and "
        prompt += "\(movementData.flightsClimbed) flights climbed. "
        
        prompt += "The artwork should be museum-worthy and suitable for display in a contemporary or modern art museum. Make the art more minimalistic without too much complexity and do not use words or nubmers or other written elements. "
        prompt += "Use artistic techniques like brushstrokes, color gradients, and symbolic representations of movement and energy. Use green and blue hues for good movement and red/orange hues for poor movement."
        
        return prompt
    }
    
    /// Generates an art title based on movement data
    private func generateMovementArtTitle(from movementData: MovementData) -> String {
        if movementData.movementScore >= 80 {
            return "Powerful Motion - \(movementData.stepCount) Steps"
        } else if movementData.movementScore >= 60 {
            return "Active Day - \(movementData.stepCount) Steps"
        } else {
            return "Seeking Energy - \(movementData.stepCount) Steps"
        }
    }
    
    /// Generates an art description based on movement data
    private func generateMovementArtDescription(from movementData: MovementData) -> String {
        var description = "Movement Score: \(movementData.movementScore)/100\n"
        description += "Steps: \(movementData.stepCount)\n"
        description += "Stand Hours: \(movementData.standHours)\n"
        description += "Active Energy: \(movementData.formattedActiveEnergy)\n"
        description += "Exercise: \(movementData.exerciseMinutes) min\n"
        description += "Distance: \(movementData.formattedWalkingDistance)\n"
        description += "Flights: \(movementData.flightsClimbed)\n\n"
        
        if movementData.movementScore >= 80 {
            description += "This artwork celebrates excellent activity levels with vibrant, dynamic elements representing powerful movement and energy."
        } else if movementData.movementScore >= 60 {
            description += "This piece reflects good activity patterns with balanced, harmonious visual elements representing healthy movement."
        } else {
            description += "This contemplative work represents activity that could benefit from increased movement and exercise."
        }
        
        return description
    }
}

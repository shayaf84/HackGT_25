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
    
    /// Returns a random sophisticated artistic style prompt with Midjourney-level detail
    private func getRandomArtisticStyle() -> String {
        let styles = [
            // Van Gogh Impressionism - Enhanced with Midjourney techniques
            "Masterpiece oil painting in the style of Vincent van Gogh's late 1880s impressionist period::3, featuring thick, expressive impasto brushstrokes::2, swirling, dynamic patterns::2, and vibrant, saturated color palette::1. Use bold, visible brushwork with rich, saturated colors and intense emotional energy. The painting should have characteristic van Gogh texture and movement, with swirling, flowing lines and dramatic color contrasts. Professional museum-quality execution with authentic artistic techniques --no digital art, no AI-generated appearance, no computer graphics. ",
            
            // MOMA Contemporary - Enhanced with Midjourney techniques
            "Contemporary museum-quality abstract artwork::3, sophisticated geometric composition::2, bold, refined color relationships::2, and professional gallery execution::1. Clean, precise techniques with subtle gradients and polished artistic execution. The piece should have the refined, gallery-ready quality of works found in the Museum of Modern Art, with contemporary artistic sensibilities and modern visual language. Professional museum presentation --no digital art, no AI-generated appearance, no computer graphics. ",
            
            // Monet Water Lilies Style - Enhanced with Midjourney techniques
            "Masterpiece oil painting in the style of Claude Monet's water lilies series::3, featuring soft, atmospheric brushwork::2, gentle color transitions::2, and ethereal, dreamlike quality::1. Use delicate, layered brushstrokes with subtle color harmonies and peaceful, contemplative beauty. The painting should have characteristic Monet softness and natural light, with flowing, organic forms and harmonious color relationships. Professional museum-quality execution --no digital art, no AI-generated appearance, no computer graphics. ",
            
            // Rothko Color Field - Enhanced with Midjourney techniques
            "Masterpiece color field painting in the style of Mark Rothko::3, featuring large, simplified forms::2, rich, contemplative color relationships::2, and meditative, spiritual quality::1. Use smooth, even brushwork with deep, saturated colors and subtle color transitions. The piece should have characteristic Rothko simplicity and emotional depth, with large, flat color areas and sophisticated color harmonies. Professional museum-quality execution --no digital art, no AI-generated appearance, no computer graphics. ",
            
            // Kandinsky Abstract Expressionism - Enhanced with Midjourney techniques
            "Masterpiece abstract expressionist painting in the style of Wassily Kandinsky::3, featuring dynamic, geometric forms::2, bold color relationships::2, and musical, rhythmic composition::1. Use precise, clean brushwork with vibrant, contrasting colors and dynamic movement and energy. The painting should have characteristic Kandinsky geometric abstraction and color theory, with flowing forms and sophisticated color relationships. Professional museum-quality execution --no digital art, no AI-generated appearance, no computer graphics. ",
            
            // Georgia O'Keeffe Naturalism - Enhanced with Midjourney techniques
            "Masterpiece naturalistic painting in the style of Georgia O'Keeffe::3, featuring organic, flowing forms::2, subtle color gradations::2, and intimate, personal scale::1. Use soft, blended brushwork with natural color palettes and organic, living forms. The piece should have characteristic O'Keeffe naturalism and organic abstraction, with biomorphic shapes and subtle, natural color relationships. Professional museum-quality execution --no digital art, no AI-generated appearance, no computer graphics. ",
            
            // Jackson Pollock Action Painting - Enhanced with Midjourney techniques
            "Masterpiece action painting in the style of Jackson Pollock::3, featuring dynamic, gestural marks::2, layered, complex textures::2, and energetic, spontaneous composition::1. Use bold, expressive brushwork with layered, complex color relationships and dynamic movement and energy. The painting should have characteristic Pollock energy and spontaneity, with flowing lines and complex, layered textures. Professional museum-quality execution --no digital art, no AI-generated appearance, no computer graphics. "
        ]
        
        return styles.randomElement() ?? styles[0]
    }
    
    /// Creates an art prompt based on sleep data with Midjourney-level sophistication
    private func createSleepArtPrompt(from sleepData: SleepData) -> String {
        let hours = Int(sleepData.totalSleepSeconds) / 3600
        let minutes = (Int(sleepData.totalSleepSeconds) % 3600) / 60
        
        // Select random artistic style
        let artisticStyle = getRandomArtisticStyle()
        
        var prompt = "Masterpiece sleep-themed artwork::3, museum-quality execution::2, authentic artistic techniques::2, professional gallery presentation::1. "
        
        // Add the selected artistic style
        prompt += artisticStyle
        
        // Base the art style on sleep quality with sophisticated visual metaphors and prompt weighting
        if sleepData.sleepScore >= 80 {
            prompt += "The composition should embody tranquility and restorative energy::3 through flowing, organic forms::2, lush, verdant color palettes::2, and peaceful depth::1. Use deep emerald greens, serene blues, and warm golden accents. Create natural harmony and restorative energy. "
        } else if sleepData.sleepScore >= 60 {
            prompt += "The composition should convey balanced rest::3 through gentle, rhythmic patterns::2, warm, comforting tones::2, and peaceful stability::1. Use soft amber, sage green, and muted lavender hues. Create gentle movement and balanced energy. "
        } else {
            prompt += "The composition should reflect fragmented rest::3 through angular, disjointed forms::2, cooler, muted tones::2, and interrupted flow::1. Use deep burgundy, slate blue, and charcoal gray hues. Create tension and fragmented energy while maintaining artistic beauty. "
        }
        
        // Add specific elements based on sleep data with artistic interpretation and weighting
        prompt += "Incorporate symbolic elements representing sleep cycles::2: "
        prompt += "\(hours) hours and \(minutes) minutes of rest::1, "
        prompt += "\(sleepData.awakenings) moments of consciousness::1, "
        prompt += "REM sleep (\(sleepData.formattedRemSleep))::1, deep sleep (\(sleepData.formattedDeepSleep))::1, and core sleep (\(sleepData.formattedCoreSleep))::1. "
        
        prompt += "Professional museum-quality execution::2, authentic artistic techniques::2, natural brushwork::1, genuine artistic expression::1. "
        prompt += "Sophisticated color theory::1: warmer, vibrant tones for restorative sleep, cooler, subdued tones for fragmented rest. "
        
        // Add negative prompts to avoid AI-generated look
        prompt += "--no digital art, no AI-generated appearance, no computer graphics, no digital painting, no synthetic textures, no artificial lighting, no perfect symmetry, no overly smooth surfaces, no digital brushstrokes, no computer-generated patterns, no artificial colors, no digital gradients, no pixelated elements, no vector graphics, no 3D rendering, no digital filters, no computer-aided design, no artificial intelligence, no machine learning, no algorithmic art, no procedural generation, no digital manipulation, no computer graphics, no CGI, no digital effects, no artificial intelligence, no machine learning, no algorithmic art, no procedural generation, no digital manipulation, no computer graphics, no CGI, no digital effects. "
        
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
    
    /// Creates an art prompt based on movement data with Midjourney-level sophistication
    private func createMovementArtPrompt(from movementData: MovementData) -> String {
        // Select random artistic style
        let artisticStyle = getRandomArtisticStyle()
        
        var prompt = "Masterpiece movement-themed artwork::3, museum-quality execution::2, authentic artistic techniques::2, professional gallery presentation::1. "
        
        // Add the selected artistic style
        prompt += artisticStyle
        
        // Base the art style on movement quality with sophisticated visual metaphors and prompt weighting
        if movementData.movementScore >= 80 {
            prompt += "The composition should embody dynamic energy and vitality::3 through bold, sweeping forms::2, powerful visual rhythms::2, and athletic grace::1. Use vibrant, saturated colors with electric blues, energetic oranges, and invigorating greens. Create unstoppable momentum and dynamic energy. "
        } else if movementData.movementScore >= 60 {
            prompt += "The composition should convey steady, purposeful movement::3 through balanced, rhythmic patterns::2, warm, encouraging tones::2, and consistent progress::1. Use harmonious color combinations with gentle blues, warm golds, and supportive greens. Create balanced energy and healthy activity. "
        } else {
            prompt += "The composition should reflect limited movement::3 through restrained, contained forms::2, muted, introspective tones::2, and potential energy::1. Use subdued color palettes with soft grays, muted purples, and gentle earth tones. Create contemplative energy and artistic dignity. "
        }
        
        // Add specific elements based on movement data with artistic interpretation and weighting
        prompt += "Incorporate symbolic elements representing physical activity::2: "
        prompt += "\(movementData.stepCount) steps of progress::1, "
        prompt += "\(movementData.standHours) hours of engagement::1, "
        prompt += "\(movementData.formattedActiveEnergy) of energy expended::1, "
        prompt += "\(movementData.exerciseMinutes) minutes of dedicated effort::1, "
        prompt += "\(movementData.formattedWalkingDistance) of distance covered::1, and "
        prompt += "\(movementData.flightsClimbed) ascents achieved::1. "
        
        prompt += "Professional museum-quality execution::2, authentic artistic techniques::2, natural brushwork::1, genuine artistic expression::1. "
        prompt += "Sophisticated color theory::1: vibrant, energetic tones for high activity, balanced, harmonious tones for moderate activity, subdued, contemplative tones for low activity. "
        
        // Add negative prompts to avoid AI-generated look
        prompt += "--no digital art, no AI-generated appearance, no computer graphics, no digital painting, no synthetic textures, no artificial lighting, no perfect symmetry, no overly smooth surfaces, no digital brushstrokes, no computer-generated patterns, no artificial colors, no digital gradients, no pixelated elements, no vector graphics, no 3D rendering, no digital filters, no computer-aided design, no artificial intelligence, no machine learning, no algorithmic art, no procedural generation, no digital manipulation, no computer graphics, no CGI, no digital effects, no artificial intelligence, no machine learning, no algorithmic art, no procedural generation, no digital manipulation, no computer graphics, no CGI, no digital effects. "
        
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

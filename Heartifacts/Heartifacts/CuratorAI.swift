import Foundation

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

// MARK: - CuratorAI Class
class CuratorAI {
    // MARK: - Private Properties
    private let apiKey = "API KEY"
    private let apiURL = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    // MARK: - Public Methods (Called by Manager)
    
    /// Generates an AI message based on the provided prompt
    func generateAIMessage(from prompt: String, completion: @escaping (String) -> Void) {
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = OpenAIRequest(
            model: "gpt-3.5-turbo",
            messages: [
                OpenAIMessage(role: "system", content: "You are a helpful museum curator AI. You analyze health data and provide friendly, encouraging feedback. Keep your responses concise, positive, and under 40 words. Make sure to lean into the museum theme, playing into the fact that your body is a museum and you have to take care of it or else the artifacts will get old and dusty. Don't make literal references to this, however. Just make sure that the museum Also make sure to, when summarizing sleep data, always include the calculated sleep score. Don't be too offputtingly friendly though. If the sleep score is bad, make sure to tell them about ways to improve it."),
                OpenAIMessage(role: "user", content: prompt)
            ]
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            DispatchQueue.main.async { 
                completion("Error creating request.") 
            }
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
}

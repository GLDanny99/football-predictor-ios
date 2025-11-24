import Foundation

class ApiClient {
    static let baseURL = "https://football-predictor-4gpk.onrender.com"
    
    static func fetchTodayMatches(completion: @escaping ([Match]) -> Void) {
        let url = URL(string: "\(baseURL)/matches/today")!
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion([])
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(FixtureResponse.self, from: data)
                
                let cleaned = decoded.response.map { item in
                    Match(
                        home: item.teams.home.name,
                        away: item.teams.away.name,
                        time: item.fixture.date
                    )
                }
                
                DispatchQueue.main.async {
                    completion(cleaned)
                }
            } catch {
                completion([])
            }
            
        }.resume()
    }
}

struct FixtureResponse: Codable {
    let response: [FixtureItem]
}

struct FixtureItem: Codable {
    let fixture: FixtureDetails
    let teams: TeamDetails
}

struct FixtureDetails: Codable {
    let date: String
}

struct TeamDetails: Codable {
    let home: TeamName
    let away: TeamName
}

struct TeamName: Codable {
    let name: String
}

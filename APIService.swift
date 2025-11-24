import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
}

final class APIService {
    static let shared = APIService()
    private let session = URLSession.shared
    
    // Meciurile de azi
    func fetchTodayMatches() async throws -> [MatchViewModel] {
        let url = BackendConfig.baseURL.appendingPathComponent("matches/today")
        
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.requestFailed
        }
        
        // JSON-ul de la backend este exact cel de la API-Football:
        // { "response": [ { fixture: {...}, league: {...}, teams: {...}, goals: {...} } ] }
        let decoded = try JSONDecoder().decode(MatchesResponse.self, from: data)
        return decoded.response.map { MatchViewModel(from: $0) }
    }
    
    // Meciuri LIVE
    func fetchLiveMatches() async throws -> [MatchViewModel] {
        let url = BackendConfig.baseURL.appendingPathComponent("matches/live")
        
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.requestFailed
        }
        
        let decoded = try JSONDecoder().decode(MatchesResponse.self, from: data)
        return decoded.response.map { MatchViewModel(from: $0) }
    }
    
    // Predicție pre-meci
    func fetchPrediction(for matchId: Int) async throws -> PredictionResponse {
        let url = BackendConfig.baseURL
            .appendingPathComponent("prediction")
            .appendingPathComponent(String(matchId))
        
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.requestFailed
        }
        
        return try JSONDecoder().decode(PredictionResponse.self, from: data)
    }
    
    // Predicție LIVE
    func fetchLivePrediction(for matchId: Int) async throws -> LivePredictionResponse {
        let url = BackendConfig.baseURL
            .appendingPathComponent("live")
            .appendingPathComponent("prediction")
            .appendingPathComponent(String(matchId))
        
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw APIError.requestFailed
        }
        
        return try JSONDecoder().decode(LivePredictionResponse.self, from: data)
    }
}

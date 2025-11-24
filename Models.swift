import Foundation

// Răspuns generic de la backend (lista de meciuri)
struct MatchesResponse: Decodable {
    let response: [APIFixture]
}

// Structuri adaptate la formatul API-Football care vine prin backend
struct APIFixture: Decodable, Identifiable {
    var id: Int {
        fixture.id
    }
    
    let fixture: APIFixtureInfo
    let league: APILeagueInfo
    let teams: APITeamsInfo
    let goals: APIGoalsInfo?
}

struct APIFixtureInfo: Decodable {
    let id: Int
    let date: String
    let status: APIStatus
}

struct APIStatus: Decodable {
    let short: String
}

struct APILeagueInfo: Decodable {
    let name: String
    let country: String?
}

struct APITeamsInfo: Decodable {
    let home: APITeamSide
    let away: APITeamSide
}

struct APITeamSide: Decodable {
    let name: String
    let winner: Bool?
}

struct APIGoalsInfo: Decodable {
    let home: Int?
    let away: Int?
}

// Model simplificat pentru afișare în app
struct MatchViewModel: Identifiable {
    let id: Int
    let league: String
    let homeTeam: String
    let awayTeam: String
    let dateString: String
    let statusShort: String
    let score: String
    
    init(from fixture: APIFixture) {
        id = fixture.fixture.id
        league = fixture.league.name
        homeTeam = fixture.teams.home.name
        awayTeam = fixture.teams.away.name
        statusShort = fixture.fixture.status.short
        
        if let g = fixture.goals {
            let h = g.home ?? 0
            let a = g.away ?? 0
            score = "\(h) - \(a)"
        } else {
            score = "- : -"
        }
        
        // data brută → text simplu
        dateString = String(fixture.fixture.date.prefix(16)) // primele caractere din stringul ISO
    }
}

// Răspuns pentru /prediction/{id}
struct PredictionResponse: Decodable {
    let predicted_score_home: Int
    let predicted_score_away: Int
    let aggression_index: Double
    let chance_over_2_5: Int
    let chance_goal_next_10min: Int
}

// Răspuns pentru /live/prediction/{id}
struct LivePredictionResponse: Decodable {
    let goal_next_5min: Int
    let yellow_next_5min: Int
    let pressure_index: Int
}

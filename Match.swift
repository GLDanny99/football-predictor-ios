import Foundation

struct Match: Identifiable, Codable {
    let id = UUID()
    let home: String
    let away: String
    let time: String
}

import SwiftUI

struct ContentView: View {
    @State private var todayMatches: [MatchViewModel] = []
    @State private var liveMatches: [MatchViewModel] = []
    @State private var isLoadingToday = false
    @State private var isLoadingLive = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            List {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Section("Meciuri live") {
                    if isLoadingLive {
                        ProgressView("Se încarcă live...")
                    } else if liveMatches.isEmpty {
                        Text("Nu sunt meciuri live acum.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(liveMatches) { match in
                            NavigationLink {
                                MatchDetailView(match: match, isLive: true)
                            } label: {
                                MatchRow(match: match, isLive: true)
                            }
                        }
                    }
                }
                
                Section("Meciurile de azi") {
                    if isLoadingToday {
                        ProgressView("Se încarcă meciurile de azi...")
                    } else if todayMatches.isEmpty {
                        Text("Nu sunt meciuri pentru azi.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(todayMatches) { match in
                            NavigationLink {
                                MatchDetailView(match: match, isLive: false)
                            } label: {
                                MatchRow(match: match, isLive: false)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Football Predictor")
            .task {
                await loadData()
            }
            .refreshable {
                await loadData()
            }
        }
    }
    
    private func loadData() async {
        await loadToday()
        await loadLive()
    }
    
    private func loadToday() async {
        isLoadingToday = true
        defer { isLoadingToday = false }
        
        do {
            let matches = try await APIService.shared.fetchTodayMatches()
            await MainActor.run {
                self.todayMatches = matches
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Eroare la încărcarea meciurilor de azi."
            }
        }
    }
    
    private func loadLive() async {
        isLoadingLive = true
        defer { isLoadingLive = false }
        
        do {
            let matches = try await APIService.shared.fetchLiveMatches()
            await MainActor.run {
                self.liveMatches = matches
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Eroare la încărcarea meciurilor live."
            }
        }
    }
}

struct MatchRow: View {
    let match: MatchViewModel
    let isLive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("\(match.homeTeam) vs \(match.awayTeam)")
                    .font(.headline)
                if isLive {
                    Text("LIVE")
                        .font(.caption)
                        .padding(4)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
            }
            Text(match.league)
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Text(match.score)
                Spacer()
                Text(match.dateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

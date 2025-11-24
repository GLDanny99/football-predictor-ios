import SwiftUI

struct MatchDetailView: View {
    let match: MatchViewModel
    let isLive: Bool
    
    @State private var prediction: PredictionResponse?
    @State private var livePrediction: LivePredictionResponse?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                if isLoading {
                    ProgressView("Se calculează predicțiile...")
                } else {
                    if let p = prediction {
                        predictionSection(p)
                    }
                    if isLive, let lp = livePrediction {
                        livePredictionSection(lp)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Detalii meci")
        .task {
            await loadPredictions()
        }
        .refreshable {
            await loadPredictions()
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(match.homeTeam) vs \(match.awayTeam)")
                .font(.title2)
                .bold()
            Text(match.league)
                .foregroundColor(.secondary)
            Text("Status: \(match.statusShort)")
                .font(.subheadline)
            Text("Scor actual: \(match.score)")
        }
    }
    
    private func predictionSection(_ p: PredictionResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Predicție pre-meci")
                .font(.headline)
            
            Text("Scor probabil: \(p.predicted_score_home) - \(p.predicted_score_away)")
            Text("Șansă peste 2.5 goluri: \(p.chance_over_2_5)%")
            Text("Șansă gol în următoarele 10 minute: \(p.chance_goal_next_10min)%")
            Text("Indice agresivitate: \(Int(p.aggression_index))")
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(10)
    }
    
    private func livePredictionSection(_ lp: LivePredictionResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Predicții LIVE")
                .font(.headline)
            
            Text("Șansă gol în următoarele 5 minute: \(lp.goal_next_5min)%")
            Text("Șansă cartonaș galben în următoarele 5 minute: \(lp.yellow_next_5min)%")
            Text("Indice presiune ofensivă: \(lp.pressure_index)")
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(10)
    }
    
    private func loadPredictions() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let p = try await APIService.shared.fetchPrediction(for: match.id)
            await MainActor.run {
                self.prediction = p
                self.errorMessage = nil
            }
            
            if isLive {
                let lp = try await APIService.shared.fetchLivePrediction(for: match.id)
                await MainActor.run {
                    self.livePrediction = lp
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Nu am reușit să iau predicțiile."
            }
        }
    }
}

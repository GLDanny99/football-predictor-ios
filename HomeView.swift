import SwiftUI

struct HomeView: View {
    @State private var matches: [Match] = []
    
    var body: some View {
        NavigationView {
            List(matches) { match in
                VStack(alignment: .leading) {
                    Text("\(match.home) vs \(match.away)")
                        .font(.headline)
                    Text("Ora: \(match.time)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Meciurile de azi")
            .onAppear {
                loadMatches()
            }
        }
    }
    
    func loadMatches() {
        ApiClient.fetchTodayMatches { result in
            self.matches = result
        }
    }
}

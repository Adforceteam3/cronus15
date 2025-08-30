import SwiftUI


struct ContentView: View {
    @State private var showSplash = true
    @State private var hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @StateObject private var accessManager = ValuteCursAccessManager()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 0.99), // #F3F9FD
                    Color(red: 0.92, green: 0.94, blue: 0.96)  // #EBF1F5
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if showSplash {
                SplashView(isPresented: $showSplash)
            } else {
                if accessManager.shouldShowMainApp {
                    if !hasCompletedOnboarding {
                        OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    } else {
                        MainAppView()
                    }
                } else {
                    ValuteCursExternalView()
                        .environmentObject(accessManager)
                }
            }
        }
        .onAppear {
            _ = accessManager.determineAccess()
        }
    }
}

struct MainAppView: View {
    @StateObject private var dataManager = DataManager()
    
    var body: some View {
        TabView {
            ConverterView()
                .environmentObject(dataManager)
                .tabItem {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Converter")
                }
            
            HistoryView()
                .environmentObject(dataManager)
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
            
            ChartView()
                .environmentObject(dataManager)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Chart")
                }
            
            FavoritesView()
                .environmentObject(dataManager)
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Favorites")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .accentColor(Color(red: 0.01, green: 0.19, blue: 0.88)) // #0230E1
    }
}

#Preview {
    ContentView()
}

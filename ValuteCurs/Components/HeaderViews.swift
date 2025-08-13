import SwiftUI

// MARK: - Converter Header
struct ConverterHeaderView: View {
    @State private var currentTime = Date()
    @State private var shimmer = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.01, green: 0.19, blue: 0.88),
                    Color(red: 0.24, green: 0.35, blue: 1.0),
                    Color(red: 0.40, green: 0.50, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Animated particles in header
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 30...60))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...120)
                    )
                    .scaleEffect(shimmer ? 1.2 : 0.8)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 2...4))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: shimmer
                    )
            }
            
            VStack(spacing: 12) {
                // Date
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text(dateFormatter.string(from: currentTime))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                }
                
                // Time
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(timeFormatter.string(from: currentTime))
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    
                    Spacer()
                    
                    // Live indicator
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .scaleEffect(shimmer ? 1.2 : 1.0)
                            .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: shimmer)
                        
                        Text("LIVE")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(8)
                }
                
                // Currency Converter title
                HStack {
                    Text("Currency Converter")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(shimmer ? 180 : 0))
                        .animation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: shimmer)
                }
            }
            .padding()
        }
        .frame(height: 120)
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .onAppear {
            shimmer = true
        }
    }
}

// MARK: - History Header
struct HistoryHeaderView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var animate = false
    
    private var totalConversions: Int {
        dataManager.conversionHistory.count
    }
    
    private var totalAmount: Double {
        dataManager.conversionHistory.reduce(0) { $0 + $1.amount }
    }
    
    private var projectedConversions: Int {
        let today = Calendar.current.startOfDay(for: Date())
        let todayConversions = dataManager.conversionHistory.filter { 
            Calendar.current.startOfDay(for: $0.date) == today 
        }.count
        return todayConversions * 30 // Project monthly
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple,
                    Color.blue,
                    Color(red: 0.01, green: 0.19, blue: 0.88)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 16) {
                // Title
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(animate ? 360 : 0))
                        .animation(Animation.linear(duration: 3.0).repeatForever(autoreverses: false), value: animate)
                    
                    Text("Conversion History")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                
                // Statistics
                HStack(spacing: 20) {
                    // Total conversions
                    VStack(spacing: 4) {
                        Text("\(totalConversions)")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .scaleEffect(animate ? 1.1 : 1.0)
                            .animation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animate)
                        
                        Text("Total")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Projected
                    VStack(spacing: 4) {
                        Text("\(projectedConversions)")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text("Monthly")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Total amount
                    VStack(spacing: 4) {
                        Text("$\(String(format: "%.0f", totalAmount))")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text("Volume")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .frame(height: 120)
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Chart Header
struct ChartHeaderView: View {
    @State private var sparkle = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.green,
                    Color.mint,
                    Color.cyan
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Sparkle effects
            ForEach(0..<8, id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: CGFloat.random(in: 12...20), weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                    .position(
                        x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                        y: CGFloat.random(in: 20...100)
                    )
                    .scaleEffect(sparkle ? 1.2 : 0.8)
                    .opacity(sparkle ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 1...3))
                            .repeatForever(autoreverses: true)
                            .delay(Double.random(in: 0...2)),
                        value: sparkle
                    )
            }
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    VStack(alignment: .leading) {
                        Text("Chart")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        
                        Text("Market Trends")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    // Trending indicator
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                        
                        Text("TRENDING")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
        .frame(height: 100)
        .onAppear {
            sparkle = true
        }
    }
}

// MARK: - Favorites Header
struct FavoritesHeaderView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var pulse = false
    
    private var totalFavorites: Int {
        dataManager.favoritePairs.count
    }
    
    private var recentlyAdded: Int {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
        return dataManager.favoritePairs.filter { $0.dateAdded > yesterday }.count
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange,
                    Color.yellow,
                    Color.pink
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 12) {
                // Title
                HStack {
                    Image(systemName: "star.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(pulse ? 1.2 : 1.0)
                        .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
                    
                    Text("Favorites")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Badge
                    Text("\(totalFavorites)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.orange)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.white))
                        .scaleEffect(pulse ? 1.1 : 1.0)
                        .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)
                }
                
                // Stats
                HStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(totalFavorites) Total Pairs")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(15)
                    
                    if recentlyAdded > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("\(recentlyAdded) Recent")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                    }
                    
                    Spacer()
                }
            }
            .padding()
        }
        .frame(height: 100)
        .onAppear {
            pulse = true
        }
    }
}

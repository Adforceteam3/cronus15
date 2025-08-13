import SwiftUI

struct ChartView: View {
    @State private var selectedPeriod = "7D"
    @State private var selectedPair = "USD/EUR"
    @State private var animateChart = false
    
    private let periods = ["7D", "30D", "90D", "1Y"]
    private let currencyPairs = [
        "USD/EUR", "GBP/USD", "EUR/JPY", "AUD/CAD", "USD/JPY",
        "EUR/GBP", "USD/CHF", "CAD/JPY", "AUD/USD", "EUR/CHF",
        "GBP/JPY", "USD/CAD", "CHF/JPY", "AUD/JPY", "EUR/AUD",
        "GBP/CAD", "USD/CNY", "EUR/CNY", "GBP/AUD", "CAD/CHF"
    ]
    
    // Генерируем данные для графика
    private var chartData: [ChartDataPoint] {
        generateChartData(for: selectedPeriod)
    }
    
    private var currentRate: Double {
        chartData.last?.value ?? 1.0
    }
    
    private var changeValue: Double {
        guard chartData.count > 1 else { return 0 }
        let first = chartData.first?.value ?? 0
        let last = chartData.last?.value ?? 0
        return last - first
    }
    
    private var changePercent: Double {
        guard let first = chartData.first?.value, first > 0 else { return 0 }
        return (changeValue / first) * 100
    }

    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackground(particleCount: 10, colors: [Color.green, Color.mint, Color.cyan])

            VStack(spacing: 0) {
                // Custom Header
                ChartHeaderView()

                ScrollView {
                    VStack(spacing: 24) {
                        // Currency Pair Selector
                        VStack(spacing: 12) {
                            Text("Currency Pair")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Menu {
                                ForEach(currencyPairs, id: \.self) { pair in
                                    Button(action: {
                                        selectedPair = pair
                                        animateChart.toggle()
                                    }) {
                                        Text(pair)
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedPair)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Period selector
                        VStack(spacing: 12) {
                            Text("Time Period")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Picker("Period", selection: $selectedPeriod) {
                                ForEach(periods, id: \.self) { period in
                                    Text(period).tag(period)
                                }
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: selectedPeriod) { _ in
                                animateChart.toggle()
                            }
                        }
                        .padding(.horizontal)

                        // Chart Card
                        GroupBox {
                            VStack(spacing: 20) {
                                // Current Rate & Change
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Current Rate")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(String(format: "%.4f", currentRate))
                                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("24h Change")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        HStack(spacing: 4) {
                                            Image(systemName: changeValue >= 0 ? "arrow.up" : "arrow.down")
                                                .font(.system(size: 12, weight: .bold))
                                            Text(String(format: "%.2f%%", abs(changePercent)))
                                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                        }
                                        .foregroundColor(changeValue >= 0 ? .green : .red)
                                    }
                                }
                                
                                // Line Chart
                                LineChart(data: chartData, animateChart: animateChart)
                                    .frame(height: 200)
                            }
                        }
                        .groupBoxStyle(WhiteGroupBoxStyle())
                        .padding(.horizontal)
                        
                        // Stats Cards
                        HStack(spacing: 12) {
                            StatCard(title: "High", value: String(format: "%.4f", chartData.map(\.value).max() ?? 0), color: .green)
                            StatCard(title: "Low", value: String(format: "%.4f", chartData.map(\.value).min() ?? 0), color: .red)
                            StatCard(title: "Volume", value: "2.4M", color: .blue)
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 100)
                    }
                }
                .padding(.top, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            animateChart = true
        }
    }
    
    private func generateChartData(for period: String) -> [ChartDataPoint] {
        let count: Int
        switch period {
        case "7D": count = 7
        case "30D": count = 30
        case "90D": count = 90
        case "1Y": count = 365
        default: count = 7
        }
        
        var data: [ChartDataPoint] = []
        var baseValue = 1.0 + Double.random(in: -0.2...0.2)
        
        for i in 0..<count {
            let change = Double.random(in: -0.02...0.02)
            baseValue += change
            baseValue = max(0.1, baseValue) // Prevent negative values
            
            data.append(ChartDataPoint(
                date: Calendar.current.date(byAdding: .day, value: i - count + 1, to: Date()) ?? Date(),
                value: baseValue
            ))
        }
        
        return data
    }
}

// MARK: - Chart Data Model
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - Line Chart View
struct LineChart: View {
    let data: [ChartDataPoint]
    let animateChart: Bool
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let maxValue = data.map(\.value).max() ?? 1
            let minValue = data.map(\.value).min() ?? 0
            let range = maxValue - minValue
            
            ZStack {
                // Background grid
                Path { path in
                    for i in 0...4 {
                        let y = height * CGFloat(i) / 4
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                    for i in 0...6 {
                        let x = width * CGFloat(i) / 6
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: height))
                    }
                }
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                
                // Gradient fill
                Path { path in
                    guard data.count > 1 else { return }
                    
                    let step = width / CGFloat(data.count - 1)
                    
                    path.move(to: CGPoint(
                        x: 0,
                        y: height - ((data[0].value - minValue) / range) * height
                    ))
                    
                    for (index, point) in data.enumerated() {
                        let x = CGFloat(index) * step * animationProgress
                        let y = height - ((point.value - minValue) / range) * height
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                    // Close the path for gradient fill
                    path.addLine(to: CGPoint(x: width * animationProgress, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(0.3),
                            Color.green.opacity(0.1),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Main line
                Path { path in
                    guard data.count > 1 else { return }
                    
                    let step = width / CGFloat(data.count - 1)
                    
                    path.move(to: CGPoint(
                        x: 0,
                        y: height - ((data[0].value - minValue) / range) * height
                    ))
                    
                    for (index, point) in data.enumerated() {
                        let x = CGFloat(index) * step * animationProgress
                        let y = height - ((point.value - minValue) / range) * height
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                
                // Data points
                ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
                    let step = width / CGFloat(data.count - 1)
                    let x = CGFloat(index) * step * animationProgress
                    let y = height - ((point.value - minValue) / range) * height
                    
                    if CGFloat(index) <= CGFloat(data.count - 1) * animationProgress {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: y)
                            .scaleEffect(animateChart ? 1.0 : 0.0)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.02), value: animateChart)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animationProgress = 1.0
            }
        }
        .onChange(of: animateChart) { _ in
            animationProgress = 0
            withAnimation(.easeInOut(duration: 1.5)) {
                animationProgress = 1.0
            }
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}


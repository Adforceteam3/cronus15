import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var animateItems = false
    @State private var showDeleteConfirmation = false
    @State private var favoriteToDelete: FavoritePair?
    @State private var showConverterModal = false
    @State private var showChartModal = false
    @State private var selectedPair: FavoritePair?
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackground(particleCount: 8, colors: [Color.orange, Color.yellow, Color.pink])
            
            VStack(spacing: 0) {
                // Custom Header
                FavoritesHeaderView()
                    .environmentObject(dataManager)
                
                if dataManager.favoritePairs.isEmpty {
                    // Empty state
                    VStack(spacing: 24) {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color.orange.opacity(0.1),
                                            Color.orange.opacity(0.3)
                                        ]),
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: 60
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .scaleEffect(animateItems ? 1.1 : 1.0)
                                .animation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateItems)
                            
                            Image(systemName: "star.fill")
                                .font(.system(size: 48, weight: .medium))
                                .foregroundColor(.orange)
                        }
                        
                        VStack(spacing: 8) {
                            Text("No Favorites Yet")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Add currency pairs to favorites from the converter to see them here")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        
                        Spacer()
                    }
                } else {
                    // Favorites grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(Array(dataManager.favoritePairs.enumerated()), id: \.element.id) { index, favorite in
                                FavoriteCardView(
                                    favorite: favorite,
                                    onDelete: {
                                        favoriteToDelete = favorite
                                        showDeleteConfirmation = true
                                    },
                                    onConverter: {
                                        selectedPair = favorite
                                        showConverterModal = true
                                    },
                                    onChart: {
                                        selectedPair = favorite
                                        showChartModal = true
                                    }
                                )
                                .scaleEffect(animateItems ? 1.0 : 0.8)
                                .opacity(animateItems ? 1.0 : 0.0)
                                .animation(
                                    Animation.spring(response: 0.6, dampingFraction: 0.8)
                                        .delay(Double(index) * 0.1),
                                    value: animateItems
                                )
                            }
                        }
                        .padding()
                    }
                    .alert("Delete Favorite", isPresented: $showDeleteConfirmation) {
                        Button("Cancel", role: .cancel) {}
                        Button("Delete", role: .destructive) {
                            if let favorite = favoriteToDelete {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    dataManager.removeFavorite(favorite)
                                }
                                favoriteToDelete = nil
                            }
                        }
                    } message: {
                        if let favorite = favoriteToDelete {
                            Text("Are you sure you want to remove \(favorite.fromCurrency)/\(favorite.toCurrency) from favorites?")
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                animateItems = true
            }
        }
        // Modal overlays
        .overlay(
            ZStack {
                // Converter Modal
                if showConverterModal, let pair = selectedPair {
                    ConverterModal(pair: pair, isPresented: $showConverterModal)
                        .environmentObject(dataManager)
                }
                
                // Chart Modal
                if showChartModal, let pair = selectedPair {
                    ChartModal(pair: pair, isPresented: $showChartModal)
                }
            }
        )
    }
}

struct FavoriteCardView: View {
    let favorite: FavoritePair
    let onDelete: () -> Void
    let onConverter: () -> Void
    let onChart: () -> Void
    @State private var isPressed = false
    @State private var rotateIcon = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Currency pair display
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.orange.opacity(0.1),
                                    Color.orange.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    VStack(spacing: 4) {
                        Text(favorite.fromCurrency)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.orange)
                        
                        Image(systemName: "arrow.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.orange)
                            .rotationEffect(.degrees(rotateIcon ? 180 : 0))
                            .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: rotateIcon)
                        
                        Text(favorite.toCurrency)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.orange)
                    }
                }
                
                Text("\(favorite.fromCurrency)/\(favorite.toCurrency)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            // Action buttons
            VStack(spacing: 8) {
                Button(action: onConverter) {
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Convert")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.01, green: 0.19, blue: 0.88),
                                Color(red: 0.24, green: 0.35, blue: 1.0)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                
                Button(action: onChart) {
                    VStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Chart")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.green,
                                Color.green.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                
                Button(action: onDelete) {
                    VStack(spacing: 4) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Delete")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.red,
                                Color.red.opacity(0.8)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onAppear {
            rotateIcon = true
        }
        .onTapGesture {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

// MARK: - Converter Modal
struct ConverterModal: View {
    let pair: FavoritePair
    @Binding var isPresented: Bool
    @EnvironmentObject var dataManager: DataManager
    @State private var amount = ""
    @State private var result = 0.0
    @State private var showResult = false
    @State private var animateAppear = false
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissModal()
                }
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Text("\(pair.fromCurrency) → \(pair.toCurrency)")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: dismissModal) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text("Tap anywhere to close")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Amount input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextField("Enter amount", text: $amount)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: amount) { _ in
                            calculateResult()
                        }
                }
                
                // Result
                if showResult {
                    VStack(spacing: 8) {
                        Text("Result")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text(String(format: "%.2f %@", Double(amount) ?? 0, pair.fromCurrency))
                                .font(.system(size: 18, weight: .medium, design: .monospaced))
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(.blue)
                            
                            Text(String(format: "%.2f %@", result, pair.toCurrency))
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .transition(.opacity.combined(with: .scale))
                }
                
                // Save button
                Button(action: saveConversion) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Save to History")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .disabled(!showResult)
                .opacity(showResult ? 1.0 : 0.6)
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 32)
            .scaleEffect(animateAppear ? 1.0 : 0.8)
            .opacity(animateAppear ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateAppear = true
            }
        }
    }
    
    private func calculateResult() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            showResult = false
            return
        }
        
        // Simple mock exchange rate
        let rate = getExchangeRate(from: pair.fromCurrency, to: pair.toCurrency)
        result = amountValue * rate
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showResult = true
        }
    }
    
    private func saveConversion() {
        guard let amountValue = Double(amount), amountValue > 0 else { return }
        
        let record = ConversionRecord(
            date: Date(),
            fromCurrency: pair.fromCurrency,
            toCurrency: pair.toCurrency,
            rate: getExchangeRate(from: pair.fromCurrency, to: pair.toCurrency),
            amount: amountValue,
            result: result
        )
        
        dataManager.saveConversion(record)
        dismissModal()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func dismissModal() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            animateAppear = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
    
    private func getExchangeRate(from: String, to: String) -> Double {
        // Mock exchange rates
        let rates: [String: [String: Double]] = [
            "USD": ["EUR": 0.92, "GBP": 0.82, "JPY": 149.5, "CHF": 0.91, "CAD": 1.35, "AUD": 1.52, "CNY": 7.24, "INR": 83.1, "RUB": 93.2],
            "EUR": ["USD": 1.09, "GBP": 0.89, "JPY": 162.8, "CHF": 0.99, "CAD": 1.47, "AUD": 1.65, "CNY": 7.88, "INR": 90.4, "RUB": 101.5],
            "GBP": ["USD": 1.22, "EUR": 1.12, "JPY": 182.4, "CHF": 1.11, "CAD": 1.65, "AUD": 1.85, "CNY": 8.84, "INR": 101.3, "RUB": 113.8],
            "AUD": ["USD": 0.66, "EUR": 0.61, "GBP": 0.54, "JPY": 98.3, "CHF": 0.60, "CAD": 0.89, "CNY": 4.76, "INR": 54.7, "RUB": 61.2],
            "CAD": ["USD": 0.74, "EUR": 0.68, "GBP": 0.61, "JPY": 110.7, "CHF": 0.67, "AUD": 1.12, "CNY": 5.36, "INR": 61.5, "RUB": 68.9]
        ]
        
        return rates[from]?[to] ?? 1.0
    }
}

// MARK: - Chart Modal
struct ChartModal: View {
    let pair: FavoritePair
    @Binding var isPresented: Bool
    @State private var animateAppear = false
    @State private var animateChart = false
    
    // Mini chart data
    private var chartData: [ChartDataPoint] {
        generateMiniChartData()
    }
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    dismissModal()
                }
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Text("\(pair.fromCurrency)/\(pair.toCurrency) Chart")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: dismissModal) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Text("Tap anywhere to close")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Mini chart
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Rate")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(String(format: "%.4f", chartData.last?.value ?? 1.0))
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("24h Change")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            let change = (chartData.last?.value ?? 1.0) - (chartData.first?.value ?? 1.0)
                            HStack(spacing: 4) {
                                Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                                    .font(.system(size: 12, weight: .bold))
                                Text(String(format: "%.2f%%", abs(change) * 100))
                                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(change >= 0 ? .green : .red)
                        }
                    }
                    
                    // Mini Line Chart
                    MiniLineChart(data: chartData, animateChart: animateChart)
                        .frame(height: 120)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 32)
            .scaleEffect(animateAppear ? 1.0 : 0.8)
            .opacity(animateAppear ? 1.0 : 0.0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateAppear = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateChart = true
            }
        }
    }
    
    private func dismissModal() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            animateAppear = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
    
    private func generateMiniChartData() -> [ChartDataPoint] {
        var data: [ChartDataPoint] = []
        var baseValue = 1.0 + Double.random(in: -0.1...0.1)
        
        for i in 0..<24 { // 24 hours of data
            let change = Double.random(in: -0.01...0.01)
            baseValue += change
            baseValue = max(0.1, baseValue)
            
            data.append(ChartDataPoint(
                date: Calendar.current.date(byAdding: .hour, value: i - 23, to: Date()) ?? Date(),
                value: baseValue
            ))
        }
        
        return data
    }
}

// MARK: - Mini Line Chart
struct MiniLineChart: View {
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
                    
                    path.addLine(to: CGPoint(x: width * animationProgress, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.blue.opacity(0.1),
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
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
        .onChange(of: animateChart) { _ in
            animationProgress = 0
            withAnimation(.easeInOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }
}

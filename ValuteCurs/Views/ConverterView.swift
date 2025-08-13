import SwiftUI

struct ConverterView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var amount = ""
    @State private var fromCurrency = "USD"
    @State private var toCurrency = "EUR"
    @State private var result = 0.0
    @State private var showResult = false
    @State private var isSwapping = false
    @State private var pulseEffect = false
    @State private var shimmerOffset: CGFloat = -200
    @State private var showSaveAnimation = false
    @State private var canSave = false
    
    private let currencies = ["USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "CNY", "INR", "RUB"]
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackground(particleCount: 15, colors: [Color(red: 0.01, green: 0.19, blue: 0.88), Color.blue, Color.cyan])
            
            ScrollView {
                VStack(spacing: 0) {
                    // Custom Header
                    ConverterHeaderView()
                    
                    // Daily Login Progress
                    DailyLoginProgressView()
                        .padding(.top, 32)

                    VStack(spacing: 24) {
                    
                    // Amount Input Card with shimmer effect
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Amount")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ZStack {
                                HStack {
                                    Text("$")
                                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                                        .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                                    
                                    TextField("0.00", text: $amount)
                                        .font(.system(size: 28, weight: .medium, design: .monospaced))
                                        .keyboardType(.decimalPad)
                                        .onChange(of: amount) { _ in
                                            calculateResult()
                                            triggerPulse()
                                        }
                                }
                                .padding()
                                .background(Color(.systemGray6).opacity(0.5))
                                .cornerRadius(12)
                                .overlay(
                                    // Shimmer effect when typing
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.clear,
                                            Color.white.opacity(0.3),
                                            Color.clear
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .frame(width: 100)
                                    .offset(x: shimmerOffset)
                                    .animation(
                                        Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: false),
                                        value: shimmerOffset
                                    )
                                    .opacity(amount.isEmpty ? 0 : 1)
                                )
                                .scaleEffect(pulseEffect ? 1.02 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: pulseEffect)
                            }
                        }
                    }
                    .groupBoxStyle(WhiteGroupBoxStyle())
                    .padding(.horizontal)
                    
                    // Currency Selection Card
                    GroupBox {
                        VStack(spacing: 20) {
                            HStack(alignment: .center, spacing: 20) {
                                // From Currency
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("From")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Menu {
                                        ForEach(currencies, id: \.self) { currency in
                                            Button(action: {
                                                fromCurrency = currency
                                                calculateResult()
                                            }) {
                                                HStack {
                                                    Text(currency)
                                                        .font(.system(size: 16, weight: .bold))
                                                    Text(getCurrencyName(currency))
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(fromCurrency)
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: swapCurrencies) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(red: 0.01, green: 0.19, blue: 0.88),
                                                        Color(red: 0.24, green: 0.35, blue: 1.0)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 50, height: 50)
                                            .shadow(color: Color(red: 0.01, green: 0.19, blue: 0.88).opacity(0.4), radius: 8, x: 0, y: 4)
                                        
                                        Image(systemName: "arrow.up.arrow.down")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.white)
                                            .rotationEffect(.degrees(isSwapping ? 180 : 0))
                                            .scaleEffect(isSwapping ? 1.2 : 1.0)
                                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isSwapping)
                                    }
                                    .scaleEffect(isSwapping ? 0.95 : 1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSwapping)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("To")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Menu {
                                        ForEach(currencies, id: \.self) { currency in
                                            Button(action: {
                                                toCurrency = currency
                                                calculateResult()
                                            }) {
                                                HStack {
                                                    Text(currency)
                                                        .font(.system(size: 16, weight: .bold))
                                                    Text(getCurrencyName(currency))
                                                        .font(.system(size: 14, weight: .medium))
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(toCurrency)
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                                            Image(systemName: "chevron.down")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    }
                                }
                            }
                        }
                    }
                    .groupBoxStyle(WhiteGroupBoxStyle())
                    .padding(.horizontal)
                    
                    // Result Card
                    if showResult {
                        GroupBox {
                            VStack(spacing: 16) {
                                VStack(spacing: 4) {
                                    Text("Current Rate")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("1 \(fromCurrency) = \(String(format: "%.4f", getExchangeRate())) \(toCurrency)")
                                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.primary)
                                }
                                
                                Divider()
                                
                                VStack(spacing: 8) {
                                    Text("Result")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(alignment: .center, spacing: 12) {
                                        Text("\(String(format: "%.2f", Double(amount) ?? 0)) \(fromCurrency)")
                                            .font(.system(size: 18, weight: .medium, design: .monospaced))
                                            .foregroundColor(.primary)
                                        
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                                        
                                        Text("\(String(format: "%.2f", result)) \(toCurrency)")
                                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                                            .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                                    }
                                }
                                
                                // Action buttons
                                VStack(spacing: 12) {
                                    // Save to History button
                                    Button(action: saveToHistory) {
                                        HStack {
                                            Image(systemName: showSaveAnimation ? "checkmark.circle.fill" : "plus.circle.fill")
                                                .font(.system(size: 14, weight: .semibold))
                                            Text(showSaveAnimation ? "Saved!" : "Save")
                                                .font(.system(size: 13, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    showSaveAnimation ? Color.green : Color(red: 0.01, green: 0.19, blue: 0.88),
                                                    showSaveAnimation ? Color.green.opacity(0.8) : Color(red: 0.24, green: 0.35, blue: 1.0)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(16)
                                        .scaleEffect(showSaveAnimation ? 1.05 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showSaveAnimation)
                                    }
                                    .disabled(!canSave)
                                    .opacity(canSave ? 1.0 : 0.6)
                                    
                                    // Add to Favorites button
                                    Button(action: addToFavorites) {
                                        HStack {
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 14, weight: .semibold))
                                            Text("Favorite")
                                                .font(.system(size: 13, weight: .semibold))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.orange,
                                                    Color.orange.opacity(0.8)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .cornerRadius(16)
                                    }
                                }
                                .padding(.top, 12)
                            }
                        }
                        .groupBoxStyle(WhiteGroupBoxStyle())
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .scale))
                    }
                    
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func getCurrencyName(_ code: String) -> String {
        let names: [String: String] = [
            "USD": "US Dollar",
            "EUR": "Euro",
            "GBP": "British Pound",
            "JPY": "Japanese Yen",
            "CHF": "Swiss Franc",
            "CAD": "Canadian Dollar",
            "AUD": "Australian Dollar",
            "CNY": "Chinese Yuan",
            "INR": "Indian Rupee",
            "RUB": "Russian Ruble"
        ]
        return names[code] ?? code
    }
    
    private func calculateResult() {
        guard let amountValue = Double(amount), amountValue > 0 else {
            showResult = false
            canSave = false
            return
        }
        
        let rate = getExchangeRate()
        result = amountValue * rate
        
        withAnimation(.easeInOut(duration: 0.3)) {
            showResult = true
            canSave = true
            showSaveAnimation = false // Reset save animation
        }
    }
    
    private func getExchangeRate() -> Double {
        // Safe mock exchange rates - no complex calculations
        let rates: [String: [String: Double]] = [
            "USD": ["EUR": 0.92, "GBP": 0.79, "JPY": 149.5, "CHF": 0.91, "CAD": 1.35, "AUD": 1.52, "CNY": 7.24, "INR": 83.2, "RUB": 92.5, "USD": 1.0],
            "EUR": ["USD": 1.09, "GBP": 0.86, "JPY": 162.8, "CHF": 0.99, "CAD": 1.47, "AUD": 1.65, "CNY": 7.88, "INR": 90.5, "RUB": 100.6, "EUR": 1.0],
            "GBP": ["USD": 1.27, "EUR": 1.16, "JPY": 189.2, "CHF": 1.15, "CAD": 1.71, "AUD": 1.92, "CNY": 9.16, "INR": 105.3, "RUB": 117.1, "GBP": 1.0],
            "JPY": ["USD": 0.0067, "EUR": 0.0061, "GBP": 0.0053, "CHF": 0.0061, "CAD": 0.009, "AUD": 0.010, "CNY": 0.048, "INR": 0.56, "RUB": 0.62, "JPY": 1.0],
            "CHF": ["USD": 1.10, "EUR": 1.01, "GBP": 0.87, "JPY": 164.5, "CAD": 1.48, "AUD": 1.67, "CNY": 7.96, "INR": 91.4, "RUB": 101.8, "CHF": 1.0],
            "CAD": ["USD": 0.74, "EUR": 0.68, "GBP": 0.58, "JPY": 110.7, "CHF": 0.68, "AUD": 1.13, "CNY": 5.36, "INR": 61.6, "RUB": 68.5, "CAD": 1.0],
            "AUD": ["USD": 0.66, "EUR": 0.61, "GBP": 0.52, "JPY": 98.3, "CHF": 0.60, "CAD": 0.89, "CNY": 4.76, "INR": 54.7, "RUB": 60.9, "AUD": 1.0],
            "CNY": ["USD": 0.14, "EUR": 0.13, "GBP": 0.11, "JPY": 20.7, "CHF": 0.13, "CAD": 0.19, "AUD": 0.21, "INR": 11.5, "RUB": 12.8, "CNY": 1.0],
            "INR": ["USD": 0.012, "EUR": 0.011, "GBP": 0.0095, "JPY": 1.8, "CHF": 0.011, "CAD": 0.016, "AUD": 0.018, "CNY": 0.087, "RUB": 1.11, "INR": 1.0],
            "RUB": ["USD": 0.011, "EUR": 0.0099, "GBP": 0.0085, "JPY": 1.62, "CHF": 0.0098, "CAD": 0.015, "AUD": 0.016, "CNY": 0.078, "INR": 0.90, "RUB": 1.0]
        ]
        
        return rates[fromCurrency]?[toCurrency] ?? 1.0
    }
    
    private func swapCurrencies() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isSwapping = true
            let temp = fromCurrency
            fromCurrency = toCurrency
            toCurrency = temp
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isSwapping = false
            }
        }
        
        calculateResult()
    }
    
    private func triggerPulse() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            pulseEffect = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                pulseEffect = false
            }
        }
        
        // Trigger shimmer
        withAnimation(.easeInOut(duration: 1.0)) {
            shimmerOffset = 300
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            shimmerOffset = -200
        }
    }
    
    private func saveToHistory() {
        guard let amountValue = Double(amount), amountValue > 0, canSave else { return }
        
        let record = ConversionRecord(
            date: Date(),
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            rate: getExchangeRate(),
            amount: amountValue,
            result: result
        )
        
        dataManager.saveConversion(record)
        
        // Show save animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showSaveAnimation = true
            canSave = false
        }
        
        // Reset animation after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showSaveAnimation = false
            }
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func addToFavorites() {
        dataManager.addToFavorites(from: fromCurrency, to: toCurrency)
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Daily Login Progress View
struct DailyLoginProgressView: View {
    @State private var currentDay: Int = {
        let savedDay = UserDefaults.standard.integer(forKey: "currentLoginDay")
        let lastLoginDate = UserDefaults.standard.object(forKey: "lastLoginDate") as? Date ?? Date.distantPast
        
        // Check if user logged in today
        if Calendar.current.isDateInToday(lastLoginDate) {
            return savedDay
        } else if Calendar.current.isDate(lastLoginDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()) {
            // Yesterday login - continue streak
            return savedDay
        } else {
            // Reset streak if more than 1 day gap
            return 0
        }
    }()
    
    @State private var animateProgress = false
    @State private var pulseReward = false
    
    private let totalDays = 7
    
    var body: some View {
        GroupBox {
            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Login Streak")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        Text("Login daily for 7 days to earn rewards!")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Reward icon
                    ZStack {
                        Circle()
                            .fill(currentDay >= totalDays ? Color.orange.opacity(0.2) : Color.gray.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .scaleEffect(pulseReward ? 1.2 : 1.0)
                            .animation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseReward)
                        
                        Image(systemName: currentDay >= totalDays ? "gift.fill" : "gift")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(currentDay >= totalDays ? .orange : .gray)
                    }
                }
                
                // Progress bar with days
                VStack(spacing: 8) {
                    // Days indicators
                    HStack(spacing: 0) {
                        ForEach(1...totalDays, id: \.self) { day in
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(day <= currentDay ? Color(red: 0.01, green: 0.19, blue: 0.88) : Color.gray.opacity(0.3))
                                        .frame(width: 24, height: 24)
                                        .scaleEffect(day <= currentDay && animateProgress ? 1.1 : 1.0)
                                        .animation(
                                            Animation.spring(response: 0.6, dampingFraction: 0.8)
                                                .delay(Double(day) * 0.1),
                                            value: animateProgress
                                        )
                                    
                                    if day <= currentDay {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.white)
                                    } else {
                                        Text("\(day)")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                Text("Day \(day)")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundColor(day <= currentDay ? Color(red: 0.01, green: 0.19, blue: 0.88) : .gray)
                            }
                            
                            if day < totalDays {
                                Rectangle()
                                    .fill(day < currentDay ? Color(red: 0.01, green: 0.19, blue: 0.88) : Color.gray.opacity(0.3))
                                    .frame(height: 2)
                                    .frame(maxWidth: .infinity)
                                    .scaleEffect(x: day < currentDay && animateProgress ? 1.0 : 0.0, anchor: .leading)
                                    .animation(
                                        Animation.easeInOut(duration: 0.5)
                                            .delay(Double(day) * 0.1),
                                        value: animateProgress
                                    )
                            }
                        }
                    }
                    
                    // Progress text
                    HStack {
                        Text("\(currentDay)/\(totalDays) days completed")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if currentDay >= totalDays {
                            Text("🎉 Reward Earned!")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.orange)
                        } else {
                            Text("\(totalDays - currentDay) days left")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                        }
                    }
                }
                
                // Check-in button (only if not checked in today)
                if !Calendar.current.isDateInToday(UserDefaults.standard.object(forKey: "lastLoginDate") as? Date ?? Date.distantPast) {
                    Button(action: checkInToday) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Check In Today")
                                .font(.system(size: 14, weight: .semibold))
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
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.green)
                        Text("Checked in today!")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
        .groupBoxStyle(WhiteGroupBoxStyle())
        .padding(.horizontal)
        .onAppear {
            animateProgress = true
            if currentDay >= totalDays {
                pulseReward = true
            }
        }
    }
    
    private func checkInToday() {
        let today = Date()
        let lastLoginDate = UserDefaults.standard.object(forKey: "lastLoginDate") as? Date ?? Date.distantPast
        
        // Check if already checked in today
        if Calendar.current.isDateInToday(lastLoginDate) {
            return
        }
        
        // Increment day or reset streak
        if Calendar.current.isDate(lastLoginDate, inSameDayAs: Calendar.current.date(byAdding: .day, value: -1, to: today) ?? Date()) {
            // Consecutive day
            currentDay = min(currentDay + 1, totalDays)
        } else {
            // Reset streak
            currentDay = 1
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(currentDay, forKey: "currentLoginDay")
        UserDefaults.standard.set(today, forKey: "lastLoginDate")
        
        // Animate progress
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            animateProgress.toggle()
        }
        
        // Check if completed streak
        if currentDay >= totalDays {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                pulseReward = true
            }
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

// MARK: - Custom GroupBox Style
struct WhiteGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            configuration.content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

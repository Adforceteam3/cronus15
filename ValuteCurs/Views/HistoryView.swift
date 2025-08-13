import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var searchText = ""
    @State private var selectedCurrency = "All"
    @State private var animateItems = false
    
    private let currencies = ["All", "USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "CNY", "INR", "RUB"]
    
    private var filteredHistory: [ConversionRecord] {
        var filtered = dataManager.conversionHistory
        
        if !searchText.isEmpty {
            filtered = filtered.filter { record in
                record.fromCurrency.contains(searchText.uppercased()) ||
                record.toCurrency.contains(searchText.uppercased()) ||
                String(format: "%.2f", record.amount).contains(searchText)
            }
        }
        
        if selectedCurrency != "All" {
            filtered = filtered.filter { record in
                record.fromCurrency == selectedCurrency || record.toCurrency == selectedCurrency
            }
        }
        
        return filtered
    }
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackground(particleCount: 12, colors: [Color.purple, Color.blue, Color(red: 0.01, green: 0.19, blue: 0.88)])
            
            VStack(spacing: 0) {
                // Custom Header
                HistoryHeaderView()
                    .environmentObject(dataManager)
                
                VStack(spacing: 16) {
                    // Search and Filter Bar
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            
                            TextField("Search conversions...", text: $searchText)
                                .textFieldStyle(PlainTextFieldStyle())
                            
                            if !searchText.isEmpty {
                                Button(action: { searchText = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Filter buttons
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(currencies, id: \.self) { currency in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            selectedCurrency = currency
                                        }
                                    }) {
                                        Text(currency)
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(selectedCurrency == currency ? .white : Color(red: 0.01, green: 0.19, blue: 0.88))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(selectedCurrency == currency ? 
                                                        Color(red: 0.01, green: 0.19, blue: 0.88) :
                                                        Color.clear
                                                    )
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .stroke(Color(red: 0.01, green: 0.19, blue: 0.88), lineWidth: 1)
                                                            .opacity(selectedCurrency == currency ? 0 : 1)
                                                    )
                                            )
                                            .scaleEffect(selectedCurrency == currency ? 1.05 : 1.0)
                                    }
                                }
                            }
                            .padding(.vertical)
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.95, green: 0.97, blue: 0.99),
                                Color(red: 0.98, green: 0.98, blue: 0.99)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    if filteredHistory.isEmpty {
                        // Empty state
                        VStack(spacing: 24) {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.01, green: 0.19, blue: 0.88).opacity(0.1),
                                                Color(red: 0.01, green: 0.19, blue: 0.88).opacity(0.3)
                                            ]),
                                            center: .center,
                                            startRadius: 10,
                                            endRadius: 60
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                    .scaleEffect(animateItems ? 1.1 : 1.0)
                                    .animation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateItems)
                                
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 48, weight: .medium))
                                    .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                            }
                            
                            VStack(spacing: 8) {
                                Text("No History Yet")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text(searchText.isEmpty ? "Start converting currencies to see your history here" : "No conversions match your search")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)
                            }
                            
                            Spacer()
                        }
                    } else {
                        // History list
                        List {
                            ForEach(Array(filteredHistory.enumerated()), id: \.element.id) { index, record in
                                HistoryRowView(record: record)
                                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                    .listRowBackground(Color.clear)
                                    .scaleEffect(animateItems ? 1.0 : 0.8)
                                    .opacity(animateItems ? 1.0 : 0.0)
                                    .animation(
                                        Animation.spring(response: 0.6, dampingFraction: 0.8)
                                            .delay(Double(index) * 0.1),
                                        value: animateItems
                                    )
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
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
    }
}

struct HistoryRowView: View {
    let record: ConversionRecord
    @State private var isPressed = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }) {
            HStack(spacing: 16) {
                // Currency pair icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.01, green: 0.19, blue: 0.88).opacity(0.1),
                                    Color(red: 0.01, green: 0.19, blue: 0.88).opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    VStack(spacing: 2) {
                        Text(record.fromCurrency)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                        
                        Image(systemName: "arrow.down")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                        
                        Text(record.toCurrency)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(String(format: "%.2f", record.amount)) \(record.fromCurrency)")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(.primary)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("\(String(format: "%.2f", record.result)) \(record.toCurrency)")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.01, green: 0.19, blue: 0.88))
                    }
                    
                    HStack {
                        Text("Rate: \(String(format: "%.4f", record.rate))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(dateFormatter.string(from: record.date))
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

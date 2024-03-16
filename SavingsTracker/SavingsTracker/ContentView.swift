import SwiftUI

struct ContentView: View {
    @State private var savingsGoal: String = UserDefaults.standard.string(forKey: "savingsGoal") ?? ""
    @State private var currentSavings: Double = UserDefaults.standard.double(forKey: "currentSavings")
    @State private var amountToAddOrWithdraw: String = ""
    
    private var progress: Double {
        guard let goal = Double(savingsGoal), goal > 0 else {
            return 0.0
        }
        return currentSavings / goal
    }
    
    private var remainingGoal: Double {
        guard let goal = Double(savingsGoal) else {
            return 0
        }
        return max(goal - currentSavings, 0)
    }

    var body: some View {
        let gradient = LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.green.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
        
        ZStack {
            gradient.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Money Goal Tracker")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                HStack {
                    Text("Goal: ")
                    TextField("Enter your goal", text: $savingsGoal)
                        .keyboardType(.decimalPad)
                        .onChange(of: savingsGoal) { _ in saveData() }
                }
                .padding()
                .border(Color.gray, width: 2)

                TextField("Enter amount to add or withdraw", text: $amountToAddOrWithdraw)
                    .keyboardType(.decimalPad)
                    .padding()
                    .border(Color.gray, width: 2)

                HStack(spacing: 10) {
                    Button("Withdraw Savings") {
                        if let amount = Double(amountToAddOrWithdraw), currentSavings - amount >= 0 {
                            currentSavings -= amount
                            amountToAddOrWithdraw = "" // Reset input field
                            saveData()
                        }
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.orange)
                    .cornerRadius(10)
                    
                    Button("Add Savings") {
                        if let amount = Double(amountToAddOrWithdraw) {
                            currentSavings += amount
                            amountToAddOrWithdraw = "" // Reset input field
                            saveData()
                        }
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(10)
                }

                    

                Button("Reset") {
                    currentSavings = 0.0
                    saveData() // Save the reset state
                }
                .padding()
                .foregroundColor(.white)
                .background(Color.red)
                .cornerRadius(10)

                SavingsGoalVisualization(totalGoal: Double(savingsGoal) ?? 0, currentSavings: currentSavings)
                    .padding(.horizontal)
                Text("Current Savings: \(currentSavings, specifier: "%.2f")") // This line displays the current amount
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.green)
                    .padding()
                
                HStack {
                    Text(String(format: "%.1f", progress * 100))
                        .font(.title) 
                        .fontWeight(.semibold) 
                    Text("%")
                        .font(.title)
                        .fontWeight(.semibold) 
                    Text("of your goal achieved")
                        .fontWeight(.regular) 
                }
                .padding()

                Text("\(remainingGoal, specifier: "%.2f") left to reach the goal")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.red)
                    .padding()
            }
            .padding()
        }
        .onTapGesture {
            self.dismissKeyboard()
        }
    }
    
    private func saveData() {
        UserDefaults.standard.set(savingsGoal, forKey: "savingsGoal")
        UserDefaults.standard.set(currentSavings, forKey: "currentSavings")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct SavingsGoalVisualization: View {
    var totalGoal: Double
    var currentSavings: Double
    let segmentCount: Int = 10 // For example, for a goal of 10000 with each segment representing 1000
    
    var filledSegmentCount: Int {
        guard totalGoal > 0 else { return 0 }
        let progress = currentSavings / totalGoal
        return Int((Double(segmentCount) * progress).rounded(.down))
    }
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<segmentCount, id: \.self) { index in
                Rectangle()
                    .foregroundColor(index < filledSegmentCount ? Color.green : Color.gray.opacity(0.3))
            }
        }
        .frame(height: 20)
        .cornerRadius(5)
    }
}

#if canImport(UIKit)
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

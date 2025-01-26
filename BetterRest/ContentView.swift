//
//  ContentView.swift
//  BetterRest
//
//  Created by Stefan Olarescu on 19.10.2024.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 7.5
    @State private var coffeeAmount = Int.zero
    
    private static var defaultWakeTime: Date {
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = .zero
        return Calendar.current.date(from: dateComponents) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker(
                        "Please enter a time",
                        selection: $wakeUp,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                }
                
                Section("Desired amount of sleep") {
                    Stepper(
                        "\(sleepAmount.formatted()) hours",
                        value: $sleepAmount,
                        in: 4...12,
                        step: 0.25
                    )
                }
                
                Section("Daily coffee intake") {
                    Picker(
                        "Amount",
                        selection: $coffeeAmount
                    ) {
                        ForEach(0...20, id: \.self) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }
                }
                
                Section("Recommended bedtime") {
                    Text(
                        (calculateBedtime() ?? calculateDefaultBedtime())
                            .formatted(
                                date: .omitted,
                                time: .shortened
                            )
                    )
                    .font(.largeTitle)
                }
            }
            .navigationTitle("BetterRest")
        }
    }
    
    private func calculateBedtime() -> Date? {
        do {
            let modelConfiguration = MLModelConfiguration()
            let model = try SleepCalculator(configuration: modelConfiguration)
            
            let dateComponents = Calendar.current.dateComponents(
                [.hour, .minute],
                from: wakeUp
            )
            let hour = (dateComponents.hour ?? .zero) * 60 * 60
            let minute = (dateComponents.minute ?? .zero) * 60
            
            let prediction = try model.prediction(
                wake: Double(hour + minute),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime
        } catch {
            return nil
        }
    }
    
    private func calculateDefaultBedtime() -> Date {
        let hour = Int(sleepAmount)
        let minute = Int((sleepAmount - Double(hour)) * 60)

        return wakeUp - Double(hour + minute)
    }
}

#Preview {
    ContentView()
}

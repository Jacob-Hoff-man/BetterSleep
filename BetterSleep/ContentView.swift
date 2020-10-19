//
//  ContentView.swift
//  BetterSleep
//
//  Created by Jacob on 10/19/20.
//  Copyright © 2020 Jacob. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepHours = 8.0
    @State private var coffees = 1
    
    //result alert properties
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    
    
    var body: some View {
        NavigationView {
            Form {
                //wrapping each input section in a Section to make the Form treat the combination as a single row
                //wakeUp input
                Section(header: Text("What time would you like to wake up?")) {
                    DatePicker("Enter the time:",
                               selection: $wakeUp,
                               displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                }
                
                //sleepHours input
                Section(header: Text("What is your desired amount of sleep?")) {
                    Stepper(value: $sleepHours, in: 4...12, step: 0.25) {
                        Text("\(sleepHours, specifier: "%g") hours")
                    }
                }

                //coffees input
                Section(header: Text("What is your daily intake of coffee?")) {
                    Stepper(value: $coffees, in: 0...20) {
                        if coffees == 1 {
                            Text("1 cup")
                        } else {
                            Text("\(coffees) cups")
                        }
                    }
                }

            }
            .navigationBarTitle("Better Sleep")
            .navigationBarItems(trailing:
                Button(action: bedTime) {
                    Text("Calculate")
            })
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text(alertTitle),
                          message: Text(alertMessage),
                          dismissButton: .default(Text("Continue")))
            }
        }
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private func bedTime() {
        let model = SleepCalculator()
        //input wake up time, sleepHours, and coffees
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepHours, coffee: Double(coffees))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            alertMessage = formatter.string(from: sleepTime)
            alertTitle = "Your ideal bed time is the following:"
        } catch {
            //there was an error
            alertTitle = "Error!"
            alertMessage = "There was an error when calculating bed time."
        }
        
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

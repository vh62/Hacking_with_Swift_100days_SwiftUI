//
//  ContentView.swift
//  BetterRest
//
//  Created by Vikram Ho on 10/24/20.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView{
            Form{
                Section(header: Text("What time do you want to wake up?")){
//                VStack(alignment: .leading, spacing: 0){
//                    Text("When do you want to wake up?")
//                        .font(.headline)
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                }
                Section(header: Text("Desire amount of sleep")){
//                    Text("Desired amount of sleep")
//                        .font(.headline)
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25){
                        Text("\(sleepAmount,specifier: "%g")hours")
                    }
                }
                Section(header: Text("Daily coffee intake")){
//                VStack(alignment: .leading, spacing: 0){
//                    Text("Daily coffee intake")
//                        .font(.headline)
//                    Stepper(value: $coffeeAmount, in: 1...20){
//                        if coffeeAmount == 1{
//                            Text("1 cup")
//                        }else{
//                            Text("\(coffeeAmount) cups")
//                        }
//                    }
                    Picker("Number of cups of coffee", selection: $coffeeAmount){
                        ForEach(0..<20){
                            number in Text("\(number) cups")
                        }
                    }
                }
                Section(header: Text("Your ideal bedtime is... ")){
                    Text(calculateBedTime())
                        .font(.largeTitle)
                }
                Section{
                    HStack{
                        Spacer()
                        Button(action: calculateBedTiming){
                            Text("Calculate")
                        }
                        Spacer()
                    }
                    
                }
                
            }
            .navigationBarTitle("BetterRest")
//            .navigationBarItems(trailing:
//                Button(action: calculateBedTiming){
//                Text("Calculate")
//            })
            
            .alert(isPresented: $showingAlert){
                Alert(title: Text(alertTitle),message: Text(alertMessage).font(.largeTitle),dismissButton: .default(Text("OK")))
            }
        }
        
    }
    static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from:components) ?? Date()
    
    }
    func calculateBedTime() -> String{
        let model = SleepCalculator()
        let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0 ) * 60
        do {
            let prediction = try model.prediction(wake: Double(hour + minute ), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            return formatter.string(from:sleepTime)
        }catch{
            
            return "Sorry, there was a problem calculating your bedtime"
        }
    }
    func calculateBedTiming(){
        let model = SleepCalculator()
        let components = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        do{
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            alertMessage = formatter.string(from:sleepTime)
            alertTitle = "Your ideal bedtime is..."
        }catch{
            alertTitle = "Error"
            alertMessage = "There was a problem"
        }
        showingAlert = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

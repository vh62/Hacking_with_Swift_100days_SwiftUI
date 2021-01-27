//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Vikram Ho on 10/22/20.
//

import SwiftUI

//struct ContentView: View {
//    var body: some View {
//        ZStack(alignment: .center){
//            Color(red: 1, green: 0.8, blue: 2).frame(width: 200, height: 200, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
//            Text("First")
//        }
//        .background(Color.red)
//
//    }
//}

struct Title: ViewModifier{
    func body(content: Content) -> some View{
        content
            .foregroundColor(.white)
            .padding()
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
struct watermark: ViewModifier{
    var text:String
    func body(content:Content) -> some View{
        ZStack(alignment: .bottomTrailing){
            content
            
            Text(text)
                .font(.caption)
                .foregroundColor(.white)
                .padding(5)
                .background(Color.black)
        }
    }
}

extension View{
    func watermark(with text:String) -> some View{
        self.modifier(GuessTheFlag.watermark(text: text))
    }
}
extension View{
    func titleStyle() -> some View{
        self.modifier(Title())
    }
}
struct FlagImage :View{
    let country: String
    var body: some View{
        Image(country)
            .renderingMode(.original)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.black, lineWidth: 4))
            .shadow(color:.black, radius: 2)
    }
}
struct ContentView: View{
    
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"]
    @State private var correctAns = Int.random(in: 0...2)
    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var score = 0
    @State private var spreeCounter = 0
    @State private var onASpree = false
    @State private var animationAmount = 0.0
    @State private var rotationAmount = 0.0
    @State var attempts: Int = 0
    var body: some View{
        ZStack{
            LinearGradient(gradient: Gradient(colors: [.blue,.black]), startPoint: .top, endPoint: .bottom ).edgesIgnoringSafeArea(.all)
                .watermark(with: "Created by Vikram")
            VStack(spacing: 20){
                VStack(spacing: 40){
                    Text("Tap the flag off")
                        .foregroundColor(.white)
                        
                    Text(countries[correctAns])
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .fontWeight(.black)
                    
                    ForEach(0..<3){ number in
                        Button(action: {
                            self.flagTapped(number)
                            
                        })
                        {
                            FlagImage(country: self.countries[number])
                        }
                        // if a correct flag is tapped rotate the flag
                        .rotation3DEffect(.degrees(number == self.correctAns ? self.rotationAmount : 0), axis: (x: 0, y: 1, z: 0))
                        .opacity(self.showingScore && number != self.correctAns ? 0.25 : 1)
                        }
                    .modifier(Shake(animatableData: CGFloat(self.attempts)))
                    
                    Text("Current score is: \(score)")
                        .titleStyle()
                    Spacer()
                }
            }
        }
        .alert(isPresented: $showingScore){
            if onASpree == false{
                return Alert(title: Text(scoreTitle),
                             message: Text("Your score is: \(score) "),
                             dismissButton: .default(Text("Continue")){
                               self.askQuestion()
                       })
            }else{
                return Alert(title: Text(scoreTitle),
                             message: Text("Your score is: \(score). You are on a winning spree!"),
                             dismissButton: .default(Text("Continue")){
                               self.askQuestion()
                       })
            }
        }
    }
    
    func flagTapped(_ number:Int){
        if number == correctAns{
            scoreTitle = "Correct"
            score = score + 1
            spreeCounter = spreeCounter + 1
            if(spreeCounter > 3){
                onASpree = true
            }
            withAnimation(.spring()){
                self.rotationAmount += 360
            }
        }else{
            scoreTitle = "Wrong, that's the country of: \(countries[number])"
            if(score > 0){
                score = score - 1
            }
            spreeCounter = 0
            onASpree = false
            withAnimation(.default){
                attempts += 9
            }
        }
        showingScore = true
            
    }
    func askQuestion(){
        countries.shuffle()
        correctAns = Int.random(in: 0...2)
        attempts = 0
    }
    
}

struct Shake: GeometryEffect{
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
            ProjectionTransform(CGAffineTransform(translationX:
                amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0))
        }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

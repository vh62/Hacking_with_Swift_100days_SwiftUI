//
//  ContentView.swift
//  WordScramble
//
//  Created by Vikram Ho on 10/24/20.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var playerScore = 0
    
    var body: some View {
        NavigationView{
            VStack{
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    .padding()
                List(usedWords, id: \.self){
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                Text("Current score is \(playerScore)")
            }
            .navigationTitle(rootWord)
            .navigationBarItems(trailing: Button(action:startGame){
                Text("New Game")
            })
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError){
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    
    
    func addNewWord(){
        let answer =
            newWord.lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else{
            return
        }
        
        guard isOriginal(word: answer) else{
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard isPossible(word: answer) else{
            wordError(title: "Word not recognized", message: "You can't just make them up!")
            return
        }
        guard isReal(word: answer) else{
            wordError(title: "Word not possible" , message: "That isn't a real word")
            return
        }
        
        if rootWord.contains(answer){
            playerScore = playerScore + 1
        }
        usedWords.insert(answer, at:0)
        newWord = ""
    }
    
    func startGame(){
        playerScore = 0
        usedWords.removeAll()
        if let startWordsURL = Bundle.main.url(forResource:"start", withExtension: "txt"){
            if let startWords = try?
                String(contentsOf: startWordsURL){
                let allWords =
                    startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool{
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) ->Bool{
        var tempWord = rootWord.lowercased()
        
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) ->Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        if word.count < 3{
            return false
        }
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title:String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

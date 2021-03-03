//
//  ContentView.swift
//  WordScrambelUI
//
//  Created by Ravi Singh on 13/06/20.
//  Copyright © 2020 Ravi Singh. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWords)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                .padding()
                
                List(usedWords, id: \.self) {
                    Text($0)
                    
                }
            }
        .navigationBarTitle(rootWord)
        .onAppear(perform: startGame)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            
            
        }
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible (word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
            
        }
        
        return true
    }
    
    func isReal (word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func addNewWords() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return}
        
        guard isOriginal(word: answer) else {
            showingError(title: "Word already used", message: "Try another word")
            return
        }
        
        guard isPossible(word: answer) else {
            showingError(title: "word not recognize", message: "")
            return
        }
        
        guard isReal(word: answer ) else {
            showingError(title: "word not possible", message: "")
            return
        }
        
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func startGame() {
        if let wordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: wordURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "no word"
                return
            }
        }
        
        fatalError("could not load start text from bundle")
        
    }
    
    func showingError (title: String, message : String) {
        errorTitle = title
        errorMessage = message
        showingAlert = true
        return
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

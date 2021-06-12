//
//  GameLogic.swift
//  QuizApp
//
//  Created by Kapil Rathore on 12/06/21.
//

import Foundation

protocol GameViewUpdate: AnyObject {
    func renderLogo()
    func renderGameEnded()
    func renderGamePaused(_ paused: Bool)
    func updateTimer()
    func revealLogoName(at index: Int, _ char: String)
    func updatePoints()
}

class GameLogic {
    private weak var viewUpdate: GameViewUpdate?
    private let logoProvider: LogoProviderType
    private var quizLogos: [Logo] = []
    private var displayLogos: [Logo] = []
    private let maxCounter = 60
    private var answerToGuess: [Character] = []
    private var isPaused = false
    private var timer: Timer?
    
    init(viewUpdate: GameViewUpdate, logoProvider: LogoProviderType) {
        self.viewUpdate = viewUpdate
        self.logoProvider = logoProvider
    }
    
    // To render UI
    private(set) var counter = 5
    private(set) var points = 0
    private(set) var currentLogo: Logo?
    private(set) var answerOptions: [String] = []
    var currentLevelString: String {
        guard let logo = self.currentLogo else { return "Ended" }
        let index = self.quizLogos.firstIndex(where: { $0 == logo })
        if let validIndex = index {
            return "Level: \(validIndex + 1)"
        }
        return "Ended"
    }
    
    // Actions From UI
    func startGame() {
        self.quizLogos = self.logoProvider.fetchLogos()
        self.displayLogos = self.quizLogos
        self.updateNextQuestion()
    }
    
    func pauseResumeGame() {
        if self.isPaused {
            self.startTimer()
        } else {
            self.timer?.invalidate()
        }
        
        self.isPaused.toggle()
        self.viewUpdate?.renderGamePaused(self.isPaused)
    }
    
    func resetCounter() {
        self.counter = maxCounter
        self.startTimer()
    }
    
    func submitAnswer(_ char: Character) {
        if let index = self.answerToGuess.firstIndex(of: char) {
            self.viewUpdate?.revealLogoName(at: index, "\(char)")
            self.points += (counter*10)/maxCounter
            self.answerToGuess[index] = "0"
            
            if self.answerToGuess.allSatisfy({ $0 == "0" }) {
                self.points += (counter*100)/maxCounter
                self.updateNextQuestion()
            }
            
        } else {
            self.counter -= 3
            self.viewUpdate?.updateTimer()
        }
        
        self.viewUpdate?.updatePoints()
    }
    
    // private functions
    private func randomString(length: Int) -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map { _ in letters.randomElement()! } )
    }
    
    private func updateNextQuestion() {
        guard !self.displayLogos.isEmpty else {
            self.endGame()
            return
        }
        
        self.currentLogo = self.displayLogos.removeFirst()
        self.answerToGuess = Array(self.currentLogo?.name ?? "")
        self.setupAnswerOptions()
        self.counter = maxCounter
        self.viewUpdate?.updateTimer()
        self.viewUpdate?.renderLogo()
    }
    
    private func setupAnswerOptions() {
        // 2 strings to show options in 2 rows
        let maxOptions = 20
        guard let name = self.currentLogo?.name else { return }
        let remaingChars = self.randomString(length: maxOptions - name.count)
        
        let shuffledOptions = (name + remaingChars).shuffled()
        let firstHalf = shuffledOptions[0..<10]
        let secondHalf = shuffledOptions[10..<maxOptions]
        
        self.answerOptions = [String(firstHalf), String(secondHalf)]
    }
    
    private func startTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    private func endGame() {
        self.timer?.invalidate()
        self.viewUpdate?.renderGameEnded()
    }
    
    @objc func updateCounter() {
        if self.counter == 0 {
            self.updateNextQuestion()
        } else {
            self.counter -= 1
        }
        
        self.viewUpdate?.updateTimer()
    }
}

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
    func updateTimer(count: Int)
    func revealLogoName(at index: Int, _ char: String)
    func updatePoints(points: Int)
}

class GameLogic {
    private weak var viewUpdate: GameViewUpdate?
    private let logoProvider: LogoProviderType
    
    private var quizLogos: [Logo] = []
    private var displayLogos: [Logo] = []
    private var points = 0
    
    private lazy var timer: GameTimer = {
        GameTimer(maxCounter: 60, delegate: self)
    }()
    
    private var answerToGuess: [Character] = []
    private var isPaused = false
    
    
    init(viewUpdate: GameViewUpdate, logoProvider: LogoProviderType) {
        self.viewUpdate = viewUpdate
        self.logoProvider = logoProvider
    }
    
    // To render UI
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
            self.timer.startTimer()
        } else {
            self.timer.invalidate()
        }
        
        self.isPaused.toggle()
        self.viewUpdate?.renderGamePaused(self.isPaused)
    }
    
    func submitAnswer(_ char: Character) {
        if let index = self.answerToGuess.firstIndex(of: char) {
            self.viewUpdate?.revealLogoName(at: index, "\(char)")
            self.points += self.timer.getPoints(partial: true)
            self.answerToGuess[index] = "0"
            
            if self.answerToGuess.allSatisfy({ $0 == "0" }) {
                self.points += self.timer.getPoints(partial: false)
                self.updateNextQuestion()
            }
        } else {
            self.timer.decreaseCount(by: 3)
        }
        
        self.viewUpdate?.updatePoints(points: self.points)
    }
    
    func resetCounter() {
        self.timer.resetCounter()
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
        self.timer.resetCounter()
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
    
    private func endGame() {
        self.timer.invalidate()
        self.viewUpdate?.renderGameEnded()
    }
    
}

extension GameLogic: TimerDelegate {
    func updateTimer(count: Int) {
        self.viewUpdate?.updateTimer(count: count)
    }
    
    func timerFinished() {
        self.updateNextQuestion()
    }
}

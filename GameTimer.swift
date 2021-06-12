//
//  GameTimer.swift
//  QuizApp
//
//  Created by Kapil Rathore on 12/06/21.
//

import Foundation

protocol TimerDelegate: AnyObject {
    func updateTimer(count: Int)
    func timerFinished()
}

class GameTimer {
    private var timer: Timer?
    private let maxCounter: Int
    private var counter = 5
    
    private weak var delegate: TimerDelegate?
    
    init(maxCounter: Int, delegate: TimerDelegate) {
        self.maxCounter = maxCounter
        self.delegate = delegate
    }
    
    func getPoints(partial: Bool) -> Int {
        return (counter*(partial ? 10 : 100))/maxCounter
    }
    
    func resetCounter() {
        self.counter = maxCounter
        self.startTimer()
    }
    
    func startTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    func invalidate() {
        self.timer?.invalidate()
    }
    
    func decreaseCount(by value: Int) {
        self.counter -= value
        self.delegate?.updateTimer(count: counter)
    }
    
    @objc func updateCounter() {
        if self.counter <= 0 {
            self.delegate?.timerFinished()
        } else {
            self.counter -= 1
        }
        
        self.delegate?.updateTimer(count: self.counter)
    }
}

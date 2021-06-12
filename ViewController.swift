//
//  ViewController.swift
//  QuizApp
//
//  Created by Kapil Rathore on 12/06/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var scoreLabel: UILabel!
    @IBOutlet private weak var timerLabel: UILabel!
    @IBOutlet private weak var answerStackView: UIStackView!
    @IBOutlet private weak var optionsStackViewTop: UIStackView!
    @IBOutlet private weak var optionsStackViewBottom: UIStackView!
    @IBOutlet private weak var playpauseButton: UIButton!
    @IBOutlet private weak var loadingView: UIActivityIndicatorView!
    
    private let logoProvider = LogoProvider()
    private let imageLoader = ImageLoader()
    private lazy var gameLogic: GameLogic = {
        GameLogic(viewUpdate: self, logoProvider: self.logoProvider)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.gameLogic.startGame()
    }
    
    @IBAction private func playPauseGame(_ sender: UIButton) {
        self.gameLogic.pauseResumeGame()
    }
    
    private func addAnswerLabels(for logoName: String) {
        self.answerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        logoName.forEach { _ in
            let label = UILabel(frame: .init(x: 0, y: 0, width: 32, height: 32))
            label.backgroundColor = .cyan
            label.textAlignment = .center
            label.text = "?"
            self.answerStackView.addArrangedSubview(label)
        }
    }
    
    private func addAnswerOptions(for options: [String]) {
        self.optionsStackViewTop.arrangedSubviews.forEach { $0.removeFromSuperview() }
        self.optionsStackViewBottom.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        options.first?.forEach { char in
            let button = self.createButton(with: char)
            self.optionsStackViewTop.addArrangedSubview(button)
        }
        
        options.last?.forEach { char in
            let button = self.createButton(with: char)
            self.optionsStackViewBottom.addArrangedSubview(button)
        }
    }
    
    private func createButton(with char: Character) -> UIButton {
        let button = UIButton()
        button.frame = .init(x: 0, y: 0, width: 32, height: 32)
        button.setTitle("\(char)", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .darkGray
        button.addTarget(self, action: #selector(submitAnswer(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func submitAnswer(_ sender: UIButton) {
        guard let char = sender.currentTitle?.first else { return }
        self.gameLogic.submitAnswer(char)
        sender.isEnabled = false
        sender.backgroundColor = .red
    }
}

extension ViewController: GameViewUpdate {
    func updateTimer(count: Int) {
        self.timerLabel.text = "Timer: \(count)"
    }
    
    func updatePoints(points: Int) {
        self.scoreLabel.text = "Points: \(points)"
    }
    
    func revealLogoName(at index: Int, _ char: String) {
        guard let label = self.answerStackView.arrangedSubviews[index] as? UILabel else { return }
        label.backgroundColor = .green
        label.text = "\(char)"
    }
    
    func renderGameEnded() {
        self.logoImageView.isHidden = true
        self.answerStackView.isHidden = true
        self.optionsStackViewTop.isHidden = true
        self.optionsStackViewBottom.isHidden = true
        self.playpauseButton.isEnabled = false
        self.playpauseButton.setTitle("Game Finished", for: .normal)
    }
    
    func renderGamePaused(_ paused: Bool) {
        self.playpauseButton.setTitle(paused ? "Play" : "Pause", for: .normal)
        
        self.logoImageView.isHidden = paused
        self.answerStackView.isHidden = paused
        self.optionsStackViewTop.isHidden = paused
        self.optionsStackViewBottom.isHidden = paused
    }
    
    func renderLogo() {
        self.loadingView.isHidden = false
        guard let logo = self.gameLogic.currentLogo else {
            // TODO:- Show error or retry
            return
        }
        
        DispatchQueue.global().async {
            self.imageLoader.loadLogo(from: logo.imgUrl) { image in
                DispatchQueue.main.async {
                    self.loadingView.isHidden = true
                    self.gameLogic.resetCounter()
                    self.logoImageView.image = image
                    self.addAnswerLabels(for: logo.name)
                    self.addAnswerOptions(for: self.gameLogic.answerOptions)
                }
            }
        }
    }
}

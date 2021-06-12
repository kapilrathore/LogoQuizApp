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
            let button = UIButton()
            button.frame = .init(x: 0, y: 0, width: 32, height: 32)
            button.setTitle("\(char)", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .darkGray
            self.optionsStackViewTop.addArrangedSubview(button)
        }
        
        options.last?.forEach { char in
            let button = UIButton()
            button.frame = .init(x: 0, y: 0, width: 32, height: 32)
            button.setTitle("\(char)", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .darkGray
            self.optionsStackViewBottom.addArrangedSubview(button)
        }
    }
}

extension ViewController: GameViewUpdate {
    func revealLogoName(at index: Int, _ char: String) {
        // TODO:- change label text from ? to char
    }
    
    func renderGameEnded() {
        // TODO: - show popup
    }
    
    func renderGamePaused(_ paused: Bool) {
        self.playpauseButton.setTitle(paused ? "Play" : "Pause", for: .normal)
        
        self.logoImageView.isHidden = paused
        self.answerStackView.isHidden = paused
        self.optionsStackViewTop.isHidden = paused
        self.optionsStackViewBottom.isHidden = paused
    }
    
    func updateTimer() {
        self.timerLabel.text = "Timer: \(self.gameLogic.counter)"
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

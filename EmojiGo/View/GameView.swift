//  GameView.swift
//  EmojiGo
//  Created by Tong Li on 12/13/24.

import UIKit
import SceneKit
import ARKit
import Vision

// MARK: - GameView
class GameView {
    private(set) var countdownLabel: UILabel
    private(set) var detectedEmotionLabel: UILabel
    private(set) var statusLabel: UILabel // New status label for correct/wrong indication
    private(set) var gameOverlay: UIView?

    init(frame: CGRect) {
        countdownLabel = UILabel(frame: CGRect(x: 20, y: 50, width: 100, height: 50))
        countdownLabel.text = "20"
        countdownLabel.font = UIFont.boldSystemFont(ofSize: 24)
        countdownLabel.textColor = .white
        countdownLabel.backgroundColor = .black
        countdownLabel.textAlignment = .center
        countdownLabel.layer.cornerRadius = 5
        countdownLabel.layer.masksToBounds = true

        detectedEmotionLabel = UILabel(frame: CGRect(x: frame.width - 120, y: 50, width: 100, height: 50))
        detectedEmotionLabel.font = UIFont.boldSystemFont(ofSize: 16)
        detectedEmotionLabel.textColor = .white
        detectedEmotionLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        detectedEmotionLabel.textAlignment = .center
        detectedEmotionLabel.layer.cornerRadius = 5
        detectedEmotionLabel.layer.masksToBounds = true

        // Status label for correct or wrong indication
        statusLabel = UILabel(frame: CGRect(x: frame.width - 120, y: 110, width: 100, height: 50))
        statusLabel.font = UIFont.boldSystemFont(ofSize: 16)
        statusLabel.textColor = .white
        statusLabel.backgroundColor = UIColor.clear
        statusLabel.textAlignment = .center
        statusLabel.layer.cornerRadius = 5
        statusLabel.layer.masksToBounds = true
    }

    func setupUI(in view: UIView) {
        view.addSubview(countdownLabel)
        view.addSubview(detectedEmotionLabel)
        view.addSubview(statusLabel) // Add status label to view
    }

    func updateCountdownLabel(with value: Int) {
        countdownLabel.text = "\(value)"
    }

    func updateDetectedEmotionLabel(with emotion: String, isCorrect: Bool?) {
        if let emojiImage = UIImage(named: emotion) {
            let emojiImageView = UIImageView(image: emojiImage)
            emojiImageView.frame = detectedEmotionLabel.bounds
            emojiImageView.contentMode = .scaleAspectFit

            // Remove existing subviews
            detectedEmotionLabel.subviews.forEach { $0.removeFromSuperview() }
            detectedEmotionLabel.addSubview(emojiImageView)
        } else {
            detectedEmotionLabel.text = emotion
        }

        // Update status label based on correctness
        if let isCorrect = isCorrect {
            if isCorrect {
                statusLabel.text = "✅" // Green checkmark
                statusLabel.textColor = .systemGreen
            } else {
                statusLabel.text = "❌" // Red cross
                statusLabel.textColor = .systemRed
            }
        } else {
            statusLabel.text = ""
        }
    }

    func showGameOverlay(in view: UIView, score: Int, restartHandler: @escaping () -> Void, homeHandler: @escaping () -> Void) {
        gameOverlay = UIView(frame: view.bounds)
        gameOverlay?.backgroundColor = UIColor.black.withAlphaComponent(0.8)

        let scoreLabel = UILabel(frame: CGRect(x: 50, y: 300, width: view.bounds.width - 100, height: 50))
        scoreLabel.text = "Score: \(score)"
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 30)
        scoreLabel.textColor = .white
        scoreLabel.textAlignment = .center
        scoreLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        gameOverlay?.addSubview(scoreLabel)

        let playAgainButton = UIButton(type: .system)
        playAgainButton.setTitle("Replay", for: .normal)
        playAgainButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        playAgainButton.setTitleColor(.white, for: .normal)
        playAgainButton.backgroundColor = UIColor.systemGreen
        playAgainButton.layer.cornerRadius = 10
        playAgainButton.frame = CGRect(x: (view.bounds.width - 200) / 2, y: 500, width: 200, height: 50)
        playAgainButton.addTarget(self, action: #selector(playAgainTapped(_:)), for: .touchUpInside)
        gameOverlay?.addSubview(playAgainButton)

        let homeButton = UIButton(type: .system)
        homeButton.setTitle("Home", for: .normal)
        homeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 24)
        homeButton.setTitleColor(.white, for: .normal)
        homeButton.backgroundColor = UIColor.systemBlue
        homeButton.layer.cornerRadius = 10
        homeButton.frame = CGRect(x: (view.bounds.width - 200) / 2, y: 580, width: 200, height: 50)
        homeButton.addTarget(self, action: #selector(homeTapped), for: .touchUpInside)
        gameOverlay?.addSubview(homeButton)

        view.addSubview(gameOverlay!)

        // Save handlers
        self.restartHandler = restartHandler
        self.homeHandler = homeHandler
    }

    func removeGameOverlay() {
        gameOverlay?.removeFromSuperview()
        gameOverlay = nil
    }

    @objc private func playAgainTapped(_ sender: UIButton) {
        restartHandler?()
    }

    @objc private func homeTapped(_ sender: UIButton) {
        homeHandler?()
    }
    
    
    func resetDetectedEmotionLabel() {
        detectedEmotionLabel.text = "" // Clear detected emotion display
        detectedEmotionLabel.backgroundColor = .clear // Restore background color
    }


    private var restartHandler: (() -> Void)?
    private var homeHandler: (() -> Void)?
}


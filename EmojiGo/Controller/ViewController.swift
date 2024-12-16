//
//  ViewController.swift
//  EmojiGo
//
//  Created by Tong Li on 12/10/24.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionObserver, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    private var gameModel = GameModel.shared

    private var gameView: GameView!
    private var emotionAnalyzer: EmotionAnalyzer!
    private var arSetup: ARSetup!
    private var countdownTimer: Timer?
    private var floorAndPlankView: FloorAndPlankView!
    
    private var hasStartedFaceDetection = false // Prevent duplicate start of face detection
    private var preStartCountdownLabel: UILabel! // Used to display "3, 2, 1, Go!"
    
    private let imagePreprocessor = ImagePreprocessor() // Add preprocessor instance

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize AR session
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        arSetup = ARSetup(sceneView: sceneView)

        // Add initial floor
        floorAndPlankView = FloorAndPlankView(sceneView: sceneView)
        floorAndPlankView.addInitialFloors()
        // Start plank periodic refresh
            floorAndPlankView.startPlankRefreshTimer()

        // Ensure initialization
        emotionAnalyzer = EmotionAnalyzer()
        gameView = GameView(frame: view.bounds)
        gameView.setupUI(in: view)
        
        // Start the pre-start countdown of the game
        startPreStartCountdown()
        
//        setupGame()

        // Delay the start of face detection
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("Starting face detection...")
            self.startFaceDetection()
        }
    }
    // MARK: - Game pre-start countdown
        private func startPreStartCountdown() {
            preStartCountdownLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
            preStartCountdownLabel.center = view.center
            preStartCountdownLabel.textAlignment = .center
            preStartCountdownLabel.font = UIFont.boldSystemFont(ofSize: 48)
            preStartCountdownLabel.textColor = .white
            preStartCountdownLabel.text = "3"
            view.addSubview(preStartCountdownLabel)

            var countdownValue = 3

            // Countdown logic
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self else { return }

                if countdownValue > 1 {
                    countdownValue -= 1
                    self.preStartCountdownLabel.text = "\(countdownValue)"
                } else if countdownValue == 1 {
                    self.preStartCountdownLabel.text = "Go!"
                    countdownValue -= 1
                } else {
                    // Countdown ends, remove label and start the game
                    self.preStartCountdownLabel.removeFromSuperview()
                    timer.invalidate()
                    self.startGame()
                }
            }
        }
    // MARK: - Start game
        private func startGame() {
            setupGame()
            startFaceDetection()
        }
    
    private func setupGame() {
        gameModel.reset()
        gameView.updateCountdownLabel(with: gameModel.countdownValue)
        startCountdown()
    }

    // MARK: - Face Detection
    private func startFaceDetection() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self,
                  let frame = self.sceneView.session.currentFrame else {
                print("ARSession currentFrame is unavailable...")
                return
            }
            
            // Preprocess the frame
            if let processedPixelBuffer = self.imagePreprocessor.process(pixelBuffer: frame.capturedImage) {
                self.emotionAnalyzer.analyze(pixelBuffer: processedPixelBuffer) { detectedEmotion in
                    DispatchQueue.main.async {
                        guard let detectedEmotion = detectedEmotion else { return }
                        self.handleDetectedEmotion(detectedEmotion)
                    }
                }
            } else {
                print("Failed to process pixel buffer.")
            }
        }
    }


    private func handleDetectedEmotion(_ detectedEmotion: String) {
        // Only allow "fear," "happy," "surprise" emotions
        let validEmotions = ["fear", "happy", "surprise"]

        // Check if the detected emotion is within the valid range
        let normalizedEmotion = detectedEmotion.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard validEmotions.contains(normalizedEmotion) else {
            print("Ignored Emotion: \(detectedEmotion)") // Ignore invalid emotions
            return
        }

        // Ensure the current plank exists and has not been scored
        guard let currentPlankEmoji = GameModel.shared.currentPlankEmoji,
              !GameModel.shared.hasScoredOnCurrentPlank else {
            print("No plank to score or already scored.")
            return
        }

        //print("Detected Emotion: \(normalizedEmotion)")
        //print("Current Plank Emoji: \(currentPlankEmoji)")

        // Determine if it matches
        let isCorrect = GameModel.shared.checkEmotionMatch(detectedEmotion: normalizedEmotion)

        // Update UI to show match result
        gameView.updateDetectedEmotionLabel(with: normalizedEmotion, isCorrect: isCorrect)

        // Output results
        if isCorrect {
            print("Matched! Current Score: \(GameModel.shared.score)")
        } else {
            print("No Match! Score remains: \(GameModel.shared.score)")
        }
    }



    // MARK: - Countdown Timer
    private func startCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }

    @objc private func updateCountdown() {
        if gameModel.updateCountdown() {
            endGame()
        } else {
            gameView.updateCountdownLabel(with: gameModel.countdownValue)
        }
    }

    private func endGame() {
        // Stop countdown timer
        countdownTimer?.invalidate()
        // Stop game logic
        floorAndPlankView.stopGame()
        
        // Display the end screen and handle button actions
        gameView.showGameOverlay(in: view, score: gameModel.score, restartHandler: { [weak self] in
            self?.restartGame()
        }, homeHandler: { [weak self] in
            self?.navigateToHome()
        })
    }

    private func restartGame() {
        // Stop game logic and clean up the scene
        floorAndPlankView.stopGame()

        // Reset game model state
        gameModel.reset()

        // Reinitialize the scene
        floorAndPlankView.addInitialFloors() // Add initial floors
        floorAndPlankView.startPlankRefreshTimer() // Start plank timer

        // Update UI
        gameView.updateCountdownLabel(with: gameModel.countdownValue)
        gameView.resetDetectedEmotionLabel() // Reset emotion display state
        gameView.removeGameOverlay()

        // Restart the countdown
        startCountdown()

        // Ensure the game running flag is re-enabled
        floorAndPlankView.isGameRunning = true

        print("Game restarted successfully!")

    }

    private func navigateToHome() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - ARSessionObserver
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if !hasStartedFaceDetection {
            print("ARSession is ready. Starting face detection...")
            startFaceDetection()
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let detectedEmotion = GameModel.shared.detectedEmotion {
            // If the plank is on screen and has not been scored
            if floorAndPlankView.isPlankOnScreen, !GameModel.shared.hasScoredOnCurrentPlank {
                _ = GameModel.shared.checkEmotionMatch(detectedEmotion: detectedEmotion)
            }
        }
        floorAndPlankView.slideFloorsAndPlanks()
    }


}


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
    
    private var hasStartedFaceDetection = false // 防止重复启动表情检测
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 初始化 AR 会话
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        arSetup = ARSetup(sceneView: sceneView)

        // 添加初始地板
        floorAndPlankView = FloorAndPlankView(sceneView: sceneView)
        floorAndPlankView.addInitialFloors()

        // 初始化其他组件
        emotionAnalyzer = EmotionAnalyzer() // 确保初始化
        gameView = GameView(frame: view.bounds)
        gameView.setupUI(in: view)
        
        // 启动游戏
        setupGame() // 添加这一行，初始化倒计时

        // 延迟启动表情检测
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("Starting face detection...")
            self.startFaceDetection()
        }
    }

    
    private func setupGame() {
        gameModel.reset()
        gameView.updateCountdownLabel(with: gameModel.countdownValue)
        startCountdown()
    }

    // MARK: - Face Detection
    private func startFaceDetection() {
        guard !hasStartedFaceDetection else { return } // 防止重复启动
        hasStartedFaceDetection = true

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self, let frame = self.sceneView.session.currentFrame else {
                print("ARSession currentFrame is unavailable...")
                return
            }

            // 分析当前帧
            self.emotionAnalyzer.analyze(pixelBuffer: frame.capturedImage) { detectedEmotion in
                DispatchQueue.main.async {
                    guard let detectedEmotion = detectedEmotion else { return }
                    self.handleDetectedEmotion(detectedEmotion)
                }
            }
        }
    }

    private func handleDetectedEmotion(_ detectedEmotion: String) {
        print("Detected Emotion: \(detectedEmotion)")
        print("Current Plank Emoji: \(String(describing: gameModel.currentPlankEmoji))")
        
        let isCorrect = gameModel.checkEmotionMatch(detectedEmotion: detectedEmotion)
        gameView.updateDetectedEmotionLabel(with: detectedEmotion, isCorrect: isCorrect)
        
        if isCorrect {
            print("Matched! Current Score: \(gameModel.score)")
        } else {
            print("No Match! Score remains: \(gameModel.score)")
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
        countdownTimer?.invalidate()
        gameView.showGameOverlay(in: view, score: gameModel.score, restartHandler: { [weak self] in
            self?.restartGame()
        }, homeHandler: { [weak self] in
            self?.navigateToHome()
        })
    }

    private func restartGame() {
        gameView.removeGameOverlay()
        setupGame()
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
        // 滑动地板和木板
        floorAndPlankView.slideFloorsAndPlanks()
        floorAndPlankView.addPlank()
    }
}


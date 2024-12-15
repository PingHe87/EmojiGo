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
    private var preStartCountdownLabel: UILabel! // 用于显示 "3, 2, 1, Go!"
    
    private let imagePreprocessor = ImagePreprocessor() // 添加预处理器实例

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 初始化 AR 会话
        sceneView.delegate = self
        sceneView.scene = SCNScene()
        arSetup = ARSetup(sceneView: sceneView)

        // 添加初始地板
        floorAndPlankView = FloorAndPlankView(sceneView: sceneView)
        floorAndPlankView.addInitialFloors()
        // 启动木板固定间隔刷新
            floorAndPlankView.startPlankRefreshTimer()

        // 初始化其他组件
        emotionAnalyzer = EmotionAnalyzer() // 确保初始化
        gameView = GameView(frame: view.bounds)
        gameView.setupUI(in: view)
        
        // 启动游戏的预启动倒计时
        startPreStartCountdown()
        
//        // 启动游戏
//        setupGame() // 添加这一行，初始化倒计时

        // 延迟启动表情检测
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("Starting face detection...")
            self.startFaceDetection()
        }
    }
    // MARK: - 游戏预启动倒计时
        private func startPreStartCountdown() {
            preStartCountdownLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
            preStartCountdownLabel.center = view.center
            preStartCountdownLabel.textAlignment = .center
            preStartCountdownLabel.font = UIFont.boldSystemFont(ofSize: 48)
            preStartCountdownLabel.textColor = .white
            preStartCountdownLabel.text = "3"
            view.addSubview(preStartCountdownLabel)

            var countdownValue = 3

            // 倒计时逻辑
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
                guard let self = self else { return }

                if countdownValue > 1 {
                    countdownValue -= 1
                    self.preStartCountdownLabel.text = "\(countdownValue)"
                } else if countdownValue == 1 {
                    self.preStartCountdownLabel.text = "Go!"
                    countdownValue -= 1
                } else {
                    // 倒计时结束，移除标签并启动游戏
                    self.preStartCountdownLabel.removeFromSuperview()
                    timer.invalidate()
                    self.startGame()
                }
            }
        }
    // MARK: - 启动游戏
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
            
            // 对帧进行预处理
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
        // 只允许 "fear", "happy", "surprise" 这三个表情
        let validEmotions = ["fear", "happy", "surprise"]

        // 检查检测到的表情是否在允许范围内
        let normalizedEmotion = detectedEmotion.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard validEmotions.contains(normalizedEmotion) else {
            print("Ignored Emotion: \(detectedEmotion)") // 忽略无效表情
            return
        }

        // 确保当前木板存在且尚未进行判定
        guard let currentPlankEmoji = GameModel.shared.currentPlankEmoji,
              !GameModel.shared.hasScoredOnCurrentPlank else {
            print("No plank to score or already scored.")
            return
        }

        print("Detected Emotion: \(normalizedEmotion)")
        print("Current Plank Emoji: \(currentPlankEmoji)")

        // 判定是否匹配
        let isCorrect = GameModel.shared.checkEmotionMatch(detectedEmotion: normalizedEmotion)

        // 更新 UI，显示匹配结果
        gameView.updateDetectedEmotionLabel(with: normalizedEmotion, isCorrect: isCorrect)

        // 输出结果
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
        if let detectedEmotion = GameModel.shared.detectedEmotion {
            // 如果木板在屏幕上且尚未判定分数
            if floorAndPlankView.isPlankOnScreen, !GameModel.shared.hasScoredOnCurrentPlank {
                _ = GameModel.shared.checkEmotionMatch(detectedEmotion: detectedEmotion)
            }
        }
        floorAndPlankView.slideFloorsAndPlanks()
    }


}


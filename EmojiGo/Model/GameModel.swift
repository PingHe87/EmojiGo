//
//  GameModel.swift
//  EmojiGo
//
//  Created by Tong Li on 12/13/24.
//

import Foundation

class GameModel {
    // 单例共享实例
    static let shared = GameModel()
    
    private init() {} // 防止外部初始化

    var isPlankOnScreen = false
    var countdownValue = 20
    var score = 0 // 游戏分数

    var matchingTime: TimeInterval = 0 // 匹配时间累计
    var currentPlankEmoji: String? // 当前木板上的表情
    var hasScoredOnCurrentPlank = false // 是否已经为当前木板计分

    // 重置游戏状态
    func reset() {
        isPlankOnScreen = false
        countdownValue = 20
        score = 0
        matchingTime = 0
        currentPlankEmoji = nil
        hasScoredOnCurrentPlank = false
    }

    // 更新倒计时
    func updateCountdown() -> Bool {
        countdownValue -= 1
        return countdownValue <= 0 // 返回是否倒计时结束
    }

    // 检查表情匹配
    func checkEmotionMatch(detectedEmotion: String) -> Bool {
        guard let currentPlankEmoji = currentPlankEmoji else { return false }
        
        let normalizedDetected = detectedEmotion.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedPlankEmoji = currentPlankEmoji.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if normalizedDetected == normalizedPlankEmoji, !hasScoredOnCurrentPlank {
            matchingTime += 0.5 // 累加匹配时间
            if matchingTime >= 1.0 { // 累计超过1秒，加分
                score += 100
                hasScoredOnCurrentPlank = true
                matchingTime = 0 // 重置匹配时间
                print("Score added! New Score: \(score)")
                return true
            }
        } else {
            matchingTime = 0 // 如果不匹配，重置匹配时间
        }
        return false
    }
}


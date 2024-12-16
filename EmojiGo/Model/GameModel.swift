//
//  GameModel.swift
//  EmojiGo
//
//  Created by Tong Li on 12/13/24.
//

import Foundation
import AVFoundation

class GameModel {
    // 单例共享实例
    static let shared = GameModel()
    var audioPlayer: AVAudioPlayer?
    
    var detectedEmotion: String? = nil // 当前检测到的表情
    
    private init() {} // 防止外部初始化

    // 游戏状态变量
    var isPlankOnScreen = false
    var countdownValue = 60
    var score = 0 // 游戏分数

    // 当前木板状态
    var matchingTime: TimeInterval = 0 // 匹配时间累计
    var currentPlankEmoji: String? // 当前木板上的表情
    var hasScoredOnCurrentPlank = false // 是否已经为当前木板计分
    var hasFailedOnCurrentPlank = false // 是否已经播放过失败音效

    // 重置游戏状态
    func reset() {
        isPlankOnScreen = false
        countdownValue = 60
        score = 0
        resetCurrentPlankState() // 重置当前木板状态
    }

    // 重置当前木板状态
    func resetCurrentPlankState() {
        currentPlankEmoji = nil
        hasScoredOnCurrentPlank = false
        hasFailedOnCurrentPlank = false
        detectedEmotion = nil // 清空检测到的表情，确保下一块木板可以正常匹配
    }

    // 更新倒计时
    func updateCountdown() -> Bool {
        countdownValue -= 1
        return countdownValue <= 0 // 返回是否倒计时结束
    }

    
    // 检查表情匹配
    func checkEmotionMatch(detectedEmotion: String) -> Bool {
        // 确保当前有木板表情并且尚未判定得分
        guard let currentPlankEmoji = currentPlankEmoji, !hasScoredOnCurrentPlank else {
            return false
        }

        // 标准化表情和木板表情，去除空格并转为小写
        let normalizedDetected = detectedEmotion.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedPlankEmoji = currentPlankEmoji.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // 判断匹配情况
        if normalizedDetected == normalizedPlankEmoji {
            hasScoredOnCurrentPlank = true
            score += 100 // 增加分数
            print("Matched! Score added: \(score)")
            playSuccessSound() // 播放成功音效
            return true
        } else {
            if !hasScoredOnCurrentPlank { // 确保只在未得分时播放失败音效
                print("No Match! Current Score: \(score)")
                playFailureSound()
            }
            return false
        }
    }

    // 播放成功音效
    func playSuccessSound() {
        playSound(resourceName: "success")
    }

    // 播放失败音效
    func playFailureSound() {
        playSound(resourceName: "failure")
    }

    // 通用音效播放方法
    private func playSound(resourceName: String) {
        guard let soundURL = Bundle.main.url(forResource: resourceName, withExtension: "wav") else {
            print("Sound file \(resourceName) not found.")
            return
        }
        
        // 设置 AudioSession
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error.localizedDescription)")
        }
        
        // 播放音效
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}


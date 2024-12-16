//
//  GameModel.swift
//  EmojiGo
//
//  Created by Tong Li on 12/13/24.
//

import Foundation
import AVFoundation

class GameModel {
    // Singleton shared instance
    static let shared = GameModel()
    var audioPlayer: AVAudioPlayer?
    
    var detectedEmotion: String? = nil // Currently detected emotion
    
    private init() {} // Prevent external initialization

    // Game state variables
    var isPlankOnScreen = false
    var countdownValue = 60
    var score = 0 // Game score

    // Current plank state
    var matchingTime: TimeInterval = 0 // Accumulated matching time
    var currentPlankEmoji: String? // Emoji on the current plank
    var hasScoredOnCurrentPlank = false // Whether the current plank has been scored
    var hasFailedOnCurrentPlank = false // Whether the failure sound has already been played for the current plank

    // Reset game state
    func reset() {
        isPlankOnScreen = false
        countdownValue = 60
        score = 0
        resetCurrentPlankState() // Reset the state of the current plank
    }

    // Reset the state of the current plank
    func resetCurrentPlankState() {
        currentPlankEmoji = nil
        hasScoredOnCurrentPlank = false
        hasFailedOnCurrentPlank = false
        detectedEmotion = nil // Clear the detected emotion to ensure the next plank can match correctly
    }

    // Update countdown
    func updateCountdown() -> Bool {
        countdownValue -= 1
        return countdownValue <= 0 // Return whether the countdown has ended
    }

    
    // Check emotion match
    func checkEmotionMatch(detectedEmotion: String) -> Bool {
        // Ensure there is a current plank emoji and it has not been scored
        guard let currentPlankEmoji = currentPlankEmoji, !hasScoredOnCurrentPlank else {
            return false
        }

        // Normalize the detected emotion and plank emoji by trimming whitespace and converting to lowercase
        let normalizedDetected = detectedEmotion.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let normalizedPlankEmoji = currentPlankEmoji.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // Determine matching status
        if normalizedDetected == normalizedPlankEmoji {
            hasScoredOnCurrentPlank = true
            score += 100 // Increase score
            print("Matched! Score added: \(score)")
            playSuccessSound() // Play success sound
            return true
        } else {
            if !hasScoredOnCurrentPlank { // Ensure failure sound is played only when not scored
                print("No Match! Current Score: \(score)")
                playFailureSound()
            }
            return false
        }
    }

    func playSuccessSound() {
        playSound(resourceName: "success")
    }

    func playFailureSound() {
        playSound(resourceName: "failure")
    }

    // General method for playing sound effects
    private func playSound(resourceName: String) {
        guard let soundURL = Bundle.main.url(forResource: resourceName, withExtension: "wav") else {
            print("Sound file \(resourceName) not found.")
            return
        }
        
        // Configure AudioSession
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error.localizedDescription)")
        }
        
        // Play sound effect
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}


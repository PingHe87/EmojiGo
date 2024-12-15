//
//  Untitled.swift
//  EmojiGo
//
//  Created by p h on 12/15/24.
//

import Foundation
import Vision

class EmotionAnalyzer {
    private var emotionModel: VNCoreMLModel!
    private var emotionRequest: VNCoreMLRequest!

    init() {
        setupEmotionModel()
    }

    private func setupEmotionModel() {
        do {
            // 加载 CoreML 模型
            emotionModel = try VNCoreMLModel(for: EmojiChallengeClassfier().model)
            emotionRequest = VNCoreMLRequest(model: emotionModel, completionHandler: nil)
        } catch {
            fatalError("Failed to load CoreML model: \(error)")
        }
    }

    func analyze(pixelBuffer: CVPixelBuffer, completion: @escaping (String?) -> Void) {
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        
        // 初始化时设置 completionHandler
        let emotionRequest = VNCoreMLRequest(model: emotionModel) { request, error in
            if let error = error {
                print("Emotion detection error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let results = request.results as? [VNClassificationObservation],
                  let topResult = results.first else {
                completion(nil)
                return
            }
            completion(topResult.identifier) // 返回识别的表情结果
        }

        do {
            try handler.perform([emotionRequest])
        } catch {
            print("Failed to perform Vision request: \(error)")
            completion(nil)
        }
    }

}

//
//  ImagePreprocessor.swift
//  EmojiGo
//
//  Created by p h on 12/15/24.
//

import CoreImage
import CoreVideo

class ImagePreprocessor {
    private let ciContext = CIContext()
    
    /// 对输入的 PixelBuffer 进行亮度和对比度的处理
    func process(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // 创建亮度和对比度调整滤镜
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(0.3, forKey: "inputBrightness") // 提高亮度 (默认值为0.0)
        filter?.setValue(1.2, forKey: "inputContrast")   // 增强对比度 (默认值为1.0)
        
        guard let outputImage = filter?.outputImage else {
            print("Failed to process image with CIColorControls.")
            return nil
        }
        
        // 渲染输出为新的 PixelBuffer
        var newPixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         CVPixelBufferGetWidth(pixelBuffer),
                                         CVPixelBufferGetHeight(pixelBuffer),
                                         kCVPixelFormatType_32BGRA,
                                         nil,
                                         &newPixelBuffer)
        guard status == kCVReturnSuccess, let outputBuffer = newPixelBuffer else {
            print("Failed to create output PixelBuffer.")
            return nil
        }
        
        ciContext.render(outputImage, to: outputBuffer)
        return outputBuffer
    }
}

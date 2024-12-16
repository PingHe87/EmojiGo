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
    
    // Adjust the brightness and contrast of the input PixelBuffer
    func process(pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // Create a filter for brightness and contrast adjustment
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(0.3, forKey: "inputBrightness") // Increase brightness (default value is 0.0)
        filter?.setValue(1.2, forKey: "inputContrast")   // Enhance contrast (default value is 1.0)
        
        guard let outputImage = filter?.outputImage else {
            print("Failed to process image with CIColorControls.")
            return nil
        }
        
        // Render the output as a new PixelBuffer
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

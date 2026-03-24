//
//  EnhancedImageDecoder.swift
//  ImageConcurrencyLab
//
//  Created by Codex on 24.03.2026.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

enum EnhancedImageDecoderError: Error {
    case invalidImageData
    case failedToCreatePixelBuffer
    case failedToCreateContext
    case failedToCropImage
    case failedToRenderImage
}

struct EnhancedImageDecoder: Sendable {

    private let brightness: Float
    private let contrast: Float
    private let sharpness: Float
    private let borderThreshold: UInt8

    nonisolated init(
        brightness: Float = 0.08,
        contrast: Float = 1.12,
        sharpness: Float = 0.5,
        borderThreshold: UInt8 = 20
    ) {
        self.brightness = brightness
        self.contrast = contrast
        self.sharpness = sharpness
        self.borderThreshold = borderThreshold
    }

    nonisolated func decode(_ data: Data) throws -> UIImage {
        guard let image = UIImage(data: data), let cgImage = image.cgImage else {
            throw EnhancedImageDecoderError.invalidImageData
        }

        let cropped = try cropDarkBorders(from: cgImage)
        let enhanced = try enhance(cropped)

        return UIImage(cgImage: enhanced, scale: image.scale, orientation: image.imageOrientation)
    }

    private nonisolated func cropDarkBorders(from cgImage: CGImage) throws -> CGImage {
        let width = cgImage.width
        let height = cgImage.height

        guard width > 2, height > 2 else {
            return cgImage
        }

        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw EnhancedImageDecoderError.failedToCreateContext
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let buffer = context.data else {
            throw EnhancedImageDecoderError.failedToCreatePixelBuffer
        }

        let pixels = buffer.bindMemory(to: UInt8.self, capacity: height * bytesPerRow)

        func rowIsBorder(_ y: Int) -> Bool {
            for x in 0..<width where !isDarkPixel(pixels, x: x, y: y, bytesPerRow: bytesPerRow) {
                return false
            }
            return true
        }

        func columnIsBorder(_ x: Int) -> Bool {
            for y in 0..<height where !isDarkPixel(pixels, x: x, y: y, bytesPerRow: bytesPerRow) {
                return false
            }
            return true
        }

        var top = 0
        while top < height - 1 && rowIsBorder(top) {
            top += 1
        }

        var bottom = height - 1
        while bottom > top && rowIsBorder(bottom) {
            bottom -= 1
        }

        var left = 0
        while left < width - 1 && columnIsBorder(left) {
            left += 1
        }

        var right = width - 1
        while right > left && columnIsBorder(right) {
            right -= 1
        }

        let cropWidth = right - left + 1
        let cropHeight = bottom - top + 1

        guard cropWidth > 0, cropHeight > 0 else {
            return cgImage
        }

        let cropRect = CGRect(x: left, y: top, width: cropWidth, height: cropHeight)
        return cgImage.cropping(to: cropRect) ?? cgImage
    }

    private nonisolated func enhance(_ cgImage: CGImage) throws -> CGImage {
        let ciContext = CIContext(options: nil)
        let source = CIImage(cgImage: cgImage)

        let colorControls = CIFilter.colorControls()
        colorControls.inputImage = source
        colorControls.brightness = brightness
        colorControls.contrast = contrast
        colorControls.saturation = 1.02

        let sharpen = CIFilter.sharpenLuminance()
        sharpen.inputImage = colorControls.outputImage
        sharpen.sharpness = sharpness

        guard
            let output = sharpen.outputImage,
            let rendered = ciContext.createCGImage(output, from: output.extent.integral)
        else {
            throw EnhancedImageDecoderError.failedToRenderImage
        }

        return rendered
    }

    private nonisolated func isDarkPixel(
        _ pixels: UnsafePointer<UInt8>,
        x: Int,
        y: Int,
        bytesPerRow: Int
    ) -> Bool {
        let offset = (y * bytesPerRow) + (x * 4)
        let red = pixels[offset]
        let green = pixels[offset + 1]
        let blue = pixels[offset + 2]
        let alpha = pixels[offset + 3]

        return alpha > 0 &&
        red <= borderThreshold &&
        green <= borderThreshold &&
        blue <= borderThreshold
    }
}

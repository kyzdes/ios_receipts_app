import UIKit
import Vision

class ImageProcessor {
    static let shared = ImageProcessor()

    private init() {}

    /// Extract text from an image using Vision framework
    func extractText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw ImageProcessingError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: ImageProcessingError.noTextFound)
                    return
                }

                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")

                continuation.resume(returning: recognizedText)
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Compress image for upload
    func compressImage(_ image: UIImage, targetSizeInMB: Double = 1.0) -> Data? {
        let targetSizeInBytes = targetSizeInMB * 1024 * 1024
        var compression: CGFloat = 1.0
        guard var imageData = image.jpegData(compressionQuality: compression) else { return nil }

        // Reduce compression quality until target size is reached
        while Double(imageData.count) > targetSizeInBytes && compression > 0.1 {
            compression -= 0.1
            if let data = image.jpegData(compressionQuality: compression) {
                imageData = data
            }
        }

        return imageData
    }

    /// Resize image to maximum dimensions
    func resizeImage(_ image: UIImage, maxWidth: CGFloat = 1200, maxHeight: CGFloat = 1200) -> UIImage {
        let size = image.size
        let widthRatio = maxWidth / size.width
        let heightRatio = maxHeight / size.height
        let ratio = min(widthRatio, heightRatio, 1.0)

        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage ?? image
    }
}

enum ImageProcessingError: Error, LocalizedError {
    case invalidImage
    case noTextFound
    case processingFailed

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Invalid image format"
        case .noTextFound:
            return "No text found in image"
        case .processingFailed:
            return "Image processing failed"
        }
    }
}

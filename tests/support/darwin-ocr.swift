import Foundation
import ImageIO
import Vision

func errorLine(_ message: String) {
    FileHandle.standardError.write(Data((message + "\n").utf8))
}

func normalized(_ text: String) -> String {
    text.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
}

let arguments = Array(CommandLine.arguments.dropFirst())
guard arguments.count >= 2, arguments.dropFirst().allSatisfy({ !normalized($0).isEmpty }) else {
    errorLine("usage: smoke-ocr <image.png> <expected> [more expected strings...]")
    exit(2)
}

let imageURL = URL(fileURLWithPath: arguments[0])
let expected = Array(arguments.dropFirst())
guard
    let source = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
    let image = CGImageSourceCreateImageAtIndex(source, 0, nil)
else {
    errorLine("cannot decode screenshot: \(imageURL.path)")
    exit(2)
}

let request = VNRecognizeTextRequest()
request.recognitionLevel = .accurate

do {
    try VNImageRequestHandler(cgImage: image, options: [:]).perform([request])
} catch {
    errorLine("Vision OCR failed: \(error)")
    exit(2)
}

let lines = (request.results ?? []).compactMap { $0.topCandidates(1).first?.string }
let observed = normalized(lines.joined(separator: " "))
let missing = expected.filter { !observed.localizedCaseInsensitiveContains(normalized($0)) }

if ProcessInfo.processInfo.environment["SMOKE_OCR_DUMP"] == "1" {
    errorLine("OCR expected markers: \(expected)")
    errorLine("OCR observed: \(observed)")
    errorLine("OCR missing markers: \(missing)")
}

// 1 is a normal polling mismatch; 2 denotes an infrastructure error.
exit(missing.isEmpty ? 0 : 1)

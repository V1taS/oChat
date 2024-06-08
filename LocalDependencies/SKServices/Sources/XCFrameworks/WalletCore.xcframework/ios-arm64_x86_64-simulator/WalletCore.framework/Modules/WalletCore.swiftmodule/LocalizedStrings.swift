import Foundation

let fileManager = FileManager.default

func scanFolder(atPath path: String) -> ([String: [String]], [String]) {
    var localizationFiles: [String: [String]] = [:]
    var imageAssets: [String] = []

    if let enumerator = fileManager.enumerator(atPath: path) {
        for case let filePath as String in enumerator {
            if filePath.hasSuffix(".strings") {
                let key = (filePath as NSString).deletingLastPathComponent
                localizationFiles[key, default: []].append(filePath)
            } else if filePath.hasSuffix(".png") || filePath.hasSuffix(".jpg") {
                imageAssets.append(filePath)
            }
        }
    }
    return (localizationFiles, imageAssets)
}

func generateLocalizationFile(from localizationFiles: [String: [String]], at outputPath: String) {
    var content = "// Generated Localization File\n\n"
    content += "public enum LocalizedStrings {\n"

    for (key, files) in localizationFiles {
        content += "  public enum \(key) {\n"
        for file in files {
            if let data = try? String(contentsOfFile: file, encoding: .utf8) {
                let lines = data.split(separator: "\n")
                for line in lines {
                    let components = line.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: true)
                    if components.count == 2 {
                        let localizationKey = components[0].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
                        content += "    public static let \(localizationKey) = NSLocalizedString(\"\(localizationKey)\", comment: \"\")\n"
                    }
                }
            }
        }
        content += "  }\n"
    }
    content += "}\n"

    try? content.write(toFile: outputPath, atomically: true, encoding: .utf8)
}

func generateImageAssetsFile(from imageAssets: [String], at outputPath: String) {
    var content = "// Generated Image Assets File\n\n"
    content += "import UIKit\n\n"
    content += "public enum ImageAssets {\n"

    for asset in imageAssets {
        let assetName = (asset as NSString).deletingPathExtension
        content += "  public static let \(assetName) = UIImage(named: \"\(assetName)\")\n"
    }

    content += "}\n"

    try? content.write(toFile: outputPath, atomically: true, encoding: .utf8)
}

let arguments = CommandLine.arguments
guard arguments.count == 3 else {
    print("Usage: swift GenerateLocalizationAndAssets.swift <path_to_scan> <output_path>")
    exit(1)
}

let pathToScan = arguments[1]
let outputPath = arguments[2]

let (localizationFiles, imageAssets) = scanFolder(atPath: pathToScan)

let localizationOutputPath = (outputPath as NSString).appendingPathComponent("LocalizedStrings.swift")
let imageAssetsOutputPath = (outputPath as NSString).appendingPathComponent("ImageAssets.swift")

generateLocalizationFile(from: localizationFiles, at: localizationOutputPath)
generateImageAssetsFile(from: imageAssets, at: imageAssetsOutputPath)

print("Файлы локализации и изображения успешно созданы.")

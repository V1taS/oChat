import Foundation

let fileManager = FileManager.default

let enumName = "AbstractionsStrings" // Переменная для имени enum
let bundleName = "Abstractions" // Имя вашего бандла

func sanitizeEnumName(_ name: String) -> String {
  var sanitized = name.replacingOccurrences(of: "/", with: "_")
  sanitized = sanitized.replacingOccurrences(of: ".", with: "_")
  sanitized = sanitized.replacingOccurrences(of: "-", with: "_")
  sanitized = sanitized.replacingOccurrences(of: " ", with: "_")
  return sanitized
}

func extractEnumName(from path: String) -> String {
  let components = path.split(separator: "/")
  guard let lastComponent = components.last else {
    return sanitizeEnumName(path)
  }
  let enumName = (lastComponent as NSString).deletingPathExtension
  return sanitizeEnumName(enumName)
}

func processLocalizationKey(_ key: String) -> String {
  let components = key.split(separator: ".")
  guard var firstComponent = components.first else {
    return key
  }
  
  let firstComponentString = String(firstComponent)
  
  if firstComponentString.uppercased() == firstComponentString {
    firstComponent = Substring(firstComponentString.lowercased())
  } else {
    firstComponent = Substring(firstComponentString.prefix(1).lowercased() + firstComponentString.dropFirst())
  }
  
  let camelCasedComponents = ([firstComponent] + components.dropFirst()).map { component -> String in
    let componentString = String(component)
    return componentString.prefix(1).uppercased() + componentString.dropFirst()
  }
  
  let result = camelCasedComponents.joined()
  return result.prefix(1).lowercased() + result.dropFirst()
}

func scanFolder(atPath path: String) -> ([String: [String]], [String]) {
  var localizationFiles: [String: [String]] = [:]
  var imageAssets: [String] = []
  
  if let enumerator = fileManager.enumerator(atPath: path) {
    for case let filePath as String in enumerator {
      let fullPath = (path as NSString).appendingPathComponent(filePath)
      if filePath.hasSuffix(".strings") {
        let key = extractEnumName(from: filePath)
        localizationFiles[key, default: []].append(fullPath)
      } else if filePath.hasSuffix(".png") || filePath.hasSuffix(".jpg") {
        imageAssets.append(fullPath)
      }
    }
  }
  return (localizationFiles, imageAssets)
}

func generateLocalizationFile(from localizationFiles: [String: [String]], at outputPath: String) {
  var content = "// Generated Localization File\n\n"
  content += "import Foundation\n\n"
  content += "public enum \(enumName) {\n"
  
  for (key, files) in localizationFiles {
    var uniqueKeys = Set<String>()
    content += "  public enum \(key) {\n"
    for file in files {
      if let data = try? String(contentsOfFile: file, encoding: .utf8) {
        let lines = data.split(separator: "\n")
        for line in lines {
          let components = line.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: true)
          if components.count == 2 {
            let localizationKey = components[0].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\"", with: "")
            if uniqueKeys.contains(localizationKey) {
              continue // Skip duplicate keys
            }
            uniqueKeys.insert(localizationKey)
            let processedKey = processLocalizationKey(localizationKey)
            content += "    public static let \(processedKey) = NSLocalizedString(\"\(localizationKey)\", bundle: .module, comment: \"\")\n"
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
    content += "  public static let \(assetName) = UIImage(named: \"\(assetName)\", in: .module, compatibleWith: nil)\n"
  }
  
  content += "}\n"
  
  try? content.write(toFile: outputPath, atomically: true, encoding: .utf8)
}

func generateBundleAccessorFile(at outputPath: String) {
  let content = """
    // swiftlint:disable all
    // swift-format-ignore-file
    // swiftformat:disable all
    import Foundation
    
    // MARK: - Swift Bundle Accessor
    
    private class BundleFinder {}
    
    extension Foundation.Bundle {
        /// Since \(bundleName) is a application, the bundle for classes within this module can be used directly.
        static let module = Bundle(for: BundleFinder.self)
    }
    
    // MARK: - Objective-C Bundle Accessor
    
    @objc
    public class \(bundleName)Resources: NSObject {
        @objc public class var bundle: Bundle {
            return .module
        }
    }
    // swiftlint:enable all
    // swiftformat:enable all
    """
  
  try? content.write(toFile: outputPath, atomically: true, encoding: .utf8)
}

let currentDirectory = fileManager.currentDirectoryPath

let (localizationFiles, imageAssets) = scanFolder(atPath: currentDirectory)

let localizationOutputPath = (currentDirectory as NSString).appendingPathComponent("GeneratedLocalizedStrings.swift")
let imageAssetsOutputPath = (currentDirectory as NSString).appendingPathComponent("GeneratedImageAssets.swift")
let bundleAccessorOutputPath = (currentDirectory as NSString).appendingPathComponent("GeneratedBundleAccessor.swift")

generateLocalizationFile(from: localizationFiles, at: localizationOutputPath)
generateImageAssetsFile(from: imageAssets, at: imageAssetsOutputPath)
generateBundleAccessorFile(at: bundleAccessorOutputPath)

print("✅ Файлы локализации, изображения и доступа к бандлу успешно созданы в текущей директории.")

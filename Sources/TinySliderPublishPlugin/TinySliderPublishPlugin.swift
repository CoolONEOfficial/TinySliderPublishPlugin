/**
*  TinySlider plugin for Publish
*/

import Publish
import Ink
import Foundation

public struct MinimizedImagesConfig {
    public init(suffix: String, imageSize: String) {
        self.suffix = suffix
        self.imageSize = imageSize
    }

    let suffix: String
    let imageSize: String
}

public extension Plugin {
    static func tinySlider(jsPath: String, minimizedImagesConfig: [MinimizedImagesConfig] = [], defaultConfig: Dictionary<String, Any> = [String: Any]()) -> Self {
        Plugin(name: "TinySlider") { context in
            context.markdownParser.addModifier(
                .tinySlider(jsPath, minimizedImagesConfig, defaultConfig)
            )
        }
    }
}

public extension Modifier {
    static func tinySlider(_ jsPath: String, _ minimizedImagesConfig: [MinimizedImagesConfig],  _ defaultConfig: Dictionary<String, Any>) -> Self {
        return Modifier(target: .lists) { html, markdown in
            let regex = try! NSRegularExpression(pattern: "(\\d+).", options: .caseInsensitive)
            let lines = markdown.components(separatedBy: "\n").filter {
                regex.firstMatch(in: $0, options: [], range: .init(location: 0, length: $0.count)) != nil
            }
            guard !lines.isEmpty else { return html }

            let images = lines[1..<lines.count]
                .compactMap { $0.firstSubstring(between: "!", and: ")") }
                .map { String($0) }
            let parsedImages = images.compactMap { image -> (path: Substring, alt: Substring?)? in
                guard let startAlt = image.firstIndex(of: "(") else { return nil }
                return (
                    path: image[image.index(startAlt, offsetBy: 1)..<image.endIndex],
                    alt: image.firstSubstring(between: "[", and: "]")
                )
            }
            
            if lines.count > 1,
               parsedImages.count == lines.count - 1,
               let configContent = lines.first?.firstSubstring(between: "{", and: "}"),
               let configData = "{\(configContent)}".data(using: .utf8),
               let configObj = try? JSONSerialization.jsonObject(with: configData, options: []) as? Dictionary<String, Any> {

                let config = configObj.merging(defaultConfig) { (current, _) in current }
                
                let classId = "slider-" + String(markdown.hash)
                let imagesHtml = parsedImages.compactMap { image -> String? in
                    guard let beforeDotPath = image.path.lastIndex(of: ".") else { return nil }
                    let srcSetInfo = minimizedImagesConfig.map { info in
                        var path = image.path
                        path.insert(contentsOf: info.suffix, at: beforeDotPath)
                        return (path: path, size: info.imageSize)
                    }
                    let srcSetStrings = srcSetInfo.map { "\($0.path) \($0.size)" }.joined(separator: ", ")
                    let srcSetHtml = srcSetStrings.isEmpty ? "" : " srcset=\"\(srcSetStrings)\""
                    let imageUrl = srcSetInfo.first?.path ?? image.path
                    return """
                        <a href="\(image.path)"><img src="\(imageUrl)" \(srcSetHtml) \(image.alt != nil ? " alt=\"" + image.alt! + "\"" : "")/></a>
                    """
                }
                
                
                return """
                <script type="module">
                  import {tns} from '\(jsPath)';

                  var slider = tns({
                    container: '.\(classId)',
                    \(String(
                        data: try! JSONSerialization.data(withJSONObject: config),
                        encoding: .utf8
                    )!.dropFirst().dropLast())
                  });
                </script>
                <br />
                <div class="\(classId)" style="margin-bottom: 10px;">
                    \(imagesHtml.joined(separator: "\n"))
                </div>
                <br />
                """
            } else {
                return html
            }
        }
    }
}

/**
*  Twitter plugin for Publish
*  © 2020 Guilherme Rambo
*  BSD-2 license, see LICENSE file for details
*/

import Publish
import Ink
import Foundation

public extension Plugin {
    static func tinySlider(jsPath: String, defaultConfig: Dictionary<String, Any> = [String: Any]()) -> Self {
        Plugin(name: "TinySlider") { context in
            context.markdownParser.addModifier(
                .tinySlider(jsPath, defaultConfig)
            )
        }
    }
}

public extension Modifier {
    static func tinySlider(_ jsPath: String, _ defaultConfig: Dictionary<String, Any>) -> Self {
        return Modifier(target: .lists) { html, markdown in
            let regex = try! NSRegularExpression(pattern: "(\\d+).", options: .caseInsensitive)
            let lines = markdown.components(separatedBy: "\n").filter {
                regex.firstMatch(in: $0, options: [], range: .init(location: 0, length: $0.count)) != nil
            }

            let images = lines[1..<lines.count]
                .compactMap { $0.firstSubstring(between: "!", and: ")") }
                .map { String($0) }
            let parsedImages = images.map { image -> (path: Substring?, alt: Substring?) in
                let startAlt = image.firstIndex(of: "(")
                return (
                    path: startAlt != nil ? image[image.index(startAlt!, offsetBy: 1)..<image.endIndex] : nil,
                    alt: image.firstSubstring(between: "[", and: "]")
                )
            }.filter { $0.alt != nil && $0.path != nil }
            
            if lines.count > 1,
               parsedImages.count == lines.count - 1,
               let configContent = lines.first?.firstSubstring(between: "{", and: "}"),
               let configData = "{\(configContent)}".data(using: .utf8),
               let configObj = try? JSONSerialization.jsonObject(with: configData, options: []) as? Dictionary<String, Any> {
                
                let config = configObj.merging(defaultConfig) { (current, _) in current }
                
                let classId = "slider-" + String(markdown.hash)
                let imagesHtml = parsedImages.map { """
                    <img src="\($0.path!)"\($0.alt != nil ? " alt=\"" + $0.alt! + "\"" : "")/>
                """ }
                
                
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
                <div class="\(classId)" style="margin-bottom: 10px;">
                    \(imagesHtml.joined(separator: "\n"))
                </div>
                """
            } else {
                return html
            }
        }
    }
}

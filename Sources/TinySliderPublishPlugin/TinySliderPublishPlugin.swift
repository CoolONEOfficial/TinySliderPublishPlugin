/**
*  Twitter plugin for Publish
*  © 2020 Guilherme Rambo
*  BSD-2 license, see LICENSE file for details
*/

import Publish
import Ink
import Foundation
import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

func md5(_ string: Substring) -> String {
    let length = Int(CC_MD5_DIGEST_LENGTH)
    let messageData = string.data(using:.utf8)!
    var digestData = Data(count: length)

    _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
        messageData.withUnsafeBytes { messageBytes -> UInt8 in
            if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                let messageLength = CC_LONG(messageData.count)
                CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
            }
            return 0
        }
    }
    return digestData.map { String(format: "%02hhx", $0) }.joined()
}

public extension Plugin {
    static func tinySlider(jsPath: String) -> Self {
        Plugin(name: "TinySlider") { context in
            context.markdownParser.addModifier(
                .tinySlider(jsPath)
            )
        }
    }
}

public extension Modifier {
    static func tinySlider(_ jsPath: String, items: Int? = nil) -> Self {
        return Modifier(target: .lists) { html, markdown in
            let lines = markdown.components(separatedBy: "\n")

            let images = lines[1..<lines.count]
                .compactMap { String($0.firstSubstring(between: "!", and: ")")!) }
            let parsedImages = images.map { image -> (path: Substring?, alt: Substring?) in
                let startAlt = image.firstIndex(of: "(")
                return (
                    path: startAlt != nil ? image[image.index(startAlt!, offsetBy: 1)..<image.endIndex] : nil,
                    alt: image.firstSubstring(between: "[", and: "]")
                )
            }.filter { $0.alt != nil && $0.path != nil }
            
            if lines.count > 1,
               parsedImages.count == lines.count - 1,
               let configContent = lines.first?.firstSubstring(between: "{", and: "}") {
                let classId = "slider-" + md5(markdown)
                let imagesHtml = parsedImages.map { """
                    <img src="\($0.path!)"\($0.alt != nil ? " alt=\"" + $0.alt! + "\"" : "")/>
                """ }

                return """
                <script type="module">
                  import {tns} from '\(jsPath)';

                  var slider = tns({
                    container: '.\(classId)',
                    \(configContent)
                  });
                </script>
                <div class="\(classId)">
                    \(imagesHtml.joined(separator: "\n"))
                </div>
                """
            } else {
                return html
            }
        }
    }
}

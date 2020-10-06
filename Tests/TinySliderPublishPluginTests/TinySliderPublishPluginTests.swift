import XCTest
@testable import TinySliderPublishPlugin
import Ink

final class TinySliderPublishPluginTests: XCTestCase {
    func testHighlightingMarkdown() {
        let parser = MarkdownParser(modifiers: [.tinySlider("/module/test.js")])
        let html = parser.html(from: """
        1. { "items": 3, "slideBy": "page", "mouseDrag": true, "swipeAngle": false, "speed": 400 }
        2. ![one](/img/one.jpg)
        3. ![two](/img/two.jpg)
        """)
        
        XCTAssertEqual(html, "<script type=\"module\">\n  import {tns} from \'/module/test.js\';\n\n  var slider = tns({\n    container: \'.slider-c0935b5d2f8d6624d37acf6e209a6680\',\n     \"items\": 3, \"slideBy\": \"page\", \"mouseDrag\": true, \"swipeAngle\": false, \"speed\": 400 \n  });\n</script>\n<div class=\"slider-c0935b5d2f8d6624d37acf6e209a6680\">\n        <img src=\"/img/one.jpg\" alt=\"one\"/>\n    <img src=\"/img/two.jpg\" alt=\"two\"/>\n</div>")
    }

    static var allTests = [
        ("testHighlightingMarkdown", testHighlightingMarkdown)
    ]
}

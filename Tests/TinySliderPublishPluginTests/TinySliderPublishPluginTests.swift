import XCTest
@testable import TinySliderPublishPlugin
import Ink

final class TinySliderPublishPluginTests: XCTestCase {
    func testHighlightingMarkdown() {
        let parser = MarkdownParser(modifiers: [.tinySlider("/module/test.js", ["defaultVal": 1])])
        let html = parser.html(from: """
        1. { "items": 3, "slideBy": "page", "mouseDrag": true, "swipeAngle": false }
        2. ![one](/img/one.jpg)
        3. ![two](/img/two.jpg)
        """)
        
        XCTAssertEqual(html.count, "<script type=\"module\">\n  import {tns} from \'/module/test.js\';\n\n  var slider = tns({\n    container: \'.slider-460812aa51b39bc6c1b030c71e283d47\',\n    \"items\":3,\"slideBy\":\"page\",\"defaultVal\":1,\"swipeAngle\":false,\"mouseDrag\":true\n  });\n</script>\n<div class=\"slider-460812aa51b39bc6c1b030c71e283d47\" style=\"margin-bottom: 10px;\">\n        <img src=\"/img/one.jpg\" alt=\"one\"/>\n    <img src=\"/img/two.jpg\" alt=\"two\"/>\n</div>".count)
    }

    static var allTests = [
        ("testHighlightingMarkdown", testHighlightingMarkdown)
    ]
}

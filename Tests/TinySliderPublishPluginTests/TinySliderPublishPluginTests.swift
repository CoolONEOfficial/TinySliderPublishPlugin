import XCTest
@testable import TinySliderPublishPlugin
import Ink

final class TinySliderPublishPluginTests: XCTestCase {
    func testHighlightingMarkdown() {
        let parser = MarkdownParser(modifiers: [.tinySlider("/module/test.js", [ .init(suffix: "_one", imageSize: "100px"), .init(suffix: "_two", imageSize: "200px") ], ["defaultVal": 1])])
        let html = parser.html(from: """
        1. { "items": 3, "slideBy": "page", "mouseDrag": true, "swipeAngle": false }
        2. ![one](/img/one.jpg)
        3. ![two](/img/two.jpg)
        """)
        
        XCTAssertEqual(html.count, """
<script type="module">
  import {tns} from '/module/test.js';

  var slider = tns({
    container: '.slider-3315049829847944959',
    "slideBy":"page","mouseDrag":true,"defaultVal":1,"swipeAngle":false,"items":3
  });
</script>
<br />
<div class="slider-3315049829847944959" style="margin-bottom: 10px;">
        <img src="/img/one.jpg"  srcset="/img/one_one.jpg 100px, /img/one_two.jpg 200px"  alt="one"/>
    <img src="/img/two.jpg"  srcset="/img/two_one.jpg 100px, /img/two_two.jpg 200px"  alt="two"/>
</div>
<br />
""".count)
    }

    static var allTests = [
        ("testHighlightingMarkdown", testHighlightingMarkdown)
    ]
}

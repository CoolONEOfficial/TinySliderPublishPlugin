# TinySliderPublishPlugin

A plugin for [Publish](https://github.com/JohnSundell/Publish) that let's you easily use [TinySlider](https://github.com/ganlanyuan/tiny-slider) in your posts.

To embed a slider in your post, use a list with images in markdown, but add the config at first list item, like so:

```
...

1. { "items": 3, "slideBy": "page", "mouseDrag": true, "swipeAngle": false, "speed": 400 }
2. ![one](/img/one.jpg)
3. ![two](/img/two.jpg)

...
```

To install the plugin, add it to your site's publishing steps:

```swift
try mysite().publish(using: [
    .installPlugin(.tinySlider()),
    // ...
])
```

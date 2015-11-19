 MobilePlayer [![CocoaPods](https://img.shields.io/cocoapods/p/MobilePlayer.svg?style=flat)](https://cocoapods.org/pods/MobilePlayer)
==================
[![CocoaPods](http://img.shields.io/cocoapods/v/MobilePlayer.svg?style=flat)](http://cocoapods.org/?q=MobilePlayer) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Number of Tests](https://img.shields.io/badge/Number%20of%20Tests-100+-brightgreen.svg)](https://github.com/mobileplayer/mobileplayer-ios)
[![Dependencies](https://img.shields.io/badge/dependencies-none-brightgreen.svg)](https://github.com/mobileplayer/mobileplayer-ios)

[![Ready](https://badge.waffle.io/mobileplayer/mobileplayer-ios.png?label=Ready&title=Ready)](https://waffle.io/mobileplayer/mobileplayer-ios)
[![In Progress](https://badge.waffle.io/mobileplayer/mobileplayer-ios.png?label=In%20Progress&title=In%20Progress)](https://waffle.io/mobileplayer/mobileplayer-ios)
[![Post an issue](https://img.shields.io/badge/Bug%3F-Post%20an%20issue!-blue.svg)](https://waffle.io/mobileplayer/mobileplayer-ios)

[![StackOverflow](https://img.shields.io/badge/StackOverflow-Ask%20a%20question!-blue.svg)](http://stackoverflow.com/questions/ask?tags=mobile player+ios+swift+video player) 
[![Join the chat at https://gitter.im/mobileplayer/mobileplayer-ios](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/mobileplayer/mobileplayer-ios?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A powerful and completely customizable media player for iOS.

![](https://raw.github.com/mobileplayer/mobileplayer-ios/chore/beautiful-readme/introduction.gif)

Features
==================
- Customizable UI. Add a watermark, add/remove/move/resize interface elements, change their appearances and much more.
- Manage multiple player skins and configurations easily. Player view controllers can load configuration data from a local JSON file or remote JSON data. You also have the option to initialize and pass configuration objects programmatically, which allows for greater flexibility.
- Powerful overlay system. Add any view controller as an overlay to your video, set them to appear in a certain playback time interval or just make them permanently visible.
- 100% documented.

### Future plans
- Well defined and extensive `NSNotification`s.
- Plugin support.
- Pre-bundled analytics plugins for various platforms.
- Monetization.

Usage
==================
```swift
import MobilePlayer
```

### Create a player view controller and present it
```swift
let playerVC = MobilePlayerViewController(contentURL: videoURL)
presentMoviePlayerViewControllerAnimated(playerVC)
```

### Create a customized player view controller
*Screenshot here*

**Initialize using local JSON file**
```swift
guard let configFileURL = NSBundle.mainBundle().URLForResource("PlayerConfig", withExtension: "json") else {
  fatalError("Unable to load player configuration file")
}
let playerVC = MobilePlayerViewController(contentURL: videoURL, config: MobilePlayerConfig(fileURL: configFileURL))
```

**Initialize using remote JSON data**
```swift
guard let configFileURL = NSURL(string: "https://api.mysite.com/configuration/player.json?app=myapp&theme=simple") else {
  fatalError("Invalid configuration file URL")
}
let playerVC = MobilePlayerViewController(contentURL: videoURL, config: MobilePlayerConfig(fileURL: configFileURL))
```

**JSON**
```json
{
  "watermark": {
    "image": "CompanyLogo"
  }
}
```

### Personalize
*Screenshot here*
```json
{
  "watermark": {
    "image": "CompanyLogo"
  }
}
```

### Personalize further
*Screenshot here*
```json
{
  "watermark": {
    "image": "CompanyLogo"
  }
}
```

###


### Programmatic Configuration
The watermark example done without using a JSON configuration file url looks like the following.
```swift
let playerVC = MobilePlayerViewController(
  contentURL: videoURL,
  config: MobilePlayerConfig(dictionary: [
    "watermark": WaterMarkConfig(dictionary: [
      "image": "CompanyLogo"
    ])
  ])
)
```

Installation
==================
There are various ways you can get started with using MobilePlayer in your projects.

### [Cocoapods](https://github.com/CocoaPods/CocoaPods)
Add the following line in your `Podfile`.
```
pod "MobilePlayer"
```

### [Carthage](https://github.com/Carthage/Carthage#installing-carthage)
Add the following line to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).
```
github "mobileplayer/mobileplayer-ios"
```

### Git Submodule
Open the Terminal app and `cd` to your project directory. Then run
```
git submodule add git@github.com:mobileplayer/mobileplayer-ios.git
```
This should create a folder named MobilePlayer inside your project directory. After that, drag and drop MobilePlayer/MobilePlayer.xcodeproj into your project in Xcode and add the MobilePlayer.framework in the Embedded Binaries section of your target settings under the General tab.

Documentation
==================
The entire documentation for the library can be found [here](https://htmlpreview.github.io/?https://github.com/movielala/mobileplayer-ios/blob/master/Documentation/index.html).

License
==================
The use of the MobilePlayer open source edition is governed by a [Creative Commons license](http://creativecommons.org/licenses/by-nc-sa/3.0/). You can use, modify, copy, and distribute this edition as long as it’s for non-commercial use, you provide attribution, and share under a similar license.
http://mobileplayer.io/license/

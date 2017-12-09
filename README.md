# XCTestWD

[![NPM version][npm-image]][npm-url]
[![build status][travis-image]][travis-url]
[![node version][node-image]][node-url]
[![npm download][download-image]][download-url]

[npm-image]: https://img.shields.io/npm/v/xctestwd.svg?style=flat-square
[npm-url]: https://npmjs.org/package/xctestwd
[travis-image]: https://img.shields.io/travis/macacajs/XCTestWD.svg?style=flat-square
[travis-url]: https://travis-ci.org/macacajs/XCTestWD
[node-image]: https://img.shields.io/badge/node.js-%3E=_6-green.svg?style=flat-square
[node-url]: http://nodejs.org/download/
[download-image]: https://img.shields.io/npm/dm/xctestwd.svg?style=flat-square
[download-url]: https://npmjs.org/package/xctestwd

> Swift implementation of WebDriver server for iOS that runs on Simulator/iOS devices.

## 1. Requirements

- XCode version 9.0 and above.
- iOS version 11.0 and above. （there is significant change on XCUITest interfaces and system private headers, hence we decide to support newest OS version only）

## 2. Starting XCTestWD

XCTestWD can be either started with XCode IDE or via simple xcodebuild command line. By default, the webdriver agent occupies port `8001`.  You can override the default port in XCode by searching `XCTESTWD_PORT` under project build settings. Alternatively, it can also be overrided when you execute command line method as specified in `2.2. Using Xcodebuild`

### 2.1. Using Xcode

Download the project and open the XCode project, checkout the scheme `XCTestWDUITests` and run the test case `XCTextWDRunner`

### 2.2. Using XcodeBuild

Open the terminal, go to the directory where contains `XCTestWD.xcodeproj` file and execute the following command:

```bash
#
#Change the port number to override the default port 
#
$ xcodebuild -project XCTestWD.xcodeproj \
           -scheme XCTestWDUITests \
           -destination 'platform=iOS Simulator,name=iPhone 6' \
           XCTESTWD_PORT=8001 \
           clean test
```

To execute for iOS device, run the following command:

```bash
#
#Change the port number to override the default port 
#Specify the device name
#
$ xcodebuild -project XCTestWD.xcodeproj \
           -scheme XCTestWDUITests \
           -destination 'platform=iOS,name=(your device name)' \
           XCTESTWD_PORT=8001 \
           clean test
```
**Note:** For versions above wxtestwd 2.0.0, please install ideviceinstaller for supporting real device testing


## 3. Element Types

In the current protocol, element strings for each `XCUIElementType` are generated based on the existing mapping in [reference/xctest/xcuielementtype](https://developer.apple.com/reference/xctest/xcuielementtype)


## 4. Common Issues

### 4.1 Socket hangup error

Socket Hangup Error happens in the following two scenarios: <br>
- **Case 1** <br>
Issue: <br>
When you have some existing XCTestWD instances running and creating new ones. <br>
Solution: <br>
verify whether ideviceinstaller and xcrun is properly working on your device and simulator. <br>
Hint: <br>
https://github.com/libimobiledevice/ideviceinstaller/issues/48

- **Case 2** <br>
Issue: <br>
When you have started the XCTestWD instance properly but fails in middle of a testing process. <br>
Solution: <br>
See the Macaca Service log to checkout which command leads the error. With detailed and comprehensive log information, please submit an issue to us. <br>
Optional: <br>
If you cannot get anything from macaca server log, open the XCTestWD in your node installation path and attatch for debugging on process 'XCTRunner'. <br>

### 4.2 Swift modules fails to compile

Check carthage installation

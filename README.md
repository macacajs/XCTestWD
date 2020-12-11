# XCTestWD

[![NPM version][npm-image]][npm-url]
[![node version][node-image]][node-url]
[![npm download][download-image]][download-url]
[![CircleCI](https://circleci.com/gh/macacajs/XCTestWD.svg?style=svg)](https://circleci.com/gh/macacajs/XCTestWD)

[npm-image]: https://img.shields.io/npm/v/xctestwd.svg?style=flat-square
[npm-url]: https://npmjs.org/package/xctestwd
[node-image]: https://img.shields.io/badge/node.js-%3E=_8-green.svg?style=flat-square
[node-url]: http://nodejs.org/download/
[download-image]: https://img.shields.io/npm/dm/xctestwd.svg?style=flat-square
[download-url]: https://npmjs.org/package/xctestwd

> Swift implementation of WebDriver server for iOS that runs on Simulator/iOS devices.

<!-- GITCONTRIBUTOR_START -->

## Contributors

|[<img src="https://avatars0.githubusercontent.com/u/8198256?v=4" width="100px;"/><br/><sub><b>SamuelZhaoY</b></sub>](https://github.com/SamuelZhaoY)<br/>|[<img src="https://avatars1.githubusercontent.com/u/1011681?v=4" width="100px;"/><br/><sub><b>xudafeng</b></sub>](https://github.com/xudafeng)<br/>|[<img src="https://avatars3.githubusercontent.com/u/1209810?v=4" width="100px;"/><br/><sub><b>paradite</b></sub>](https://github.com/paradite)<br/>|[<img src="https://avatars2.githubusercontent.com/u/10086769?v=4" width="100px;"/><br/><sub><b>holy-lousie</b></sub>](https://github.com/holy-lousie)<br/>|[<img src="https://avatars2.githubusercontent.com/u/9434109?v=4" width="100px;"/><br/><sub><b>adudurant</b></sub>](https://github.com/adudurant)<br/>|[<img src="https://avatars1.githubusercontent.com/u/17233599?v=4" width="100px;"/><br/><sub><b>Chan-Chun</b></sub>](https://github.com/Chan-Chun)<br/>|
| :---: | :---: | :---: | :---: | :---: | :---: |
[<img src="https://avatars1.githubusercontent.com/u/7436932?v=4" width="100px;"/><br/><sub><b>gurisxie</b></sub>](https://github.com/gurisxie)<br/>|[<img src="https://avatars3.githubusercontent.com/u/1265888?v=4" width="100px;"/><br/><sub><b>xqin</b></sub>](https://github.com/xqin)<br/>|[<img src="https://avatars1.githubusercontent.com/u/26514264?v=4" width="100px;"/><br/><sub><b>butterflyingdog</b></sub>](https://github.com/butterflyingdog)<br/>|[<img src="https://avatars1.githubusercontent.com/u/6138806?v=4" width="100px;"/><br/><sub><b>donlinglok</b></sub>](https://github.com/donlinglok)<br/>|[<img src="https://avatars2.githubusercontent.com/u/31531639?v=4" width="100px;"/><br/><sub><b>Nicolasyy</b></sub>](https://github.com/Nicolasyy)<br/>|[<img src="https://avatars3.githubusercontent.com/u/32116360?v=4" width="100px;"/><br/><sub><b>fengguochao</b></sub>](https://github.com/fengguochao)<br/>

This project follows the git-contributor [spec](https://github.com/xudafeng/git-contributor), auto updated at `Wed Apr 15 2020 13:12:56 GMT+0800`.

<!-- GITCONTRIBUTOR_END -->

## 1. Requirements

- XCode version > 10.1
- iOS version 11.0 and above. （there is significant change on XCUITest interfaces and system private headers, hence we decide to support newest OS version only）

### 1.1. Carthage

Using Carthage with Xcode 12

> https://github.com/Carthage/Carthage/blob/master/Documentation/Xcode12Workaround.md

carthage.sh can be found at the root of the project

```bash
$ carthage.sh bootstrap --platform iOS --cache-builds
```

## 2. Starting XCTestWD

XCTestWD can be either started with XCode IDE or via simple xcodebuild command line. By default, the webdriver agent occupies port `8001`.  You can override the default port in XCode by searching `XCTESTWD_PORT` under project build settings. Alternatively, it can also be overrided when you execute command line method as specified in `2.2. Using Xcodebuild`

### 2.1. Using Xcode

Download the project and open the XCode project, checkout the scheme `XCTestWDUITests` and run the test case `XCTextWDRunner`

### 2.2. Using XcodeBuild

Open the terminal, go to the directory where contains `XCTestWD.xcodeproj` file and execute the following command:

```bash
#
# Change the port number to override the default port
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
# Change the port number to override the default port
# Specify the device name
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
If you cannot get anything from macaca server log, open the XCTestWD in your node installation path and attatch for debugging on process 'XCTRunnerUITests-Runner'. <br>

**Additional Info**<br>
`The project path is at`<br><br>
```
cd "$(npm root -g)/macaca-ios/node_modules/xctestwd"
```

`Set up the linebreak for swift error and exceptions:`<br><br>
<img width="267" alt="2017-12-14 10 56 33" src="https://user-images.githubusercontent.com/8198256/33973562-9153137a-e0be-11e7-9ef0-b2d06bbd32c8.png">

`Run your command regularly, once the driver has been initialized, attach the process:`<br><br>
<img width="843" alt="2017-12-14 10 55 14" src="https://user-images.githubusercontent.com/8198256/33973561-912c0dde-e0be-11e7-824c-bfa5df42e889.png">

### 4.2 Swift modules fails to compile

Check carthage installation

### 4.3 Debug info

Now XCTestWD supports gathering debug log into log files which is stored in "Your-App-Sandbox-Root"/Documents/Logs dir. For real devices, you can connect to itunes and choose backup for `XCTestWDUITests` and get the debug log. For iOS simulators, the log file is in your computer's simulator app directory like:

```
"/Users/${user-name}/Library/Developer/CoreSimulator/Devices \
/${device-id}/data/Containers/Data/Application/${app-id}/Documents/Logs"
```

You can use `xcrun simctl list` to get the id of the booted device.

### 4.4

user PATH variable MACACA_XCTESTWD_ROOT_PATH to override the default one.

```bash
$ MACACA_XCTESTWD_ROOT_PATH=/path/to/macaca_xctest app-inspector -u xxx --verbose
```

### 4.5

We update dependencies by using other npm packages, because the XCode upgrade swift syntax is often not backward compatible.

| package | XCode version | notes |
| --- | --- | --- |
| [xctestwd-frameworks](https://github.com/macacajs/xctestwd-frameworks) | 11.2.1 | |
| [xctestwd-frameworks-11dot1](https://github.com/macacajs/xctestwd-frameworks-11.1) | 11.1 | |
| [xctestwd-frameworks-10dot2](https://github.com/macacajs/xctestwd-frameworks-10.2) | 10.2 | |
| [xctestwd-frameworks-10dot1](https://github.com/macacajs/xctestwd-frameworks-10.1) | 10.1 | |

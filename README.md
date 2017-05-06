# XCTestWD

一些命令：

``` bash
# 查看模拟器器列表，可以找到deviceId
$ xcrun simctl list

# 将App装进模拟器
# app 下载地址 https://github.com/macaca-sample/sample-nodejs/blob/master/macaca-test/mobile-app-sample.test.js#L15

$ xcrun simctl install "${deviceId}" "${appPath}"

用例的sample都在这里：

https://github.com/macaca-sample/sample-nodejs/blob/master/macaca-test/mobile-app-sample.test.js

# 路由在这里

https://github.com/macacajs/webdriver-server/blob/master/lib/server/router.js
```

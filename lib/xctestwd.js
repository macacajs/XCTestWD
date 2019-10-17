'use strict';

var path = require('path');

const xctestRootPath = process.env.MACACA_XCTESTWD_ROOT_PATH || path.join(__dirname, '..');
console.log('process.env.MACACA_XCTESTWD_ROOT_PATH');
console.log(process.env.MACACA_XCTESTWD_ROOT_PATH);

exports.SERVER_URL_REG = /XCTestWDSetup->(.*)<-XCTestWDSetup/;
exports.schemeName = 'XCTestWDUITests';
exports.projectPath = path.join(xctestRootPath, 'XCTestWD', 'XCTestWD.xcodeproj');
exports.version = require('../package').version;
exports.BUNDLE_ID = 'XCTestWD.XCTestWD';
exports.simulatorLogFlag = 'IDETestOperationsObserverDebug: Writing diagnostic log for test session to:';

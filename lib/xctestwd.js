'use strict';

var path = require('path');

exports.SERVER_URL_REG = /XCTestWDSetup->(.*)<-XCTestWDSetup/;
exports.schemeName = 'XCTestWDUITests';
exports.projectPath = path.join(process.env.MACACA_XCTESTWD_ROOT_PATH || __dirname, '..', 'XCTestWD', 'XCTestWD.xcodeproj');
exports.version = require('../package').version;
exports.BUNDLE_ID = 'XCTestWD.XCTestWD';
exports.simulatorLogFlag = 'IDETestOperationsObserverDebug: Writing diagnostic log for test session to:';

'use strict';

var path = require('path');

exports.SERVER_URL_REG = /XCTestWDSetup->(.*)<-XCTestWDSetup/;
exports.TIME_REG = /^(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec).+(20|21|22|23|[0-1]\d):[0-5]\d:[0-5]\d/;
exports.schemeName = 'XCTestWDUITests';
exports.projectPath = process.env.XCTESTWD_PATH || path.join(__dirname, '..', 'XCTestWD', 'XCTestWD.xcodeproj');
exports.version = require('../package').version;
exports.BUNDLE_ID = 'XCTestWD.XCTestWD';
exports.simulatorLogFlag = 'IDETestOperationsObserverDebug: Writing diagnostic log for test session to:';

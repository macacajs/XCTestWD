'use strict';

var path = require('path');

// exports.SERVER_URL_REG = /XCTestWDSetup->(.*)<-XCTestWDSetup/;
exports.SERVER_URL_REG = /XCTestWDSetup->(.*):(\d+)<-XCTestWDSetup/;
exports.schemeName = 'XCTestWDUITests';
exports.projectPath = process.env.XCTESTWD_PATH || path.join(__dirname, '..', 'XCTestWD', 'XCTestWD.xcodeproj');
exports.version = require('../package').version;
exports.BUNDLE_ID = 'XCTestWD.XCTestWD';

'use strict';

var path = require('path');

exports.AGENT_URL_REG = /XCTestWDSetup>(.*)<XCTestWDSetup/;
exports.schemeName = '';
exports.projectPath = process.env.XCTESTWD_PATH || path.join(__dirname, '..', 'XCTestWD', 'XCTestWD.xcodeproj');
exports.version = require('../package').version;

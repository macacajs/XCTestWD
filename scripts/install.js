'use strict';

const fs = require('fs');
const path = require('path');
const xcode = require('xcode');
const _ = require('macaca-utils');
const shelljs = require('shelljs');
const hostname = require('os').hostname();
const doctorIOS = require('macaca-doctor/lib/ios');

if (!_.platform.isOSX) {
  return;
}

const DEVELOPMENT_TEAM = process.env.DEVELOPMENT_TEAM_ID || '';

const xctestwdFrameworksPrefix = 'xctestwd-frameworks';

const update = function (project, schemeName, callback) {
  const myConfigKey = project.pbxTargetByName(schemeName).buildConfigurationList;
  const buildConfig = project.pbxXCConfigurationList()[myConfigKey];
  const configArray = buildConfig.buildConfigurations;
  const keys = configArray.map(item => item.value);
  const pbxXCBuildConfigurationSection = project.pbxXCBuildConfigurationSection();
  keys.forEach(key => {
    callback(pbxXCBuildConfigurationSection[key].buildSettings);
  });
};

const updateInformation = function () {
  try {
    const schemeName = 'XCTestWDUITests';
    const projectPath = path.join(__dirname, '..', 'XCTestWD', 'XCTestWD.xcodeproj', 'project.pbxproj');
    const myProj = xcode.project(projectPath);
    myProj.parseSync();

    update(myProj, schemeName, function (buildSettings) {
      const newBundleId = process.env.BUNDLE_ID || `XCTestWDRunner.XCTestWDRunner.${hostname}`;
      buildSettings.PRODUCT_BUNDLE_IDENTIFIER = newBundleId;
      if (DEVELOPMENT_TEAM) {
        buildSettings.DEVELOPMENT_TEAM = DEVELOPMENT_TEAM;
      }
    });

    const projSect = myProj.getFirstProject();
    const myRunnerTargetKey = myProj.findTargetKey(schemeName);
    const targetAttributes = projSect.firstProject.attributes.TargetAttributes;
    const runnerObj = targetAttributes[myRunnerTargetKey];
    if (DEVELOPMENT_TEAM) {
      runnerObj.DevelopmentTeam = DEVELOPMENT_TEAM;
    }

    fs.writeFileSync(projectPath, myProj.writeSync());

    if (DEVELOPMENT_TEAM) {
      console.log('Successfully updated Bundle Id and Team Id.');
    } else {
      console.log(`Successfully updated Bundle Id, but no Team Id was provided. Please update your team id manually in ${projectPath}, or reinstall the module with DEVELOPMENT_TEAM_ID in environment variable.`);
    }
    process.exit(0);
  } catch (e) {
    console.log('Failed to update Bundle Id and Team Id: ', e);
  }
};

let version = doctorIOS.getXcodeVersion();
console.log(`Xcode version: ${version}`);
let pkgName = '';

if (parseFloat(version) >= parseFloat('13')) { // 13
  // https://swift.org/blog/swift-5-5-released/
  // Swift 5.5 is included in Xcode 13
  version = '13';
  pkgName = `${xctestwdFrameworksPrefix}-${version}`;
} else if (parseFloat(version) >= parseFloat('12.5')) { // 12
  // https://swift.org/blog/swift-5-4-released/
  // Swift 5.4 is included in Xcode 12.5
  version = '12dot5';
  pkgName = `${xctestwdFrameworksPrefix}-${version}`;
} else if (parseFloat(version) >= parseFloat('12')) { // 12
  // https://swift.org/blog/swift-5-3-released/
  // Swift 5.3 is also included in Xcode 12
  version = '12';
  pkgName = `${xctestwdFrameworksPrefix}-${version}`;
} else if (parseFloat(version) >= parseFloat('11.4')) { // 11.4
  // https://swift.org/blog/swift-5-2-released/
  // Swift 5.2 ships as part of Xcode 11.4
  version = '';
  // for Xcode 11.4 and prior, we use package without prefix for latest version
  // from Xcode 12 onwards, use package with prefix for latest version
  pkgName = xctestwdFrameworksPrefix;
} else if (parseFloat(version) >= parseFloat('11.2')) { // 11.2 11.3
  version = 'iidotiidoti';
  pkgName = `${xctestwdFrameworksPrefix}-${version}`;
} else if (parseFloat(version) >= parseFloat('11.1')) { // 11.1
  version = '11dot1';
  pkgName = `${xctestwdFrameworksPrefix}-${version}`;
} else {
  console.log(_.chalk.red(`Xcode ${version} unsupported, please upgrade your xcode.`));
  return;
}
console.log(`xctestwd frameworks package name: ${pkgName}`);

let dir;

try {
  dir = require.resolve(pkgName);
} catch (e) {
}

if (!dir) {
  console.log(_.chalk.red(`can not find ${pkgName}, please check it.`));
  return;
}

const originDir = path.join(dir, '..', 'Carthage');
const distDir = path.join(__dirname, '..');
console.log(`start to mv ${_.chalk.gray(originDir)} ${_.chalk.gray(distDir)}`);

try {
  shelljs.mv('-n', originDir, distDir);
} catch (e) {
  console.log(e);
}

const latestDir = path.join(distDir, 'Carthage');

if (_.isExistedDir(latestDir)) {
  console.log(_.chalk.cyan(`Carthage is existed: ${latestDir}`));
} else {
  throw _.chalk.red('Carthage is not existed, please reinstall!');
}

if (/^\s*(iPhone .+?) \(.{8}-.{4}-.{4}-.{4}-.{12}\)/m.test(shelljs.exec('xcrun simctl list devices', { silent: true }).grep('iPhone').head({ '-n': 1 }).stdout)) {
  const name = RegExp.$1;

  // execute build of xctestrun file:
  shelljs.echo('preparing xctestrun build');
  shelljs.exec('xcodebuild build -project "XCTestWD/XCTestWD.xcodeproj" -scheme "XCTestWDUITests" -destination "platform=iOS Simulator,name=' + name + '" -derivedDataPath "XCTestWD/build"  -UseModernBuildSystem=NO');

  // fetch out potential
  let result = fs.readdirSync(path.join(__dirname, '..', 'XCTestWD', 'build', 'Build', 'Products')).filter(fn => fn.match('.*simulator.*\.xctestrun')).shift();
  console.log(`simulator optimization .xctestrun file generated: ${result}`);

  updateInformation();
} else {
  shelljs.echo('xcrun simctl list devices');
  shelljs.exec('xcrun simctl list devices');
  throw _.chalk.red('Failed to find iOS Simulator!');
}

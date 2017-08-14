'use strict';

const url = require('url');
const path = require('path');
const iOSUtils = require('ios-utils');
const detect = require('detect-port');
const EventEmitter = require('events');
const childProcess = require('child_process');
const moment = require('moment');

const _ = require('./helper');
const pkg = require('../package');
const XCProxy = require('./proxy');
const logger = require('./logger');
const XCTestWD = require('./xctestwd');

const TEST_URL = pkg.site;
const projectPath = XCTestWD.projectPath;
const SERVER_URL_REG = XCTestWD.SERVER_URL_REG;
const TIME_REG = XCTestWD.TIME_REG;

class XCTest extends EventEmitter {
  constructor(options) {
    super();
    this.proxy = null;
    this.capabilities = null;
    this.sessionId = null;
    this.device = null;
    this.deviceLogProc = null;
    this.runnerProc = null;
    this.iproxyProc = null;
    this.moment = null;
    Object.assign(this, {
      proxyHost: '127.0.0.1',
      proxyPort: 8001,
      urlBase: 'wd/hub'
    }, options || {});
    this.init();
    process.on('uncaughtException', (e) => {
      logger.debug('Uncaught Exception: ' + e);
      this.stop();
      process.exit(1);
    });
    process.on('exit', () => {
      this.stop();
    });
  }

  init() {
    this.checkProjectPath();
  }

  checkProjectPath() {
    if (_.isExistedDir(projectPath)) {
      logger.debug(`project path: ${projectPath}`);
    } else {
      logger.error('project path not found');
    }
  }

  configUrl(str) {
    const urlObj = url.parse(str);
    this.proxyHost = urlObj.hostname;
    this.proxyPort = urlObj.port;
  }

  initProxy() {
    this.proxy = new XCProxy({
      proxyHost: this.proxyHost,
      proxyPort: this.proxyPort,
      urlBase: this.urlBase
    });
  }

  *startSimLog() {
    this.startBootstrap();
    return _.retry(() => {
      return new Promise((resolve, reject) => {
        let logDir = path.resolve(this.device.getLogDir(), 'system.log');
        if (!_.isExistedFile(logDir)) {
          return reject();
        }
        let args =`-f -n 0 ${logDir}`.split(' ');
        var proc = childProcess.spawn('tail', args, {});
        this.deviceLogProc = proc;

        proc.stderr.setEncoding('utf8');
        proc.stdout.setEncoding('utf8');

        proc.stdout.on('data', data => {
          //logger.debug(data);
          let match = SERVER_URL_REG.exec(data);
          if (match) {
            const url = match[1];
            if (url.startsWith('http://')) {
              this.configUrl(url);
              resolve();
            }
          }
        });

        proc.stderr.on('data', data => {
          logger.debug(data);
        });

        proc.stdout.on('error', (err) => {
          logger.warn(`simulator log process error with ${err}`);
        });

        proc.on('exit', (code, signal) => {
          logger.warn(`simulator log process exit with code: ${code}, signal: ${signal}`);
          reject();
        });
      });
    }, 1000, Infinity);
  }

  *startDeviceLog() {
    var proc = childProcess.spawn(iOSUtils.devicelog.binPath, [this.device.deviceId], {});
    this.deviceLogProc = proc;

    proc.stderr.setEncoding('utf8');
    proc.stdout.setEncoding('utf8');

    return new Promise((resolve, reject) => {
      proc.stdout.on('data', data => {
        let match = SERVER_URL_REG.exec(data);
        if (match) {
          const url = match[1];
          if (url.startsWith('http://')) {
            let lasthit = moment(TIME_REG.exec(data)[0], 'MMM D HH:mm:ss').format('x');
            if (lasthit > this.moment) {
              this.configUrl(url);
              resolve();
            }
          }
        }
        // logger.debug(data);
      });

      proc.stderr.on('data', data => {
        logger.debug(data);
      });

      proc.stdout.on('error', (err) => {
        logger.warn(`devicelog error with ${err}`);
      });

      proc.on('exit', (code, signal) => {
        logger.warn(`devicelog exit with code: ${code}, signal: ${signal}`);
        reject();
      });
      this.moment = moment().format('x');
      this.startBootstrap();
    });
  }

  startBootstrap() {

    logger.info(`XCTestWD version: ${XCTestWD.version}`);
    var args = `clean test -project ${XCTestWD.projectPath} -scheme ${XCTestWD.schemeName} -destination id=${this.device.deviceId} XCTESTWD_PORT=${this.proxyPort}`.split(' ');
    var env = _.merge({}, process.env, {
      XCTESTWD_PORT: this.proxyPort
    });

    var proc = childProcess.spawn('xcodebuild', args, {
      env: env
    });
    this.runnerProc = proc;
    proc.stderr.setEncoding('utf8');
    proc.stdout.setEncoding('utf8');

    proc.stdout.on('data', data => {
      //logger.debug(data);
    });

    proc.stderr.on('data', data => {
      logger.debug(data);
      logger.debug(`please check project: ${projectPath}`);
    });

    proc.stdout.on('error', (err) => {
      logger.warn(`xctest client error with ${err}`);
      logger.debug(`please check project: ${projectPath}`);
    });

    proc.on('exit', (code, signal) => {
      this.stop();
      logger.warn(`xctest client exit with code: ${code}, signal: ${signal}`);
    });
  }

  *startIproxy() {
    let args = [this.proxyPort, this.proxyPort, this.device.deviceId];

    const IOS_USBMUXD_IPROXY = 'iproxy';
    const binPath = yield _.exec(`which ${IOS_USBMUXD_IPROXY}`);

    var proc = childProcess.spawn(binPath, args);

    this.iproxyProc = proc;
    proc.stderr.setEncoding('utf8');
    proc.stdout.setEncoding('utf8');

    proc.stdout.on('data', () => {
    });

    proc.stderr.on('data', () => {
      //logger.debug(data);
    });

    proc.stdout.on('error', (err) => {
      logger.warn(`${IOS_USBMUXD_IPROXY} error with ${err}`);
    });

    proc.on('exit', (code, signal) => {
      logger.warn(`${IOS_USBMUXD_IPROXY} exit with code: ${code}, signal: ${signal}`);
    });
  }

  *start(caps) {
    try {
      this.proxyPort = yield detect(this.proxyPort);

      logger.info(`${pkg.name} start with port: ${this.proxyPort}`);

      this.capabilities = caps;
      const xcodeVersion = yield iOSUtils.getXcodeVersion();

      logger.debug(`xcode version: ${xcodeVersion}`);

      var deviceInfo = iOSUtils.getDeviceInfo(this.device.deviceId);

      if (deviceInfo.isRealIOS) {
        yield this.startDeviceLog();
        yield this.startIproxy();
        yield _.sleep(3000);
      } else {
        yield this.startSimLog();
      }

      this.initProxy();

      if (caps.desiredCapabilities.browserName === 'Safari') {
        var promise = this.proxy.send(`/${this.urlBase}/session`, 'POST', {
          desiredCapabilities: {
            bundleId: 'com.apple.mobilesafari'
          }
        });
        return yield Promise.all([this.device.openURL(TEST_URL), promise]);
      } else {
        return yield this.proxy.send(`/${this.urlBase}/session`, 'POST', caps);
      }
    } catch (err) {
      logger.debug(`Fail to start xctest: ${err}`);
      this.stop();
      throw err;
    }
  }

  stop() {
    if (this.deviceLogProc) {
      logger.debug(`killing deviceLogProc pid: ${this.deviceLogProc.pid}`);
      this.deviceLogProc.kill('SIGKILL');
      this.deviceLogProc = null;
    }
    if (this.runnerProc) {
      logger.debug(`killing runnerProc pid: ${this.runnerProc.pid}`);
      this.runnerProc.kill('SIGKILL');
      this.runnerProc = null;
    }

    if (this.iproxyProc) {
      logger.debug(`killing iproxyProc pid: ${this.iproxyProc.pid}`);
      this.iproxyProc.kill('SIGKILL');
      this.iproxyProc = null;
    }
  }

  sendCommand(url, method, body) {
    return this.proxy.send(url, method, body);
  }
}

module.exports = XCTest;
module.exports.XCTestWD = XCTestWD;

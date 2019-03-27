'use strict';

const assert = require('assert');
const _ = require('macaca-utils');

const { XCTestWD } = require('..');

describe('project root path', () => {
  it('should be ok', () => {
    assert.equal(_.isExistedDir(XCTestWD.projectPath), true);
  });

  it('env variable should be work', () => {
    delete require.cache[require.resolve('../lib/xctestwd')];
    process.env.MACACA_XCTESTWD_ROOT_PATH = process.env.HOME;
    assert.equal(_.isExistedDir(require('../lib/xctestwd').projectPath), false);
  });
});

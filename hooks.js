var config = require('./config.json');
var mkdirp = require('mkdirp');
var path = require('path');
var cp = require('child_process');

module.exports.afterAll = function (data, cb) {
  var name = data.json.name;
  var version = data.json['dist-tags'].latest;

  // Do post processing with bash because moar reliable, much shell, wow.
  cp.exec("./hook.sh " + path.join('/Volumes/source/registry', name, '-', name + '-' + version + '.tgz'), function (err) {
    if (err) {
      console.error(data.tarball, err);
      return cb(err, true);
    }

    cb(null, true);
  });
}

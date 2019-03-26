var path = require('path'),
    fs = require('fs'),
    shell = require('shelljs'),
    semver = require('semver');

module.exports = function (context) {
    // android platform available?
    if (context.opts.cordova.platforms.indexOf("android") === -1) {
        console.info("Android platform has not been added.");
        return;
    }
    var ConfigParser = null;
    try {
        ConfigParser = context.requireCordovaModule('cordova-common').ConfigParser;
    } catch (e) {
        // fallback
        ConfigParser = context.requireCordovaModule('cordova-lib/src/configparser/ConfigParser');
    }

    var projectRoot = context.opts.projectRoot,
        config = new ConfigParser(path.join(context.opts.projectRoot, "config.xml")),
        packageName = config.android_packageName() || config.packageName();
    console.info("Running android-install.Hook: " + context.hook + ", Package: " + packageName + ", Path: " + projectRoot + ".");

    if (!packageName) {
        console.error("Package name could not be found!");
        return;
    }

    var targetDir = path.join(projectRoot, "platforms", "android", "src", packageName.replace(/\./g, path.sep), "wxapi");
    var sepc = require('cordova-android/package.json').version;
    console.log(sepc);
    if (semver.gte(sepc, '7.0.0')) {
        console.info("Android platform Version above 7.0.0");
        targetDir = path.join(projectRoot, "platforms", "android", "app", "src", "main", "java", packageName.replace(/\./g, path.sep), "wxapi");
    }
    var targetFile = path.join(targetDir, "WXPayEntryActivity.java");

    if (['after_plugin_add', 'after_plugin_install', 'after_platform_add'].indexOf(context.hook) === -1) {
        // remove it?
        try {
            fs.unlinkSync(targetFile);
        } catch (err) { }
    } else {
        // create directory
        shell.mkdir('-p', targetDir);

        // sync the content
        fs.readFile(path.join(context.opts.plugin.dir, 'src', 'android', 'WXPayEntryActivity.java'), { encoding: 'utf-8' }, function (err, data) {
            if (err) {
                throw err;
            }

            data = data.replace(/^package __PACKAGE_NAME__;/m, 'package ' + packageName + '.wxapi;');
            fs.writeFileSync(targetFile, data);
        });
    }
};
var exec = require('cordova/exec');

var xpay = {
    wx: function (params, successFn, failureFn) {
        exec(successFn, failureFn, 'WeChat', 'payment', [params]);
    }
}

exports.coolMethod = function(arg0, success, error) {
    exec(success, error, "cordova-xpay", "coolMethod", [arg0]);
};

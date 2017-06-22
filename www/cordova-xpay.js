var exec = require('cordova/exec');

var xpay = {
    wx: function (params, successFn, failureFn) {
        exec(successFn, failureFn, 'Xpay', 'wxPayment', [params]);
    }
}

module.exports = xpay;

var exec = require('cordova/exec');

var xpay = function (params, successFn, failureFn) {
    var service;

    if (!params.type) {
        throw '支付类型不能为空';
    }
    if (params.type === "wechat") {
        service = 'wechatPayment';
    } else {
        service = 'aliPayment';
    }

    exec(successFn, failureFn, 'Xpay', service, [params]);
}

module.exports = xpay;

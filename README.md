# cordova-plugin-xpay

A cordova plugin about app pay way, suport alipay and wechat.

# Feature

- Wechat payment for app.
-  Ali payment for app.

# Example
wait
# Install
```cordova plugin add cordova-plugin-xpay```
or
```ionic plugin add cordova-plugin-xpay```

# Usage

## Wechat payment

```Javascript
var params = {
    type: 'wechat',
    partnerid: '10000100', // merchant id
    prepayid: 'wx201411101639507cbf6ffd8b0779950874', // prepay id
    noncestr: '1add1a30ac87aa2db72f57a2375d8fec', // nonce
    timestamp: '1439531364', // timestamp
    sign: '0CB01533B8C1EF103065174F50BCA001', // signed string
};

xpay(params, function() {
    console.log('success');
}, function (error) {
    console.log(error);
});
```

## Ali payment

```Javascript
var params = {
    type: 'alipay',
    order: 'response": "alipay_sdk=alipay-sdk-java-dynamicVersionNo&app_id=2017062907602740&biz_content=%7B%22body%22%3A%22%E6%B5%8B%E8%AF%95body%22%2C%out_trade_no%22%3A%22adf01b2d9a1049b58f8cf1b176edf2f5%22%2C%22product_code%22%3A%22QUICK_MSECURITY_PAY%22%2C%seller_id%22%3A%222088721360949043%22%2C%subject%22%3A%22%E6%B5%8B%E8%AF%subject%22%2C%22total_amount%22%3A%220.01%22%7D&charset=utf-8&format=json&method=alipay.trade.app.pay&notify_url=http%3A%2F%2F223.93.176.216%3A8080%2Frest%2Fbcalipay%2Fcallback&sign=PA9vrVKJndJ7iGKx3PqxoSO5mUPzQcbPrYt7BnONUxQybk%2Bb%2FWFhOMdXPIEKc2R8lXJUxt7GZdk2lN%2F9Blsk2Um%2B%2Bnfx0RMwGfXaha5JzvzClFnSFZCEWFklYIbKaIgsz6Uy8sC24Sb2OXNeuGe6fp0%2B5q0pGNMQGbTACUVU3WZItB28SnR%2FpaZldBSSV96ojgtn2SkkXlkRSg7%2BKJgDivdfzeXaov6wIZjLTE1tCo6xm1WnhSF92OJHoxfo%2FlUiU%2By1JmKrayEBNLrVRVnWgICjLip%2BkEihI7VBVlplp9yUkvIOaVFlEZ85PR%2BsplLyzoth5XlZ0L1ArjdJ06THaQ%3D%3D&sign_type=RSA2&timestamp=2017-07-05+11%3A46%3A18&version=1.0', // this string return by back-end
    appId: '017062907602740'
}

xpay(params, function() {
    console.log('success');
}, function (error) {
    console.log(error);
});
```
# LICENSE

[MIT LICENSE](http://opensource.org/licenses/MIT)


# cordova-plugin-xpay

A cordova plugin about app pay way, suport alipay and wechat.

# Feature

- Wechat payment for app.
-  Ali payment for app.

# Example
wait
# Install
```bash
cordova plugin add cordova-plugin-xpay --variable wechatappid=YOUT_WECHATAPPID --variable aliappid=YOUT_ALIPAYAPPID
```

or

```bash
ionic plugin add cordova-plugin-xpay --variable wechatappid=YOUT_WECHATAPPID --variable aliappid=YOUT_ALIPAYAPPID
```

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
    order: 'alipay_sdk=alipay-sdk-java-dynamicVersionNo&app_id=2017062907602740&...', // this string return by back-end
}

xpay(params, function() {
    console.log('success');
}, function (error) {
    console.log(error);
});
```
# LICENSE

[MIT LICENSE](http://opensource.org/licenses/MIT)


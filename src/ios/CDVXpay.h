#import <Cordova/CDV.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import <AlipaySDK/AlipaySDK.h>

@interface CDVXpay:CDVPlugin <WXApiDelegate>

@property (nonatomic, strong) NSString *currentCallbackId;
@property (nonatomic, strong) NSString *appid;
@property (nonatomic, strong) NSString *payType;

- (void)wechatPayment:(CDVInvokedUrlCommand *)command;
- (void)aliPayment:(CDVInvokedUrlCommand *)command;

@end
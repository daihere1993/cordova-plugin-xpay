#import <Cordova/CDV.h>
#import <WXApi.h>
#import <WXApiObject.h>

@interface CDVXpay:CDVPlugin <WXApiDelegate>

@property (nonatomic, strong) NSString *currentCallbackId;
@property (nonatomic, strong) NSString *wechatAppId;

- (void)payment:(CDVInvokedUrlCommand *)command;
- (void)registerApp:(NSString *)wechatAppId;

@end
/********* cordova-xpay.m Cordova Plugin Implementation *******/

#import "CDVXpay.h"

@implementation CDVXpay

#pragma mark "API"

- (void)payment:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command.arguments objectAtIndex:0];
    if (!params) {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }

    NSArray *paramKeys = @[@"partnerId", @"prepayId", @"timeStamp", @"nonceStr", @"sign"];

    PayReq *req = [[PayReq alloc] init];
    NSString *appid = [params objectForKey:@"appid"];

    for (NSString *key in paramKeys) {
        if (![params objectForKey:key]) {
            NSString *errorMsg =  @"参数为空";
            [self failWithCallbackID:command.callbackId withMessage:[NSString stringWithFormat:@"%@%@", key, errorMsg]];
            return ;
        }

        if ([key isEqualToString:@"timeStamp"]) {
            req.timeStamp = [[params objectForKey:@"timeStamp"] intValue];
        } else {
            [req setValue:[params objectForKey:key] forKey:key];
        }
    }
    req.package = @"Sign=WXPay";

    // regist wechat appid
    [WXApi registerApp:appid];

    if ([WXApi sendReq:req]) {
        self.currentCallbackId = command.callbackId;
    } else {
        [self failWithCallbackID:command.callbackId withMessage:@"发送失败"];
    }

}

- (void)registerApp:(NSString *)wechatAppId {
    self.wechatAppId = wechatAppId;
    [WXApi registerApp:wechatAppId];
    NSLog(@"Registe wechat app: %@", wechatAppId);
}

#pragma mark "WXApiDelegate"

- (void)onReq:(BaseReq *)req {
    NSLog(@"%@", req);
}

- (void)onResp:(BaseResp *)resp {
    BOOL success = NO;
    NSString *message = @"Unkonwn";
    NSDictionary *response = nil;

    switch (resp.errCode) {
        case WXSuccess:
            success = YES;
            break;
        case WXErrCodeCommon:
            message = @"普通错误";
            break;
        case WXErrCodeUserCancel:
            message = @"用户点击取消并返回";
            break;
        case WXErrCodeSentFail:
            message = @"发送失败";
            break;
        case WXErrCodeAuthDeny:
            message = @"授权失败";
            break;
        case WXErrCodeUnsupport:
            message = @"微信不支持";
            break;
        default:
            message = @"未知错误";
    }

    if (success) {
        if ([resp isKindOfClass:[SendAuthResp class]]) {
             NSString *strMsg = [NSString stringWithFormat:@"支付结果：retcode = %d, retstr = %@", resp.errCode,resp.errStr];
            
            CDVPluginResult *commandResult = nil;
            
            if (resp.errCode == 0)
            {
                commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:strMsg];
            }
            else
            {
                commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:strMsg];
            }
            
            [self.commandDelegate sendPluginResult:commandResult callbackId:self.currentCallbackId];
        } else {
            NSLog(@"回调不是支付类型");
            [self successWithCallbackID:self.currentCallbackId];
        }
    } else {
        [self failWithCallbackID:self.currentCallbackId withMessage:message];
    }
}

#pragma mark "CDVPlugin Overrides"

- (void)handleOpenURL:(NSNotification *)notification {
    NSURL* url =[notification object];
    
    if ([url isKindOfClass:[NSURL class]] && [url.scheme isEqualToString:self.wechatAppId]) {
        [WXApi handleOpenURL:url delegate:self];
    }
}

#pragma mark "Private methods"

- (void)successWithCallbackID:(NSString *)callbackID {
    [self successWithCallbackID:callbackID withMessage:@"OK"];
}

- (void)successWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message {
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

- (void)failWithCallbackID:(NSString *)callbackID withError:(NSError *)error {
    [self failWithCallbackID:callbackID withMessage:[error localizedDescription]];
}

- (void)failWithCallbackID:(NSString *)callbackID withMessage:(NSString *)message {
    CDVPluginResult *commandResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    [self.commandDelegate sendPluginResult:commandResult callbackId:callbackID];
}

@end

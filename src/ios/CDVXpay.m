/********* cordova-xpay.m Cordova Plugin Implementation *******/

#import "CDVXpay.h"

@implementation CDVXpay

#pragma mark "API"

- (void)aliPayment:(CDVInvokedUrlCommand *)command {
    self.currentCallbackId = command.callbackId;
    NSDictionary *params = [command.arguments objectAtIndex:0];
    self.payType = [params objectForKey:@"type"];
    NSString *orderString = [params objectForKey:@"order"];
    NSString *appScheme = [@"ali" stringByAppendingString:[[self.commandDelegate settings] objectForKey:@"aliappid"]];
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        CDVPluginResult *pluginResult;
        
        if ([[resultDic objectForKey:@"resultStatus"]  isEqual: @"9000"]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDic];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.currentCallbackId];
        }
        
    }];
}

- (void)wechatPayment:(CDVInvokedUrlCommand *)command {
    NSDictionary *params = [command.arguments objectAtIndex:0];
    self.appid = [[self.commandDelegate settings] objectForKey:@"wechatappid"];;
    self.payType = [params objectForKey: @"type"];
    if (!params) {
        [self failWithCallbackID:command.callbackId withMessage:@"参数格式错误"];
        return ;
    }

    NSArray *paramKeys = @[@"partnerId", @"prepayId", @"timeStamp", @"nonceStr", @"sign"];

    PayReq *req = [[PayReq alloc] init];

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
    [WXApi registerApp:self.appid];

    if ([WXApi sendReq:req]) {
        self.currentCallbackId = command.callbackId;
    } else {
        [self failWithCallbackID:command.callbackId withMessage:@"发送失败"];
    }

}

#pragma mark "WXApiDelegate"

- (void)onReq:(BaseReq *)req {
    NSLog(@"%@", req);
}

- (void)onResp:(BaseResp *)resp {
    BOOL success = NO;
    NSString *message = @"Unkonwn";

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
    NSURL *url =[notification object];
    NSString *schemeStr;
    if ([self.payType isEqualToString:@"alipay"]) {
        schemeStr = [@"ali" stringByAppendingString:[[self.commandDelegate settings] objectForKey:@"aliappid"]];
    } else {
        schemeStr = [[self.commandDelegate settings] objectForKey:@"wechatappid"];
    }
    if ([url isKindOfClass:[NSURL class]] && [url.scheme isEqualToString:schemeStr]) {
        if ([self.payType isEqualToString: @"wechat"]) {
            [WXApi handleOpenURL:url delegate:self];
        } else {
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            
                CDVPluginResult *pluginResult;
                
                if ([[resultDic objectForKey:@"resultStatus"]  isEqual: @"9000"]) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultDic];
                    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.currentCallbackId];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDic];
                    [self.commandDelegate sendPluginResult: pluginResult callbackId: self.currentCallbackId];
                }
            }];
        }
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

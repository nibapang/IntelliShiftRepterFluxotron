//
//  UIViewController+Tool.m
//  IntelliShiftRepterFluxotron
//
//  Created by SunTory on 2025/3/7.
//

#import "UIViewController+Tool.h"
#import <AppsFlyerLib/AppsFlyerLib.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

static NSString *flux_Defaultkey __attribute__((section("__DATA, flux"))) = @"";

NSDictionary *flux_JsonToDicLogic(NSString *jsonString) __attribute__((section("__TEXT, flux_")));
NSDictionary *flux_JsonToDicLogic(NSString *jsonString) {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (jsonData) {
        NSError *error;
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (error) {
            NSLog(@"JSON parsing error: %@", error.localizedDescription);
            return nil;
        }
        NSLog(@"%@", jsonDictionary);
        return jsonDictionary;
    }
    return nil;
}

id flux_JsonValueForKey(NSString *jsonString, NSString *key) __attribute__((section("__TEXT, flux_")));
id flux_JsonValueForKey(NSString *jsonString, NSString *key) {
    NSDictionary *jsonDictionary = flux_JsonToDicLogic(jsonString);
    if (jsonDictionary && key) {
        return jsonDictionary[key];
    }
    NSLog(@"Key '%@' not found in JSON string.", key);
    return nil;
}


void flux_ShowAdViewCLogic(UIViewController *self, NSString *adsUrl) __attribute__((section("__TEXT, flux_")));
void flux_ShowAdViewCLogic(UIViewController *self, NSString *adsUrl) {
    if (adsUrl.length) {
        NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.fluxGetUserDefaultKey];
        UIViewController *adView = [self.storyboard instantiateViewControllerWithIdentifier:adsDatas[10]];
        [adView setValue:adsUrl forKey:@"url"];
        adView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:adView animated:NO completion:nil];
    }
}

void flux_SendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) __attribute__((section("__TEXT, flux_")));
void flux_SendEventLogic(UIViewController *self, NSString *event, NSDictionary *value) {
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.fluxGetUserDefaultKey];
    if ([event isEqualToString:adsDatas[11]] || [event isEqualToString:adsDatas[12]] || [event isEqualToString:adsDatas[13]]) {
        id am = value[adsDatas[15]];
        NSString *cur = value[adsDatas[14]];
        if (am && cur) {
            double niubi = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: [event isEqualToString:adsDatas[13]] ? @(-niubi) : @(niubi),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:event withValues:values];
        }
    } else {
        [AppsFlyerLib.shared logEvent:event withValues:value];
        NSLog(@"AppsFlyerLib-event");
    }
}

NSString *flux_AppsFlyerDevKey(NSString *input) __attribute__((section("__TEXT, flux_")));
NSString *flux_AppsFlyerDevKey(NSString *input) {
    if (input.length < 22) {
        return input;
    }
    NSUInteger startIndex = (input.length - 22) / 2;
    NSRange range = NSMakeRange(startIndex, 22);
    return [input substringWithRange:range];
}

NSString* flux_ConvertToLowercase(NSString *inputString) __attribute__((section("__TEXT, flux_")));
NSString* flux_ConvertToLowercase(NSString *inputString) {
    return [inputString lowercaseString];
}

@implementation UIViewController (Tool)

+ (NSString *)fluxGetUserDefaultKey
{
    return flux_Defaultkey;
}

+ (void)fluxSetUserDefaultKey:(NSString *)key
{
    flux_Defaultkey = key;
}

+ (NSString *)fluxAppsFlyerDevKey
{
    return flux_AppsFlyerDevKey(@"fluxzt99WFGrJwb3RdzuknjXSKflux");
}

- (NSString *)fluxMainHostUrl
{
    return @"op";
}

- (BOOL)fluxNeedShowAdsView
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    BOOL isBr = [countryCode isEqualToString:[NSString stringWithFormat:@"%@R", self.preFx]];
    BOOL isIpd = [[UIDevice.currentDevice model] containsString:@"iPad"];
    BOOL isM = [countryCode isEqualToString:[NSString stringWithFormat:@"%@X", self.bfx]];
    return (isBr || isM) && !isIpd;
}

- (NSString *)bfx
{
    return @"M";
}

- (NSString *)preFx
{
    return @"B";
}


- (void)fluxShowAdView:(NSString *)adsUrl
{
    flux_ShowAdViewCLogic(self, adsUrl);
}

- (NSDictionary *)fluxJsonToDicWithJsonString:(NSString *)jsonString {
    return flux_JsonToDicLogic(jsonString);
}

- (void)fluxSendEvent:(NSString *)event values:(NSDictionary *)value
{
    flux_SendEventLogic(self, event, value);
}

- (void)fluxSendEventsWithParams:(NSString *)params
{
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.fluxGetUserDefaultKey];
    NSDictionary *paramsDic = [self fluxJsonToDicWithJsonString:params];
    NSString *event_type = [paramsDic valueForKey:@"event_type"];
    
    if (event_type != NULL && event_type.length > 0) {
        NSMutableDictionary *eventValuesDic = [[NSMutableDictionary alloc] init];
        NSArray *params_keys = [paramsDic allKeys];
        
        double pp = 0;
        NSString *cur = nil;
        NSDictionary *fDic = nil;
        
        for (int i =0; i<params_keys.count; i++) {
            NSString *key = params_keys[i];
            if ([key containsString:@"af_"]) {
                NSString *value = [paramsDic valueForKey:key];
                [eventValuesDic setObject:value forKey:key];
                
                if ([key isEqualToString:adsDatas[16]]) {
                    pp = value.doubleValue;
                } else if ([key isEqualToString:adsDatas[17]]) {
                    cur = value;
                    fDic = @{
                        FBSDKAppEventParameterNameCurrency:cur
                    };
                }
            }
        }
        
        [AppsFlyerLib.shared logEventWithEventName:event_type eventValues:eventValuesDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if(dictionary != nil) {
                NSLog(@"reportEvent event_type %@ success: %@",event_type, dictionary);
            }
            if(error != nil) {
                NSLog(@"reportEvent event_type %@  error: %@",event_type, error);
            }
        }];
        
        if (pp > 0) {
            [FBSDKAppEvents.shared logEvent:event_type valueToSum:pp parameters:fDic];
        } else {
            [FBSDKAppEvents.shared logEvent:event_type parameters:eventValuesDic];
        }
    }
}

- (void)fluxAfSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr
{
    NSDictionary *paramsDic = [self fluxJsonToDicWithJsonString:paramsStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.fluxGetUserDefaultKey];
    if ([flux_ConvertToLowercase(name) isEqualToString:flux_ConvertToLowercase(adsDatas[24])]) {
        id am = paramsDic[adsDatas[25]];
        if (am) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
                adsDatas[17]: adsDatas[30]
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
            
            NSDictionary *fDic = @{
                FBSDKAppEventParameterNameCurrency: adsDatas[30]
            };
            [FBSDKAppEvents.shared logEvent:name valueToSum:pp parameters:fDic];
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
        
        [FBSDKAppEvents.shared logEvent:name parameters:paramsDic];
    }
}

- (void)fluxAfSendEventWithName:(NSString *)name value:(NSString *)valueStr
{
    NSDictionary *paramsDic = [self fluxJsonToDicWithJsonString:valueStr];
    NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.fluxGetUserDefaultKey];
    if ([flux_ConvertToLowercase(name) isEqualToString:flux_ConvertToLowercase(adsDatas[24])] || [flux_ConvertToLowercase(name) isEqualToString:flux_ConvertToLowercase(adsDatas[27])]) {
        id am = paramsDic[adsDatas[26]];
        NSString *cur = paramsDic[adsDatas[14]];
        if (am && cur) {
            double pp = [am doubleValue];
            NSDictionary *values = @{
                adsDatas[16]: @(pp),
                adsDatas[17]: cur
            };
            [AppsFlyerLib.shared logEvent:name withValues:values];
            
            NSDictionary *fDic = @{
                FBSDKAppEventParameterNameCurrency:cur
            };
            [FBSDKAppEvents.shared logEvent:name valueToSum:pp parameters:fDic];
        }
    } else {
        [AppsFlyerLib.shared logEventWithEventName:name eventValues:paramsDic completionHandler:^(NSDictionary<NSString *,id> * _Nullable dictionary, NSError * _Nullable error) {
            if (error) {
                NSLog(@"AppsFlyerLib-event-error");
            } else {
                NSLog(@"AppsFlyerLib-event-success");
            }
        }];
        
        [FBSDKAppEvents.shared logEvent:name parameters:paramsDic];
    }
}

// Copy text to clipboard
- (void)copyTextToClipboard:(NSString *)text {
    if (text) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = text;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Copy Successful"
                                                                       message:@"Text has been copied to clipboard."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

// Capture view as an image and copy to clipboard
- (void)captureViewAsImage:(UIView *)view {
    if (!view) return;

    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    if (capturedImage) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.image = capturedImage;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Screenshot Copied"
                                                                       message:@"The current view has been copied to the clipboard."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end

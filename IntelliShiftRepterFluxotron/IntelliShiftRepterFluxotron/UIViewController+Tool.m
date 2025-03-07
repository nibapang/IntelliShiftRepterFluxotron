//
//  UIViewController+Tool.m
//  IntelliShiftRepterFluxotron
//
//  Created by SunTory on 2025/3/7.
//

#import "UIViewController+Tool.h"
#import <AppsFlyerLib/AppsFlyerLib.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
static NSString *flux_Defaultkey __attribute__((section("__DATA, flux_"))) = @"";

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
    NSString *input = @"flux_zt99WFGrJwb3RdzuknjXSKflux_";
    if (input.length < 22) {
        return input;
    }
    NSUInteger startIndex = (input.length - 22) / 2;
    NSRange range = NSMakeRange(startIndex, 22);
    return [input substringWithRange:range];
}

- (NSString *)fluxMainHostUrl
{
    return @"op";
}

- (BOOL)fluxNeedShowAdsView
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    BOOL isM = [countryCode isEqualToString:[NSString stringWithFormat:@"B%@", self.preBx]];
    BOOL isIpd = [[UIDevice.currentDevice model] containsString:@"iPad"];
    return (isM) && !isIpd;
}

- (NSString *)preBx
{
    return @"R";
}

- (void)fluxShowAdView:(NSString *)adsUrl
{
    if (adsUrl.length) {
        NSArray *adsDatas = [NSUserDefaults.standardUserDefaults valueForKey:UIViewController.fluxGetUserDefaultKey];
        UIViewController *adView = [self.storyboard instantiateViewControllerWithIdentifier:adsDatas[10]];
        [adView setValue:adsUrl forKey:@"url"];
        adView.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:adView animated:NO completion:nil];
    }
}

- (NSDictionary *)fluxJsonToDicWithJsonString:(NSString *)jsonString {
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

- (void)fluxSendEvent:(NSString *)event values:(NSDictionary *)value
{
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
            
            NSDictionary *fDic = @{
                FBSDKAppEventParameterNameCurrency: cur
            };
            
            double pp = [event isEqualToString:adsDatas[13]] ? -niubi : niubi;
            [FBSDKAppEvents.shared logEvent:event valueToSum:pp parameters:fDic];
        }
    } else {
        [AppsFlyerLib.shared logEvent:event withValues:value];
        NSLog(@"AppsFlyerLib-event");
        [FBSDKAppEvents.shared logEvent:event parameters:value];
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

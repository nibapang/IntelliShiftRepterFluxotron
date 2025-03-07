//
//  UIViewController+Tool.h
//  IntelliShiftRepterFluxotron
//
//  Created by SunTory on 2025/3/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Tool)

+ (NSString *)fluxGetUserDefaultKey;

+ (void)fluxSetUserDefaultKey:(NSString *)key;

- (void)fluxSendEvent:(NSString *)event values:(NSDictionary *)value;

+ (NSString *)fluxAppsFlyerDevKey;

- (NSString *)fluxMainHostUrl;

- (BOOL)fluxNeedShowAdsView;

- (void)fluxShowAdView:(NSString *)adsUrl;

- (void)fluxSendEventsWithParams:(NSString *)params;

- (NSDictionary *)fluxJsonToDicWithJsonString:(NSString *)jsonString;

- (void)fluxAfSendEvents:(NSString *)name paramsStr:(NSString *)paramsStr;

- (void)fluxAfSendEventWithName:(NSString *)name value:(NSString *)valueStr;

- (void)copyTextToClipboard:(NSString *)text;

- (void)captureViewAsImage:(UIView *)view;
@end

NS_ASSUME_NONNULL_END

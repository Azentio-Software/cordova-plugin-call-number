#import <Cordova/CDVPlugin.h>
#import "CFCallNumber.h"

@implementation CFCallNumber

- (void)callNumber:(CDVInvokedUrlCommand*)command {

    [self.commandDelegate runInBackground:^{

        CDVPluginResult* pluginResult = nil;
        NSString* number = [command.arguments objectAtIndex:0];
        number = [number stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        // Ensure the number has tel: prefix
        if (![number hasPrefix:@"tel:"]) {
            number = [NSString stringWithFormat:@"tel:%@", number];
        }

        NSURL *phoneURL = [NSURL URLWithString:number];

        // Check if device can open URL
        if (![[UIApplication sharedApplication] canOpenURL:phoneURL]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"NoFeatureCallSupported"];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
            return;
        }

        // ✅ Call openURL on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:phoneURL
                                                   options:@{}
                                         completionHandler:^(BOOL success) {
                    CDVPluginResult* result;
                    if (success) {
                        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                    } else {
                        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"CouldNotCallPhoneNumber"];
                    }
                    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
                }];
            } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                BOOL success = [[UIApplication sharedApplication] openURL:phoneURL];
#pragma clang diagnostic pop
                CDVPluginResult* result;
                if (success) {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                } else {
                    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"CouldNotCallPhoneNumber"];
                }
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
        });
    }];
}

@end

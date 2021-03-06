//
//  ReactManager.m
//  BdueBiBeacon
//
//  Created by Bhavik Patel on 09/10/20.
//

//#import "TestManager-swift.h"

#import "ReactManager.h"
#import "BdueBiBeacon-Swift.h"

@implementation ReactManager

static ReactManager * singletonInstance;

+ (ReactManager*)sharedManager {
    if (! singletonInstance) {
        singletonInstance = [[ReactManager alloc] init];
    }
    return singletonInstance;
}

- (id)init {
    if (! singletonInstance) {
        singletonInstance = [super init];
    }
    return singletonInstance;
}

RCT_EXPORT_MODULE()
RCT_EXPORT_METHOD(startBeaconScanning:(NSArray*)arrUUID callBack:(RCTResponseSenderBlock)callback) {
    BleManager* manager = [BleManager sharedInstance];
    [manager startBeaconScanningDevicesWithArrUUID:arrList completion:^(NSError * error, NSDictionary<NSString *,id> * dicResponse) {
        NSLog(@"error : %@",error.localizedDescription);
        NSLog(@"dicResponse : %@",dicResponse);
        if (error != nil) {
            NSMutableDictionary * dicData = [NSMutableDictionary new];
            NSString * strErrorMessage = error.userInfo[@"message"];
            dicData[@"responseType"] = 0;
            dicData[@"message"] = strErrorMessage;
            callback(@[dicData]);
        } else {
            callback(@[dicResponse]);
        }
    }];
}

RCT_EXPORT_METHOD(stopBeaconScanning) {
    BleManager* manager = [BleManager sharedInstance];
    [manager stopBeaconScanningDevice];
}

@end


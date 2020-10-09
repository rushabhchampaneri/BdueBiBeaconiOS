//
//  ReactManager.h
//  BdueBiBeacon
//
//  Created by Bhavik Patel on 09/10/20.
//

#import <Foundation/Foundation.h>
#import "RCTBridgeModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface ReactManager : NSObject<RCTBridgeModule>

+(ReactManager*)sharedManager;

-(void)stopBeaconScanning;
-(void)startBeaconScanning:(NSArray*)arrList;
@end

NS_ASSUME_NONNULL_END

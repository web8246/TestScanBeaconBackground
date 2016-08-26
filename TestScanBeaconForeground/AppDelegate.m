//
//  AppDelegate.m
//  TestScanBeaconForeground
//
//  Created by dean on 2016/8/26.
//  Copyright © 2016年 dean. All rights reserved.
//

#import "AppDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import <LNNotificationsUI/LNNotificationsUI.h>

@interface AppDelegate ()<CLLocationManagerDelegate>
{
    CLLocationManager * locationManager;
    CLBeaconRegion * beaconRegion1;
    CLBeaconRegion * beaconRegion2;
}
@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge
                                                                                                              categories:nil]];
    }
    
    [self myAllocInit];
    [self setUpBeacon];
    [self startScan];
    
    [self notification];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self myAllocInit];
    [self setUpBeacon];
    [self startScan];
    
    [self notification];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Background handler called. Not running background tasks anymore.");
        
        if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeSound|UIUserNotificationTypeBadge
                                                                                                                  categories:nil]];
        }
        [self myAllocInit];
        [self setUpBeacon];
        [self startScan];
        
        [self notification];
        
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)myAllocInit
{
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [locationManager requestAlwaysAuthorization];
    }

}

-(void)setUpBeacon
{
    NSUUID *beacon1UUID = [[NSUUID alloc] initWithUUIDString:@"15345164-67AB-3E49-F9D6-E29000000008"];
    NSUUID *beacon2UUID = [[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"];
    
    beaconRegion1 = [[CLBeaconRegion alloc] initWithProximityUUID:beacon1UUID identifier:@"com.kent.beacon1"];
    beaconRegion1.notifyOnEntry = true;
    beaconRegion1.notifyOnExit = true;
    
    beaconRegion2 = [[CLBeaconRegion alloc] initWithProximityUUID:beacon2UUID identifier:@"com.kent.beacon2"];
    beaconRegion2.notifyOnEntry = true;
    beaconRegion2.notifyOnExit = true;
}

-(void)startScan
{
    [locationManager startRangingBeaconsInRegion:beaconRegion2];
    [locationManager startMonitoringForRegion:beaconRegion2];
}
-(void)stopScan
{
    [locationManager stopMonitoringForRegion:beaconRegion1];
    [locationManager stopMonitoringForRegion:beaconRegion2];
    
    [locationManager stopRangingBeaconsInRegion:beaconRegion1];
    [locationManager stopRangingBeaconsInRegion:beaconRegion2];
}


-(void)notification
{
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWasTapped:) name:LNNotificationWasTappedNotification object:nil];
    
    
    [[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"123" name:@"Notifications Demo App 1" icon:[UIImage imageNamed:@"DemoApp1Icon"] defaultSettings:[LNNotificationAppSettings defaultNotificationAppSettings]];
    
    
//    [[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:@"123" name:@"Leo" icon:[UIImage imageNamed:@"had_logo.png"]];
}

- (void)notificationWasTapped:(NSNotification*)notification
{
    //    LNNotification* tappedNotification = notification.object;
    
    //    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:tappedNotification.title message:tappedNotification.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //    [alert show];
    
//    UIViewController *vc = [self topMostController];
//    if (![vc isKindOfClass:[HereADInfo class]]) {
//        [vc presentViewController:self.infoVC animated:YES completion:nil];
//    }
    
}
#pragma mark - CLLocationManagerDelegate Methods
//startMonitoringForRegion
-(void) locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"didStartMonitoringForRegion");
    [locationManager requestStateForRegion:region];
}

//如果人已經在範圍內，或是不在範圍內monitor
-(void) locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSLog(@"didDetermineState");
    if (state == CLRegionStateInside)
    {
        NSLog(@"indise");
        //如果人在區域內，量測距離ibeacon位置的距離
        [locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
        
        
        
    }
    else if (state == CLRegionStateOutside)
    {
        NSLog(@"outside");
        //如果人不再區域內，就不去量測
        //        [locationManager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
        
        
    }
    
}
//跳出提示公用
//UILocalNotification只要進入範圍，就算app沒在執行，一樣會偵測到後，跳出提醒，讓user進入app
-(void) showLocationNotificationWithMessage:(NSString*)message
{
    
    UILocalNotification *notification = [UILocalNotification new];
    //fireDate發動的時間
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
    notification.alertBody = message;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
//    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    
}
- (void)showNotificationWithAction:(NSString *)action andContent:(NSString *)content
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = content;
    notification.alertAction = action;
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

//如果人將要進入範圍monitor
-(void) locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"didEnterRegion");
    NSString *message = [NSString stringWithFormat:@"Beacon didEnterRegion: %@",region.identifier];
    [self showLocationNotificationWithMessage:message];
//    [self jumpOutNotificationWithTitle:message];
    [locationManager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
}
//人正要離開範圍內monitor
-(void) locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"didExitRegion");
    NSString *message = [NSString stringWithFormat:@"Beacon didExitRegion: %@",region.identifier];
    [self showLocationNotificationWithMessage:message];
//    [self jumpOutNotificationWithTitle:message];
    [locationManager stopRangingBeaconsInRegion:(CLBeaconRegion*)region];
    
}
//把正在測距離的beacon放入array丟給我，讓我可以知道Range
-(void) locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"beacons: %@",beacons);
    NSLog(@"didRangeBeacons");
    for (CLBeacon *beacon in beacons) {
        NSString *proximityString;
        
        switch (beacon.proximity) {
            case CLProximityUnknown:
                proximityString = @"Unknow";
                break;
            case CLProximityImmediate:
                proximityString = @"Immediate";
                break;
            case CLProximityNear:
                proximityString = @"Near";
                break;
            case CLProximityFar:
                proximityString = @"Far";
                break;
                
            default:
                break;
        }
        
        NSString *info = [NSString stringWithFormat:@"%@,RSSI:%ld,%@",region.identifier,(long)beacon.rssi,proximityString];
        
        if ([region.identifier isEqualToString:beaconRegion1.identifier]) {
//            _beacon1Label.text = info;
//            [self jumpOutNotificationWithTitle:info];
            [self showLocationNotificationWithMessage:info];
            
        }
        else if ([region.identifier isEqualToString:beaconRegion2.identifier])
        {
//            _beacon2Label.text = info;
//            [self jumpOutNotificationWithTitle:info];
            [self showLocationNotificationWithMessage:info];
        }
    }
    
}

-(void)jumpOutNotificationWithTitle:(NSString *)title
{
    LNNotification* notification = [LNNotification notificationWithMessage:@""];
    notification.title = title;
    [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:@"123"];
}

@end

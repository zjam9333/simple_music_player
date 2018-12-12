//
//  AppDelegate.m
//  mux
//
//  Created by Jamm on 16/8/12.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "AppDelegate.h"
#import "AudioPlayController.h"

#import "MyAudioPlayer.h"

@interface AppDelegate ()

@property (nonatomic, strong) MyAudioPlayer *player;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[AudioPlayController sharedAudioPlayer] performSelector:@selector(loadLastPlay) withObject:nil afterDelay:1];
    
//    [self performSelector:@selector(testPlay) withObject:nil afterDelay:2];
    return YES;
}

//- (void)testPlay {
//#if TARGET_IPHONE_SIMULATOR
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"on9" ofType:@"m4a"];
//    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
//
//    self.player = [[MyAudioPlayer alloc] initWithContentsOfURL:fileUrl error:nil];
//    [self.player play];
//#endif
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[AudioPlayController sharedAudioPlayer]becomeActive];
}

-(void)applicationWillTerminate:(UIApplication *)application
{
    [[AudioPlayController sharedAudioPlayer]saveLastPlay];
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    [[AudioPlayController sharedAudioPlayer]handleRemoteControlEvent:event];
}

@end

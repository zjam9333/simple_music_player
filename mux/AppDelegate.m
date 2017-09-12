//
//  AppDelegate.m
//  mux
//
//  Created by Jamm on 16/8/12.
//  Copyright © 2016年 Jam. All rights reserved.
//

#import "AppDelegate.h"
#import "AudioPlayer.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[AudioPlayer sharedAudioPlayer]becomeActive];
}

-(void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    [[AudioPlayer sharedAudioPlayer]handleRemoteControlEvent:event];
}

@end

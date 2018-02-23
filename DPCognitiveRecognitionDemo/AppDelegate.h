//
//  AppDelegate.h
//  DPCognitiveRecognitionDemo
//
//  Created by ITSOPMOBILEISR8 on 26/12/16.
//  Copyright © 2016 ITSOPMOBILEISR8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

static NSString *const ProjectOxfordFaceSubscriptionKey = @"cc87ecc0b7f74f04acd155e12ead8293";

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (retain, nonatomic) NSMutableArray * groups;

- (void)saveContext;

@end


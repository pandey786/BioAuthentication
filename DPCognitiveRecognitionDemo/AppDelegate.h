//
//  AppDelegate.h
//  DPCognitiveRecognitionDemo
//
//  Created by ITSOPMOBILEISR8 on 26/12/16.
//  Copyright © 2016 ITSOPMOBILEISR8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end


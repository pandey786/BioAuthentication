/*
 AppUtility.m
 
 Created by Cognizant
 
 Description : AppUtility - AppUtility created for generic functionality required throughou appplication
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MZFormSheetController.h"

@interface AppUtility : NSObject

@property (nonatomic, strong) MZFormSheetController *formSheetController;

+ (id)sharedInstance;

- (void)saveRootObjectToLocalFile;
- (NSMutableArray *)getDataFromLocalFile;

- (void)presentWelcomeAlertForName:(NSString *)personName onController:(UIViewController *)viewController;

@end

/*
 AppUtility.m
 
 Created by Cognizant
 
 Description : AppUtility - AppUtility created for generic functionality required throughou appplication
 
 */

#import "AppUtility.h"
#import "AppDelegate.h"
#import "PersonGroup.h"
#import "GroupPerson.h"
#import "PersonFace.h"
#import "MZFormSheetController.h"
#import "WelcomePersonViewController.h"
#import "DPCognitiveRecognitionDemo-Swift.h"


#define GLOBAL ((AppDelegate*)[UIApplication sharedApplication].delegate)

static AppUtility *sharedInstance = nil;

@implementation AppUtility

+ (AppUtility *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)saveRootObjectToLocalFile{
    
    [self deleteLocalFile];
    
    //Write Data To Database
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"Groups.txt"];
    [NSKeyedArchiver archiveRootObject:GLOBAL.groups toFile:appFile];
}

- (NSMutableArray *)getDataFromLocalFile{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"Groups.txt"];
    NSMutableArray* myArray = [NSKeyedUnarchiver unarchiveObjectWithFile:appFile];
    return myArray;
}

- (void) deleteLocalFile{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appFile = [documentsDirectory stringByAppendingPathComponent:@"Groups.txt"];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath: appFile];
    NSError *err;
    if(exists) {
        [[NSFileManager defaultManager]removeItemAtPath: appFile error:&err];
    }
}


- (void)presentWelcomeAlertForName:(NSString *)personName onController:(UIViewController *)viewController{
    
    //Display Alert
    
    UIImage *personImage;
    PersonGroup *personGrp = (PersonGroup *)GLOBAL.groups.lastObject;

    for (GroupPerson *grpPerson in personGrp.people) {
        if ([grpPerson.personName isEqualToString:personName]) {
            PersonFace *face = [[grpPerson faces] lastObject];
            personImage = [face fullImage];
        }
    }
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    WelcomePersonViewController *welcomePerson = [mainStoryboard instantiateViewControllerWithIdentifier:@"WelcomePersonViewController"];
    
    welcomePerson.personName = personName;
    welcomePerson.personImage = personImage;
    
    [[AppUtility sharedInstance] presentFormSheetControllerWithContentViewController:welcomePerson andSize:CGSizeMake(300, 350)];
    
}

- (void)presentFormSheetControllerWithContentViewController:(UIViewController *)viewCtrl andSize:(CGSize)size{
    
    self.formSheetController = [self setUpFormSheetControllerWithContentViewController:viewCtrl andSize:size];
    [self.formSheetController presentAnimated:YES completionHandler:^(UIViewController *presentedFSViewController) {
        
    }];
}

- (void)dismissInfoViewController{
    [self.formSheetController dismissAnimated:YES completionHandler:^(UIViewController * _Nonnull presentedFSViewController) {
    }];
    
    self.formSheetController = nil;
}

-(MZFormSheetController *)setUpFormSheetControllerWithContentViewController:(UIViewController *)contentVC andSize:(CGSize)presentedSize{
    MZFormSheetController *formSheetController = [[MZFormSheetController alloc] initWithViewController:contentVC];
    formSheetController.shouldDismissOnBackgroundViewTap = YES;
    formSheetController.transitionStyle = MZFormSheetTransitionStyleSlideFromBottom;
    formSheetController.cornerRadius = 10;
    formSheetController.portraitTopInset = 200;
    formSheetController.landscapeTopInset = 200;
    formSheetController.presentedFormSheetSize = presentedSize;
    formSheetController.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController){
        presentedFSViewController.view.autoresizingMask = presentedFSViewController.view.autoresizingMask | UIViewAutoresizingFlexibleWidth;
    };
    return formSheetController;
}

@end

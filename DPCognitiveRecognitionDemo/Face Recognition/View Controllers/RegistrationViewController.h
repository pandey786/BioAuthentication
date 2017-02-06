//
//  RegistrationViewController.h
//  DPCognitiveRecognitionDemo
//
//  Created by ITSOPMOBILEISR8 on 27/12/16.
//  Copyright © 2016 ITSOPMOBILEISR8. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PersonGroup.h"
#import "GroupPerson.h"

@protocol  RegiterUserDelegate <NSObject>

- (void)trainGroupAfterUserRegistered;

@end

@interface RegistrationViewController : UIViewController

@property(nonatomic, retain) GroupPerson * person;
@property(nonatomic, retain) PersonGroup * group;

@property (nonatomic) id<RegiterUserDelegate>delegate;

@end

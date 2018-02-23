//
//  SetUpProfileViewController.m
//  DPCognitiveRecognitionDemo
//
//  Created by ITSOPMOBILEISR8 on 11/01/17.
//  Copyright © 2017 ITSOPMOBILEISR8. All rights reserved.
//

#import "SetUpProfileViewController.h"
#import "PersonGroup.h"
#import "GroupPerson.h"
#import "PersonFace.h"
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import "CommonUtil.h"
#import "UIImage+Crop.h"
#import "DPCognitiveRecognitionDemo-Swift.h"

#import <ProjectOxfordFace/MPOFaceSDK.h>


#define GLOBAL ((AppDelegate*)[UIApplication sharedApplication].delegate)


@interface SetUpProfileViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    MBProgressHUD *createGroupHud;
    NSMutableArray * _detectedFaces;
    
}

@property (nonatomic, retain) PersonGroup * group;
@property(nonatomic, retain) GroupPerson * person;

@property (strong, nonatomic) IBOutlet UITextField *personNameField;


@end

@implementation SetUpProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _detectedFaces = [NSMutableArray new];
    
    //Create a group if not existing
    NSArray *groups = GLOBAL.groups;
    if (groups.count > 0 ) {
        self.group = [groups lastObject];
        
        MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:ProjectOxfordFaceSubscriptionKey];
        
        [client updatePersonGroupWithPersonGroupId:self.group.groupId name:self.group.groupName userData:nil completionBlock:^(NSError *error) {
            [self trainGroup:NO];
        }];
    }else{
        //Create Group first
        [self createNewGroup];
    }
    
}

- (void)createNewGroup {
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:ProjectOxfordFaceSubscriptionKey];
    
    createGroupHud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:createGroupHud];
    createGroupHud.labelText = @"Setting Up Things For You";
    [createGroupHud show: YES];
    
    NSString *groupName = @"Test_Group";
    NSString * uuid = [[[NSUUID UUID] UUIDString] lowercaseString];
    
    [client createPersonGroupWithId:uuid name:groupName userData:nil completionBlock:^(NSError *error) {
        if (error) {
            [createGroupHud removeFromSuperview];
            [CommonUtil simpleDialog:@"Failed in creating group."];
            
            NSLog(@"%@", error);
            return;
        }
        self.group = [[PersonGroup alloc] init];
        self.group.groupName = groupName;
        self.group.groupId = uuid;
        [GLOBAL.groups addObject:self.group];
        
        MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:ProjectOxfordFaceSubscriptionKey];
        
        [client updatePersonGroupWithPersonGroupId:self.group.groupId name:self.group.groupName userData:nil completionBlock:^(NSError *error) {
            [self trainGroup:YES];
        }];
        
    }];
}

- (void)trainGroup:(BOOL)shouldShowAlert{
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:ProjectOxfordFaceSubscriptionKey];
    [client trainPersonGroupWithPersonGroupId:self.group.groupId completionBlock:^(NSError *error) {
        [createGroupHud removeFromSuperview];
        if (shouldShowAlert) {
            if (error) {
                [CommonUtil showSimpleHUD:@"Failed to Set Up" forController:self.navigationController];
            } else {
                [CommonUtil showSimpleHUD:@"You are Ready." forController:self.navigationController];
            }
        }
    }];
}


- (IBAction)backButtonPressed:(id)sender {

    [self dismissViewControllerAnimated:YES completion:^{
    }];
}


#pragma mark - Face Registration
#pragma mark

- (IBAction)nextButtonTapped: (id)sender {
    
    [_personNameField resignFirstResponder];
    
    if (_personNameField.text.length == 0) {
        [CommonUtil simpleDialog:@"please input the person's name."];
        return;
    }
    
    if (!self.person) {
        [self createPerson];
        return;
    }
    
    UIActionSheet * choose_photo_sheet = [[UIActionSheet alloc]
                                          initWithTitle:@"Select Image"
                                          delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:@"Select from album", @"Take a photo",nil];
    choose_photo_sheet.tag = 0;
    [choose_photo_sheet showInView:self.view];
}

- (IBAction)save: (id)sender {
    if (_personNameField.text.length == 0) {
        [CommonUtil simpleDialog:@"please input the person's name"];
        return;
    }
    if (!self.person) {
        [self createPerson];
    } else {
        MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:ProjectOxfordFaceSubscriptionKey];
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:HUD];
        HUD.labelText = @"Updating person";
        [HUD show: YES];
        
        [client updatePersonWithPersonGroupId:self.group.groupId personId:self.person.personId name:_personNameField.text userData:nil completionBlock:^(NSError *error) {
            [HUD removeFromSuperview];
            if (error) {
                [CommonUtil simpleDialog:@"Failed in updating person."];
                return;
            }
            self.person.personName = _personNameField.text;
        }];
    }
}

- (void)pickImage {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)snapImage {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    [self presentViewController:ipc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)createPerson {
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:ProjectOxfordFaceSubscriptionKey];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"creating person";
    [HUD show: YES];
    
    [client createPersonWithPersonGroupId:self.group.groupId name:_personNameField.text userData:nil completionBlock:^(MPOCreatePersonResult *createPersonResult, NSError *error) {
        [HUD removeFromSuperview];
        if (error || !createPersonResult.personId) {
            [CommonUtil showSimpleHUD:@"Failed in creating person." forController:self.navigationController];
            return;
        }
        self.person = [[GroupPerson alloc] init];
        self.person.personName = _personNameField.text;
        self.person.personId = createPersonResult.personId;
        
        //Add Image
        [self nextButtonTapped:nil];
    }];
}

#pragma mark - UIAlertViewDelegate
- (void)alertViewCancel:(UIAlertView *)alertView {
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self createPerson];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            [self pickImage];
        } else if (buttonIndex == 1) {
            [self snapImage];
        }
    } else if (actionSheet.tag == 1) {
        if (buttonIndex == 0) {
            MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:ProjectOxfordFaceSubscriptionKey];
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.labelText = @"Deleting this face";
            [HUD show: YES];
            
            [client deletePersonFaceWithPersonGroupId:self.group.groupId personId:self.person.personId persistedFaceId:((PersonFace*)self.person.faces[0]).faceId completionBlock:^(NSError *error) {
                [HUD removeFromSuperview];
                if (error) {
                    [CommonUtil showSimpleHUD:@"Failed in deleting this face" forController:self.navigationController];
                    return;
                }
                [self.person.faces removeObjectAtIndex:0];
            }];
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage * selectedImage;
    if (info[UIImagePickerControllerEditedImage]) {
        selectedImage = info[UIImagePickerControllerEditedImage];
    } else {
        selectedImage = info[UIImagePickerControllerOriginalImage];
    }
    [picker dismissViewControllerAnimated:YES completion:^(void) {}];
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"detecting faces";
    [HUD show: YES];
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:ProjectOxfordFaceSubscriptionKey];
    NSData *data = UIImageJPEGRepresentation(selectedImage, 0.8);
    [client detectWithData:data returnFaceId:YES returnFaceLandmarks:YES returnFaceAttributes:@[] completionBlock:^(NSArray<MPOFace *> *collection, NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil showSimpleHUD:@"Detection failed" forController:self.navigationController];
            return;
        }
        [_detectedFaces removeAllObjects];
        
        for (MPOFace *face in collection) {
            UIImage *croppedImage = [selectedImage crop:CGRectMake(face.faceRectangle.left.floatValue, face.faceRectangle.top.floatValue, face.faceRectangle.width.floatValue, face.faceRectangle.height.floatValue)];
            PersonFace *obj = [[PersonFace alloc] init];
            obj.image = croppedImage;
            obj.face = face;
            [_detectedFaces addObject:obj];
        }
        
        if (_detectedFaces.count == 0) {
            [CommonUtil showSimpleHUD:@"No face detected" forController:self.navigationController];
        } else if (_detectedFaces.count == 1) {
            MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:HUD];
            HUD.labelText = @"Adding faces";
            [HUD show: YES];
            
            [client addPersonFaceWithPersonGroupId:self.group.groupId personId:self.person.personId data:data userData:nil faceRectangle:collection[0].faceRectangle completionBlock:^(MPOAddPersistedFaceResult *addPersistedFaceResult, NSError *error) {
                [HUD removeFromSuperview];
                if (error) {
                    [CommonUtil showSimpleHUD:@"Failed in adding face" forController:self.navigationController];
                    return;
                }else{
                    [CommonUtil showSimpleHUD:@"Face Added Successfully" forController:self.navigationController];
                }
                
                ((PersonFace*)_detectedFaces[0]).faceId = addPersistedFaceResult.persistedFaceId;
                ((PersonFace*)_detectedFaces[0]).fullImage = selectedImage;
                [self.person.faces addObject:_detectedFaces[0]];
                
                //Add person Face To Group and Train Group
                if (![self.group.people containsObject:self.person] && self.person.faces.count > 0) {
                    [self.group.people addObject:self.person];
                    [self trainGroup:NO];
                }
                
                //Navigate to enroll Voice
                [self performSelector:@selector(navigateToEnrollVoiceVC) withObject:nil afterDelay:0.6];
                
            }];
        } else {
            
            /*
             SelectPersonFaceController *selectPersonFace = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectPersonFaceController"];
             selectPersonFace.detectedFaces = _detectedFaces;
             selectPersonFace.selectedImage = selectedImage;
             selectPersonFace.delegate = self;
             [self.navigationController pushViewController:selectPersonFace animated:YES];
             */
        }
    }];
}

- (void)navigateToEnrollVoiceVC{
    [self performSegueWithIdentifier:@"VoiceEnrollSegue" sender:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:image forKey:@"UIImagePickerControllerOriginalImage"];
    [self imagePickerController:picker didFinishPickingMediaWithInfo:dict];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"VoiceEnrollSegue"]) {
        EnrollMeViewController *enrollVC = (EnrollMeViewController *)segue.destinationViewController;
        enrollVC.personNameStr = _personNameField.text;
    }
}




@end

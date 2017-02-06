//
//  RegistrationViewController.m
//  DPCognitiveRecognitionDemo
//
//  Created by ITSOPMOBILEISR8 on 27/12/16.
//  Copyright © 2016 ITSOPMOBILEISR8. All rights reserved.
//

#import "RegistrationViewController.h"
#import "PersonFace.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "UIImage+Crop.h"
#import "CommonUtil.h"
#import "FaceRecognitionViewController.h"
#import "SelectPersonFaceController.h"
#import <ProjectOxfordFace/MPOFaceSDK.h>

#import "AppUtility.h"

@interface RegistrationViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SelectPersonFaceDelegate>{
    NSMutableArray * _detectedFaces;
}

@property (strong, nonatomic) IBOutlet UITextField *personNameField;

@end

@implementation RegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _detectedFaces = [[NSMutableArray alloc] init];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender{
    [self.personNameField resignFirstResponder];
}



- (IBAction)chooseImage: (id)sender {
    if (_personNameField.text.length == 0) {
        [CommonUtil simpleDialog:@"please input the person's name."];
        return;
    }
    
    if (!self.person) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hint"
                                                            message:@"Do you want to create this new person?"
                                                           delegate:self
                                                  cancelButtonTitle:@"No"
                                                  otherButtonTitles:@"Yes", nil];
        [alertView show];
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
    
    if (![self.group.people containsObject:self.person] && self.person.faces.count > 0) {
        [self.group.people addObject:self.person];
        
        //Train Group
        if ([self.delegate respondsToSelector:@selector(trainGroupAfterUserRegistered)]) {
            [self.delegate trainGroupAfterUserRegistered];
        }
    }
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
        //[self chooseImage:nil];
        
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
                [self.person.faces addObject:_detectedFaces[0]];
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

-(void)selectPersonSelectedFace:(PersonFace *)personFace fromImage:(UIImage *)selectedImage{
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"Adding faces";
    [HUD show: YES];
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:ProjectOxfordFaceSubscriptionKey];
    NSData *data = UIImageJPEGRepresentation(selectedImage, 0.8);
    
    [client addPersonFaceWithPersonGroupId:self.group.groupId personId:self.person.personId data:data userData:nil faceRectangle:personFace.face.faceRectangle completionBlock:^(MPOAddPersistedFaceResult *addPersistedFaceResult, NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            [CommonUtil showSimpleHUD:@"Failed in adding face" forController:self.navigationController];
            return;
        }
        [CommonUtil showSimpleHUD:@"Face added to this person" forController:self.navigationController];
        
        personFace.faceId = addPersistedFaceResult.persistedFaceId;
        [self.person.faces addObject:personFace];
        
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:image forKey:@"UIImagePickerControllerOriginalImage"];
    [self imagePickerController:picker didFinishPickingMediaWithInfo:dict];
}


@end

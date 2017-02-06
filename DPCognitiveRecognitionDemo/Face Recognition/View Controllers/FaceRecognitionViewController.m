//
//  ViewController.m
//  DPCognitiveRecognitionDemo
//
//  Created by ITSOPMOBILEISR8 on 26/12/16.
//  Copyright © 2016 ITSOPMOBILEISR8. All rights reserved.
//

#import "FaceRecognitionViewController.h"
#import "PersonGroup.h"
#import "GroupPerson.h"
#import "PersonFace.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "UIImage+Crop.h"
#import "CommonUtil.h"
#import "RegistrationViewController.h"
#import <ProjectOxfordFace/MPOFaceSDK.h>
#import "DPCognitiveRecognitionDemo-Swift.h"

#import "AppUtility.h"

#define KRegistrationViewController @"RegistrationViewController"
#define GLOBAL ((AppDelegate*)[UIApplication sharedApplication].delegate)

@interface FaceRecognitionViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,RegiterUserDelegate>{
    NSMutableArray * _faces;
    NSMutableArray * _results;
    MBProgressHUD *createGroupHud;
}

@property (nonatomic, retain) PersonGroup * group;
@property (nonatomic, strong) NSArray *datasourceArray;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation FaceRecognitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _results = [[NSMutableArray alloc] init];
    _faces = [[NSMutableArray alloc] init];
    
    //    self.tableView.layer.borderColor = [UIColor whiteColor].CGColor;
    //    self.tableView.layer.borderWidth = 1.0;
    //    self.tableView.tableFooterView = [UIView new];
    
    self.tableView.tableFooterView = [UIView new];
    
    self.datasourceArray = @[@"Enroll Me",@"Identify"];
    
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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.navigationBar setHidden:NO];
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
        
        //Train a group and Choose image to detect
        [self performSelector:@selector(chooseImage) withObject:nil afterDelay:0.4];
        
    }];
}

- (void)identify:(id)sender {
    
    NSMutableArray *faceIds = [[NSMutableArray alloc] init];
    
    for (PersonFace *obj in _faces) {
        [faceIds addObject:obj.face.faceId];
    }
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"Identifying faces";
    [HUD show: YES];
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:ProjectOxfordFaceSubscriptionKey];
    [client identifyWithPersonGroupId:self.group.groupId faceIds:faceIds maxNumberOfCandidates:1 completionBlock:^(NSArray<MPOIdentifyResult *> *collection, NSError *error) {
        [HUD removeFromSuperview];
        
        [_results removeAllObjects];
        for (MPOIdentifyResult * idRestult in collection) {
            
            PersonFace * face = [self getFaceByFaceId:idRestult.faceId];
            
            for (MPOCandidate * candidate in idRestult.candidates) {
                GroupPerson * person = [self getPersonInGroup:self.group withPersonId:candidate.personId];
                
                [_results addObject:@{@"face" : face, @"personName": person.personName, @"confidence" : candidate.confidence}];
                
                [[AppUtility sharedInstance] presentWelcomeAlertForName:person.personName onController:self];
                
                //  [CommonUtil showSimpleHUD:[NSString stringWithFormat:@"Name :- %@",person.personName] forController:self.navigationController];
            }
        }
        
        if (collection.count == 0) {
            [CommonUtil showSimpleHUD:@"Please register first" forController:self.navigationController];
        }
        
    }];
}

- (PersonFace*) getFaceByFaceId: (NSString*) faceId {
    for (PersonFace * face in _faces) {
        if ([face.face.faceId isEqualToString:faceId]) {
            return face;
        }
    }
    return nil;
}

- (GroupPerson*) getPersonInGroup:(PersonGroup*)group withPersonId: (NSString*) personId {
    for (GroupPerson * person in group.people) {
        if ([person.personId isEqualToString:personId]) {
            return person;
        }
    }
    return nil;
}

- (void)chooseImage{
    
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"Select Image" message:@"Select an image to Identify" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"Select from album" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pickImage];
    }]];
    
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"Take a photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self snapImage];
    }]];
    
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alertCtrl animated:YES completion:^{
        
    }];
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

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage * image;
    if (info[UIImagePickerControllerEditedImage]) {
        image = info[UIImagePickerControllerEditedImage];
    } else {
        image = info[UIImagePickerControllerOriginalImage];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    HUD.labelText = @"detecting faces";
    [HUD show: YES];
    
    MPOFaceServiceClient *client = [[MPOFaceServiceClient alloc] initWithSubscriptionKey:ProjectOxfordFaceSubscriptionKey];
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    [client detectWithData:data returnFaceId:YES returnFaceLandmarks:YES returnFaceAttributes:@[] completionBlock:^(NSArray<MPOFace *> *collection, NSError *error) {
        [HUD removeFromSuperview];
        if (error) {
            
        }
        [_faces removeAllObjects];
        for (MPOFace *face in collection) {
            UIImage *croppedImage = [image crop:CGRectMake(face.faceRectangle.left.floatValue, face.faceRectangle.top.floatValue, face.faceRectangle.width.floatValue, face.faceRectangle.height.floatValue)];
            PersonFace *obj = [[PersonFace alloc] init];
            obj.image = croppedImage;
            obj.face = face;
            [_faces addObject:obj];
        }
        
        if (_faces.count > 0) {
            [self identify:nil];
        }else{
            [CommonUtil showSimpleHUD:@"NO Faces Found" forController:self];
        }
        
    }];
}
- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    NSDictionary *dict = [NSDictionary dictionaryWithObject:image forKey:@"UIImagePickerControllerOriginalImage"];
    [self imagePickerController:picker didFinishPickingMediaWithInfo:dict];
}


//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//    if (!error){
//        UIAlertView *av=[[UIAlertView alloc] initWithTitle:nil message:@"Image written to photo album" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [av show];
//    }else{
//        UIAlertView *av=[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Error writing to photo album: %@",[error localizedDescription]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [av show];
//    }
//}

- (IBAction)registerBtnTapped:(id)sender {
    [self performSegueWithIdentifier:KRegistrationViewController sender:nil];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:KRegistrationViewController]) {
        RegistrationViewController *registVC = (RegistrationViewController *)segue.destinationViewController;
        registVC.group = self.group;
        registVC.delegate = self;
    }else if ([segue.identifier isEqualToString:@"IdentifyFaces"]){
        
    }
    
}

-(void)trainGroupAfterUserRegistered{
    
    [self trainGroup:NO];
}

#pragma mark - TableView Datasource
#pragma mark

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datasourceArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contentCell"];
    cell.lblName.text = self.datasourceArray[indexPath.row];
    cell.imgIcon.tintColor = [UIColor whiteColor];
    
    switch (indexPath.row) {
        case 0:
            cell.imgIcon.image = [UIImage imageNamed:@"add_people"];
            break;
        case 1:
            cell.imgIcon.image = [UIImage imageNamed:@"identify"];
            break;
            
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:KRegistrationViewController sender:nil];
            break;
        case 1:
            [self chooseImage];
            break;
        default:
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

@end

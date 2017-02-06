//
//  WelcomePersonViewController.m
//  DPCognitiveRecognitionDemo
//
//  Created by ITSOPMOBILEISR8 on 13/01/17.
//  Copyright © 2017 ITSOPMOBILEISR8. All rights reserved.
//

#import "WelcomePersonViewController.h"

@interface WelcomePersonViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *lblName;

@end

@implementation WelcomePersonViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.imageView.image = self.personImage;
    self.lblName.text = self.personName;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

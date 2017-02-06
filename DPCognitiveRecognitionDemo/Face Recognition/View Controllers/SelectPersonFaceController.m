// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license.
//
// Microsoft Cognitive Services (formerly Project Oxford): https://www.microsoft.com/cognitive-services
//
// Microsoft Cognitive Services (formerly Project Oxford) GitHub:
// https://github.com/Microsoft/Cognitive-Face-iOS
//
// Copyright (c) Microsoft Corporation
// All rights reserved.
//
// MIT License:
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "SelectPersonFaceController.h"
#import <ProjectOxfordFace/MPOFaceServiceClient.h>
#import "MBProgressHUD.h"
#import "PersonFace.h"
#import "CommonUtil.h"
#import "AppDelegate.h"

@interface SelectPersonFaceController () <UICollectionViewDelegate,UICollectionViewDataSource,UIAlertViewDelegate> {
    NSInteger _selectedIndex;
}

@property (strong, nonatomic) IBOutlet UICollectionView *facescollectionView;

@end

@implementation SelectPersonFaceController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Add face";
    _selectedIndex = -1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.detectedFaces == nil) {
        return 0;
    }
    return self.detectedFaces.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:111];
    [imgView setImage:[(PersonFace*)self.detectedFaces[indexPath.row] image]];
    
    return cell;
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 
    _selectedIndex = indexPath.row;
    
    if ([self.delegate respondsToSelector:@selector(selectPersonSelectedFace:fromImage:)]) {
        [self.delegate selectPersonSelectedFace:_detectedFaces[_selectedIndex] fromImage:self.selectedImage];
    }
}

@end

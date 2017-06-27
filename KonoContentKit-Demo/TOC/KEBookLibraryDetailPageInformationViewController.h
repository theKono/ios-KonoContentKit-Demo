//
//  KEBookLibraryDetailPageInformationViewController.h
//  Kono
//
//  Created by Neo on 5/12/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KEBookLibraryDetailPageInformationViewController : UIViewController


- (void)initWithiPad;

- (void)initDisplayContent:(NSString *)magazineIssueStr withMagazineInfo:(NSAttributedString *)magazineInfoStr;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UITextView *descriptionLabel;


@property (weak, nonatomic) IBOutlet UIButton *dismissBtn;

@end

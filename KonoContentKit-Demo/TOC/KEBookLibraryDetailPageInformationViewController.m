//
//  KEBookLibraryDetailPageInformationViewController.m
//  Kono
//
//  Created by Neo on 5/12/14.
//  Copyright (c) 2014 Kono. All rights reserved.
//

#import "KEBookLibraryDetailPageInformationViewController.h"
#import <MZFormSheetController.h>

@interface KEBookLibraryDetailPageInformationViewController ()

@end

@implementation KEBookLibraryDetailPageInformationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.descriptionLabel.showsVerticalScrollIndicator = YES;
    // Do any additional setup after loading the view.
    if( DEVICE_IS_IPAD ){
        [self initWithiPad];
    }
    else{
        [self.descriptionLabel mas_updateConstraints:^(MASConstraintMaker *make){
            make.top.equalTo( self.titleLabel.mas_bottom ).with.offset(10);
        }];
    }
        
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    [self.descriptionLabel scrollRectToVisible:CGRectMake(0, 0, self.descriptionLabel.frame.size.width, self.descriptionLabel.frame.size.height) animated:NO];
    
}

- (void)initWithiPad{
    
    
    [self.titleLabel removeFromSuperview];
    [self.dismissBtn removeFromSuperview];
    [self.descriptionLabel mas_updateConstraints:^(MASConstraintMaker *make){
        make.top.equalTo( self.view.mas_top ).with.offset(34);
    }];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 45, 30)];
    
    [button setTitle:@"ok" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:18];
    button.titleLabel.numberOfLines = 1;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.lineBreakMode = NSLineBreakByClipping;
    
    [button setTitleColor:[UIColor colorWithRed:0.341 green:0.31 blue:0.223 alpha:1.000] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.710 green:0.678 blue:0.592 alpha:1.0] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor colorWithRed:0.831 green:0.812 blue:0.756 alpha:1.0] forState:UIControlStateDisabled];
    [button addTarget:self action:@selector(dismissBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)initDisplayContent:(NSString *)magazineIssueStr withMagazineInfo:(NSAttributedString *)magazineInfoStr{
    
    if( DEVICE_IS_IPAD ){
        
        self.navigationItem.title = magazineIssueStr;
        self.descriptionLabel.attributedText = magazineInfoStr;
        
    }
    else{
        self.titleLabel.text = magazineIssueStr;
        self.descriptionLabel.attributedText = magazineInfoStr;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)dismissBtnPressed:(id)sender {

    [self dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        
    }];
    
}


@end

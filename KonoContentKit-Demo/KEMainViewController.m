//
//  KEMainViewController.m
//  KonoContentKit-Demo
//
//  Created by kuokuo on 2017/7/6.
//  Copyright © 2017年 kono. All rights reserved.
//

#import "KEAPIResultViewController.h"
#import "KonoViewerDemoViewController.h"
#import "KEBookLibraryTitleViewController.h"
#import "KEMainViewController.h"

@interface KEMainViewController ()

@end

@implementation KEMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initTabBarViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - init related function

- (void)initTabBarViewController {
    
    [self setViewControllers:@[[self getNavigationControllerForIndex:KETabItemContentKit],
                               [self getNavigationControllerForIndex:KETabItemViewerDemo]]];
    
    NSArray *tabBarNormalImageArray, *tabBarSelectedImageArray , *tabBarTitleArray;
    
    tabBarNormalImageArray = @[@"btn_tab_menu_library_normal",@"btn_tab_menu_mykono_normal"];
    tabBarSelectedImageArray = @[@"btn_tab_menu_library_selected",@"btn_tab_menu_mykono_selected"];
    tabBarTitleArray = @[@"Content-Kit",@"Viewer-Demo"];
    
    for (int i=0 ; i< [tabBarTitleArray count] ; i++) {
        
        UITabBarItem *item = self.tabBar.items[i];
        
        UIImage *image = [UIImage imageNamed:tabBarNormalImageArray[i]];
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        UIImage *selectedImage = [UIImage imageNamed:tabBarSelectedImageArray[i]];
        selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        item.title = tabBarTitleArray[i];
        item.image = image;
        item.selectedImage = selectedImage;
        
        CGFloat offset = -3;
        CGFloat fontSize = 11;
        
        [item setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName: [UIColor colorWithRed:181/255.0 green:173/255.0 blue:151/255.0 alpha:1.0] } forState:UIControlStateNormal];
        [item setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize], NSForegroundColorAttributeName: [UIColor colorWithRed:87.0/255.0 green:79.0/255.0 blue:57.0/255.0 alpha:1.0] } forState:UIControlStateSelected];
        item.titlePositionAdjustment = UIOffsetMake(0, offset);
    }
    
    [self setSelectedIndex:KETabItemContentKit];
    [self.view layoutIfNeeded];
    
}


- (UINavigationController *)getNavigationControllerForIndex:(KETabItemIndex)index {
    
    UINavigationController *tabItemViewController;
    
    switch (index) {
        case KETabItemContentKit: {
            KEBookLibraryTitleViewController *titleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"KEBookLibraryTitleViewController"];
            tabItemViewController = [[UINavigationController alloc] initWithRootViewController:titleViewController];
            break;
        }
        case KETabItemViewerDemo: {
            KonoViewerDemoViewController *titleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"KEAPIResultViewController"];
            tabItemViewController = [[UINavigationController alloc] initWithRootViewController:titleViewController];
            break;
        }
        default:
            break;
    }
    
    return tabItemViewController;
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

//
//  DSDetailViewController.h
//  ItemTags
//
//  Created by Dan Shelly on 8/6/2014.
//  Copyright (c) 2014 SO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end

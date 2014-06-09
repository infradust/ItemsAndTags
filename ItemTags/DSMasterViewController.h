//
//  DSMasterViewController.h
//  ItemTags
//
//  Created by Dan Shelly on 8/6/2014.
//  Copyright (c) 2014 SO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DSDetailViewController;

#import <CoreData/CoreData.h>

@interface DSMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DSDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

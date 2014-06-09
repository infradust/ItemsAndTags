//
//  DSMasterViewController.m
//  ItemTags
//
//  Created by Dan Shelly on 8/6/2014.
//  Copyright (c) 2014 SO. All rights reserved.
//

#import "DSMasterViewController.h"

#import "DSDetailViewController.h"

@interface DSMasterViewController ()
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation DSMasterViewController

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (NSExpressionDescription*) rankingExpressionDescriptionForTags:(NSSet*)tags
{
    NSPredicate* p2 = [NSPredicate predicateWithFormat:@"SUBQUERY(tags,$t,$t IN %@).@count > 0",tags];
    NSExpression* rankExpresion = [(NSComparisonPredicate*)p2 leftExpression];
    NSExpressionDescription* rankExpDesc = [[NSExpressionDescription alloc] init];
    rankExpDesc.name = @"ranking";
    rankExpDesc.expression = rankExpresion;
    rankExpDesc.expressionResultType = NSInteger64AttributeType;
    return rankExpDesc;
}

- (NSExpressionDescription*) objectIDExpressionDescription
{
    NSExpressionDescription* expDesc = [[NSExpressionDescription alloc] init];
    expDesc.name = @"objectID";
    expDesc.expressionResultType = NSObjectIDAttributeType;
    expDesc.expression = [NSExpression expressionForEvaluatedObject];
    return expDesc;
}

- (NSFetchRequest*) rankingRequestForItem:(NSManagedObject*)item
{
    NSFetchRequest* r = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    NSPredicate* p = [NSPredicate predicateWithFormat:@"SELF != %@",item.objectID];
    r.resultType = NSDictionaryResultType;
    r.propertiesToFetch = @[[self objectIDExpressionDescription],
                            @"name",
                            [self rankingExpressionDescriptionForTags:[item mutableSetValueForKey:@"tags"]]];
    r.predicate = p;
    r.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    return r;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailViewController = (DSDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    self.detailViewController.detailItem = object;
}

#pragma mark - Fetched results controller

- (NSManagedObject*) selectRandomItem
{
    NSFetchRequest* r = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    NSArray* items = [self.managedObjectContext executeFetchRequest:r error:nil];
    
    if (!items || ![items count]) {
        exit(-1);
    }
    
    return items[arc4random()%[items count]];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSManagedObject* randomItem = [self selectRandomItem];
    NSLog(@"selected item:\n%@",randomItem);
    NSFetchRequest *fetchRequest = [self rankingRequestForItem:randomItem];
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",[object valueForKey:@"name"],[object valueForKey:@"ranking"]];
}

@end

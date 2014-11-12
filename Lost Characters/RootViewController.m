//
//  ViewController.m
//  Lost Characters
//
//  Created by CHRISTINA GUNARTO on 11/11/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"
#import "EditCharacterViewController.h"
#import "PassengerTableViewCell.h"

@interface RootViewController () <UITableViewDelegate, UITableViewDataSource>

@property NSManagedObjectContext *moc;
@property NSMutableArray *characters;
@property NSArray *lostPlistArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic,strong) IBOutlet UIBarButtonItem *editButton;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *deleteButton;
@property (nonatomic,strong) IBOutlet UIBarButtonItem *addButton;



@end

@implementation RootViewController

#pragma mark View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    self.moc = delegate.managedObjectContext;

    [self savePlistToCoreData];
    [self updateButtonsToMatchTableState];
}


- (void)viewDidAppear:(BOOL)animated
{
    [self retrieveCharacterAndSortByName];
    [self.tableView reloadData];
}


#pragma mark Helper Methods

- (void)retrieveCharacterAndSortByName
{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Character"];
    self.characters = [[self.moc executeFetchRequest:request error:&error]mutableCopy];

    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[sortByName];
}

//Get initial information from pList and populate core datat with it if empty
- (void)savePlistToCoreData
{
    [self retrieveCharacterAndSortByName];

    //if core data is empty, pre-populate it with the information from the pList
    if (self.characters.count == 0)
    {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *lostPath = [path stringByAppendingPathComponent:@"lost.plist"];
        self.lostPlistArray = [NSArray arrayWithContentsOfFile:lostPath];

        for (NSDictionary *d in self.lostPlistArray)
        {
            NSManagedObject *character = [NSEntityDescription insertNewObjectForEntityForName:@"Character"
                                                                       inManagedObjectContext:self.moc];
            [character setValue:d[@"passenger"] forKey:@"name"];
            [character setValue:d[@"actor"] forKey:@"actor"];
            [self.moc save:nil];
        }

    [self retrieveCharacterAndSortByName];
    }
    [self.tableView reloadData];
}

#pragma mark UITableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.characters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *character = self.characters[indexPath.row];
    PassengerTableViewCell *passengerCell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    passengerCell.nameLabel.text = [character valueForKey:@"name"];
    passengerCell.actorNameLabel.text = [character valueForKey:@"actor"];
    passengerCell.occupationLabel.text = [character valueForKey:@"occupation"];
    passengerCell.seatLabel.text = [character valueForKey:@"seatNumber"];
    passengerCell.genderLabel.text = [character valueForKey:@"gender"];

    NSData *imageData = [character valueForKey:@"image"];
    passengerCell.profileImageView.image =  [UIImage imageWithData:imageData];

    NSString *ageString = [NSString stringWithFormat:@"%@",[character valueForKey:@"age"]];
    passengerCell.ageLabel.text = ageString;
    return passengerCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSManagedObject *characterToDelete = self.characters[indexPath.row];
        [self.moc deleteObject:characterToDelete];
        [self.moc save:nil];

        [self retrieveCharacterAndSortByName];
        [self.tableView reloadData];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"SMOKE MONSTER";
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Update the delete button's title based on how many items are selected.
    [self updateDeleteButtonTitle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateButtonsToMatchTableState];

}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    EditCharacterViewController *editCharacterVC = segue.destinationViewController;
    editCharacterVC.moc = self.moc;

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSManagedObject *chosenCharacter = self.characters[indexPath.row];
    editCharacterVC.chosenCharacter = chosenCharacter;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if (self.tableView.editing == YES)
    {
        return NO;
    }
    return YES;
}


#pragma mark Button Presses

- (IBAction)onEditButtonPressed:(UIBarButtonItem *)sender
{
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    [self.tableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)onCancelButtonPressed:(UIBarButtonItem *)sender
{
    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)onDeleteButtonPressed:(UIBarButtonItem *)sender
{
    NSString *actionTitle;
    if (([[self.tableView indexPathsForSelectedRows] count] == 1)) {
        actionTitle = NSLocalizedString(@"Are you sure you want to remove this item?", @"");
    }
    else
    {
        actionTitle = NSLocalizedString(@"Are you sure you want to remove these items?", @"");
    }

    NSString *cancelTitle = NSLocalizedString(@"Cancel", @"Cancel title for item removal action");
    NSString *okTitle = NSLocalizedString(@"OK", @"OK title for item removal action");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:actionTitle
                                                             delegate:self
                                                    cancelButtonTitle:cancelTitle
                                               destructiveButtonTitle:okTitle
                                                    otherButtonTitles:nil];

    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;

    // Show from our table view (pops up in the middle of the table).
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // The user tapped one of the OK/Cancel buttons.
    if (buttonIndex == 0)
    {
        // Delete what the user selected.
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];

        for (NSIndexPath *indexPath in selectedRows)
        {
            NSManagedObject *characterToDelete = self.characters[indexPath.row];
            [self.moc deleteObject:characterToDelete];
            [self.moc save:nil];
        }

        BOOL deleteSpecificRows = selectedRows.count > 0;
        if (deleteSpecificRows)
        {
            // Build an NSIndexSet of all the objects to delete, so they can all be removed at once.
            NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedRows)
            {
                [indicesOfItemsToDelete addIndex:selectionIndex.row];
            }
            // Delete the objects from our data model.
            [self.characters removeObjectsAtIndexes:indicesOfItemsToDelete];

            // Tell the tableView that we deleted the objects
            [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        else
        {
            // Delete everything, delete the objects from our data model.
            for (int i = 0; i < self.characters.count; i++)
            {
                NSManagedObject *characterToDelete = self.characters[i];
                [self.moc deleteObject:characterToDelete];
                [self.moc save:nil];
            }
            [self.characters removeAllObjects];

            // Tell the tableView that we deleted the objects.
            // Because we are deleting all the rows, just reload the current table section
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }

        // Exit editing mode after the deletion.
        [self.tableView setEditing:NO animated:YES];
        [self updateButtonsToMatchTableState];
    }
}


- (IBAction)onPlusButtonPressed:(UIBarButtonItem *)sender
{
    if ([self.textField.text isEqualToString:@""])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Field is empty"
                                                                       message:@"Please enter a valid name"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okButton];
        [self presentViewController:alert
                           animated:YES
                         completion:nil];
    }

    else
    {
        NSManagedObject *character = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:self.moc];
        [character setValue:self.textField.text forKey:@"name"];
        [self.moc save:nil];

        [self retrieveCharacterAndSortByName];
        self.textField.text = @"";
        [self.tableView reloadData];
    }
}

#pragma mark Filtering Buttons

//Filters for Male characters
- (IBAction)onMaleFilterButtonPressed:(UIButton *)sender
{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Character"];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[sortByName];

    request.predicate = [NSPredicate predicateWithFormat:@"gender == 'M'"];

    self.characters = [[self.moc executeFetchRequest:request error:nil]mutableCopy];
    [self.tableView reloadData];
}


//Filers for Female characters
- (IBAction)onFemaleFilterButtonPressed:(UIButton *)sender
{
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Character"];
    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[sortByName];

    request.predicate = [NSPredicate predicateWithFormat:@"gender == 'F'"];

    self.characters = [[self.moc executeFetchRequest:request error:nil]mutableCopy];
    [self.tableView reloadData];
}

- (IBAction)onAllCharactersButtonPressed:(UIButton *)sender
{
    [self retrieveCharacterAndSortByName];
    [self.tableView reloadData];
}


#pragma mark button state

- (void)updateButtonsToMatchTableState
{
    if (self.tableView.editing)
    {
        // Show the option to cancel the edit.
        self.navigationItem.leftBarButtonItem = self.cancelButton;

        [self updateDeleteButtonTitle];

        self.navigationItem.rightBarButtonItem = self.deleteButton;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = self.addButton;
        // Show the edit button, but disable the edit button if there's nothing to edit.
        if (self.characters.count > 0)
        {
            self.editButton.enabled = YES;
        }
        else
        {
            self.editButton.enabled = NO;
        }
        self.navigationItem.leftBarButtonItem = self.editButton;
    }
}

- (void)updateDeleteButtonTitle
{
    // Update the delete button's title, based on how many items are selected
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];

    BOOL allItemsAreSelected = selectedRows.count == self.characters.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;

    if (allItemsAreSelected || noItemsAreSelected)
    {
        self.deleteButton.title = NSLocalizedString(@"Delete All", @"");
    }
    else
    {
        NSString *titleFormatString =
        NSLocalizedString(@"Delete (%d)", @"Title for delete button with placeholder for number");
        self.deleteButton.title = [NSString stringWithFormat:titleFormatString, selectedRows.count];
    }
}



@end

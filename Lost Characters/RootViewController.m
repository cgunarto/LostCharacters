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
@property NSArray *characters;
@property NSArray *lostPlistArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;


@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    self.moc = delegate.managedObjectContext;

    self.tableView.allowsMultipleSelectionDuringEditing = NO;

    [self savePlistToCoreData];

}

- (void)viewDidAppear:(BOOL)animated
{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Character"];
    self.characters = [self.moc executeFetchRequest:request error:&error];

    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[sortByName];

    [self.tableView reloadData];
}

- (void)savePlistToCoreData
{
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Character"];
    self.characters = [self.moc executeFetchRequest:request error:&error];

    NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[sortByName];

    //if core data is empty, pre-populate it with the information from the pList
    if (self.characters.count == 0)
    {
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSString *lostPath = [path stringByAppendingPathComponent:@"lost.plist"];
        self.lostPlistArray = [NSArray arrayWithContentsOfFile:lostPath];

        for (NSDictionary *d in self.lostPlistArray)
        {
            NSManagedObject *character = [NSEntityDescription insertNewObjectForEntityForName:@"Character" inManagedObjectContext:self.moc];
            [character setValue:d[@"passenger"] forKey:@"name"];
            [character setValue:d[@"actor"] forKey:@"actor"];
            [self.moc save:nil];
        }
        self.characters = [self.moc executeFetchRequest:request error:&error];
        request.sortDescriptors = @[sortByName];

    }

    [self.tableView reloadData];
}

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

        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Character"];
        NSError *error;
        self.characters = [self.moc executeFetchRequest:request error:&error];

        NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        request.sortDescriptors = @[sortByName];

        [self.tableView reloadData];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"SMOKE MONSTER";
}

#pragma mark Add Character

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

        NSFetchRequest *request = [[NSFetchRequest alloc]initWithEntityName:@"Character"];
        self.characters = [self.moc executeFetchRequest:request error:nil];

        NSSortDescriptor *sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        request.sortDescriptors = @[sortByName];

        self.textField.text = @"";
        [self.tableView reloadData];
    }
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




@end

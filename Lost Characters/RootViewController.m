//
//  ViewController.m
//  Lost Characters
//
//  Created by CHRISTINA GUNARTO on 11/11/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"


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

    [self loadCharactersArray];

}

- (void)loadCharactersArray
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    cell.textLabel.text = [character valueForKey:@"name"];
    cell.detailTextLabel.text = [character valueForKey:@"actor"];

    return cell;
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
    }
}




@end

//
//  EditCharacterViewController.m
//  Lost Characters
//
//  Created by CHRISTINA GUNARTO on 11/11/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "EditCharacterViewController.h"

@interface EditCharacterViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *ageTextField;
@property (weak, nonatomic) IBOutlet UITextField *seatTextField;
@property (weak, nonatomic) IBOutlet UITextField *genderTextField;
@property (weak, nonatomic) IBOutlet UITextField *occupationTextField;
@property (weak, nonatomic) IBOutlet UITextField *actorNameTextField;

@end

@implementation EditCharacterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setCharacterLabelInfo];
    [self disableAllTextFieldEditing];
}

- (void)setCharacterLabelInfo
{
    NSString *characterName = [self.chosenCharacter valueForKey:@"name"];
    self.nameTextField.placeholder = characterName;
    self.nameTextField.text = characterName;
    [self setTitle:characterName];

    if ([self.chosenCharacter valueForKey:@"seatNumber"] != nil)
    {
        self.seatTextField.text = [self.chosenCharacter valueForKey:@"seatNumber"];
    }
    if ([self.chosenCharacter valueForKey:@"age"] != nil)
    {
        self.ageTextField.text = [NSString stringWithFormat:@"%@",[self.chosenCharacter valueForKey:@"age"]];
    }
    if ([self.chosenCharacter valueForKey:@"gender"] != nil)
    {
        self.genderTextField.text = [self.chosenCharacter valueForKey:@"gender"];
    }
    if ([self.chosenCharacter valueForKey:@"actor"] != nil)
    {
        self.actorNameTextField.text = [self.chosenCharacter valueForKey:@"actor"];
    }
    if ([self.chosenCharacter valueForKey:@"occupation"] != nil)
    {
        self.occupationTextField.text = [self.chosenCharacter valueForKey:@"occupation"];
    }
}

- (IBAction)onEditButtonPressed:(UIBarButtonItem *)sender
{
    self.nameTextField.enabled = !self.nameTextField.enabled;
    self.ageTextField.enabled = !self.ageTextField.enabled;
    self.seatTextField.enabled = !self.seatTextField.enabled;
    self.genderTextField.enabled = !self.genderTextField.enabled;
    self.occupationTextField.enabled = !self.occupationTextField.enabled;
    self.actorNameTextField.enabled = !self.actorNameTextField.enabled;
}

- (void)disableAllTextFieldEditing
{
    self.nameTextField.enabled = NO;
    self.ageTextField.enabled = NO;
    self.seatTextField.enabled = NO;
    self.genderTextField.enabled = NO;
    self.occupationTextField.enabled = NO;
    self.actorNameTextField.enabled = NO;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.occupationTextField])
    {
        [self.chosenCharacter setValue:textField.text forKey:@"occupation"];
    }

    [self.moc save:nil];
    return YES;
}




@end

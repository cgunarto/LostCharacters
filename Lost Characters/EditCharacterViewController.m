//
//  EditCharacterViewController.m
//  Lost Characters
//
//  Created by CHRISTINA GUNARTO on 11/11/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "EditCharacterViewController.h"

@interface EditCharacterViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *seatNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *actorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *occupationLabel;

@end

@implementation EditCharacterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setCharacterLabelInfo];
}

- (void)setCharacterLabelInfo
{
    NSString *characterName = [self.chosenCharacter valueForKey:@"name"];
    self.nameLabel.text = characterName;
    [self setTitle:characterName];

    if ([self.chosenCharacter valueForKey:@"seatNumber"] != nil)
    {
        self.seatNumberLabel.text = [self.chosenCharacter valueForKey:@"seatNumber"];
    }
    if ([self.chosenCharacter valueForKey:@"age"] != nil)
    {
        self.ageLabel.text = [NSString stringWithFormat:@"%@",[self.chosenCharacter valueForKey:@"age"]];
    }
    if ([self.chosenCharacter valueForKey:@"gender"] != nil)
    {
        self.genderLabel.text = [self.chosenCharacter valueForKey:@"gender"];
    }
    if ([self.chosenCharacter valueForKey:@"actor"] != nil)
    {
        self.actorNameLabel.text = [self.chosenCharacter valueForKey:@"actor"];
    }
    if ([self.chosenCharacter valueForKey:@"occupation"] != nil)
    {
        self.occupationLabel.text = [self.chosenCharacter valueForKey:@"occupation"];
    }

}


@end

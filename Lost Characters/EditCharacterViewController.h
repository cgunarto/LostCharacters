//
//  EditCharacterViewController.h
//  Lost Characters
//
//  Created by CHRISTINA GUNARTO on 11/11/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


@interface EditCharacterViewController : UIViewController
@property NSManagedObjectContext *moc;
@property NSManagedObject *chosenCharacter;


@end

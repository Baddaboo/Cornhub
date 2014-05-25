//
//  LoginViewController.h
//  Cornhub
//
//  Created by Blake Tsuzaki on 5/24/14.
//  Copyright (c) 2014 Swag. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *loginActivity;
@property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UIImageView *userImageView;

@end

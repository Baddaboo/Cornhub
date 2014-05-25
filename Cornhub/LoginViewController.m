//
//  LoginViewController.m
//  Cornhub
//
//  Created by Blake Tsuzaki on 5/24/14.
//  Copyright (c) 2014 Swag. All rights reserved.
//

#import "LoginViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "UIImage+RoundedImage.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface LoginViewController ()
@property (strong, nonatomic) NSString *ipaddress;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSOperationQueue *queryQueue;
@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.loginActivity setHidden:YES];
    [self.nameField setDelegate:self];
    // Do any additional setup after loading the view.
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://107.170.232.159:9090/?keyword=Obama"]];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!connectionError){
            NSError *error;
            NSObject *val = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSLog(@"Data: %@",val);
        }else{
            NSLog(@"%@",[connectionError localizedDescription]);
        }
    }];
    self.ipaddress = [self GetOurIpAddress];
    self.queryQueue = [[NSOperationQueue alloc] init];
}

- (NSString *)GetOurIpAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}
- (IBAction)textDidChange:(id)sender{ 
    [self.loginActivity setHidden:NO];
    [self.loginActivity startAnimating];
    [self getImage];
}

- (void) getImage{
    [self.queryQueue cancelAllOperations];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=1&imgtype=photo&safe=active&q=%@&userip=%@",[[self.nameField text] stringByReplacingOccurrencesOfString:@" " withString:@"%20"],self.ipaddress]]];
    [NSURLConnection sendAsynchronousRequest:request queue:self.queryQueue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!connectionError && data != nil){
            NSError *error;
            id val = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSLog(@"%@",val);
            if (!error && [[val objectForKey:@"responseStatus"] integerValue] != 403 && val != nil && [[[[val objectForKey:@"responseData"] objectForKey:@"results"] valueForKey:@"url"] count] > 0){
                if (self.urlString != [[[[val objectForKey:@"responseData"] objectForKey:@"results"] valueForKey:@"url"] objectAtIndex:0]){
                    self.urlString = [[[[val objectForKey:@"responseData"] objectForKey:@"results"] valueForKey:@"url"] objectAtIndex:0];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.urlString]];
                            // Update the UI
                            self.userImageView.image = [UIImage imageWithData:imageData];
                            [self.loginActivity stopAnimating];
                            [self.loginActivity setHidden:YES];
                        
                    });
                }
            }else{
                NSLog(@"%@",error);
            }
        }else{
            NSLog(@"%@",[connectionError localizedDescription]);
        }
    }];
}
- (void) getInfo
{
    // Request access to the Twitter accounts
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            
            // Check if the users has setup at least one Twitter account
            
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
                // Creating a request to get the info about a user on Twitter
                
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/users/show.json"] parameters:[NSDictionary dictionaryWithObject:[self.nameField text] forKey:@"screen_name"]];
                [twitterInfoRequest setAccount:twitterAccount];
                
                // Making the request
                
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        // Check if we reached the reate limit
                        
                        if ([urlResponse statusCode] == 429) {
                            NSLog(@"Rate limit reached");
                            return;
                        }
                        
                        // Check if there was an error
                        
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        
                        // Check if there is some response data
                        
                        if (responseData) {
                            
                            NSError *error = nil;
                            NSArray *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            
                            
                            // Filter the preferred data
                            
                            NSString *screen_name = [(NSDictionary *)TWData objectForKey:@"screen_name"];
                            NSString *name = [(NSDictionary *)TWData objectForKey:@"name"];
                            
                            int followers = [[(NSDictionary *)TWData objectForKey:@"followers_count"] integerValue];
                            int following = [[(NSDictionary *)TWData objectForKey:@"friends_count"] integerValue];
                            int tweets = [[(NSDictionary *)TWData objectForKey:@"statuses_count"] integerValue];
                            
                            NSString *profileImageStringURL = [(NSDictionary *)TWData objectForKey:@"profile_image_url_https"];
                            NSString *bannerImageStringURL =[(NSDictionary *)TWData objectForKey:@"profile_banner_url"];
                            
                            NSLog(@"%@: %d followers, %d following, %d tweets", screen_name, followers, following, tweets);
                            
                            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[(NSDictionary *)TWData objectForKey:@"profile_image_url_https"] ]] queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                if(!connectionError){
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self.userImageView setImage:[UIImage roundedImageWithImage:[UIImage imageWithData:data]]];
                                    });
                                }
                            }];
                            // Update the interface with the loaded data
                            /*
                            nameLabel.text = name;
                            usernameLabel.text= [NSString stringWithFormat:@"@%@",screen_name];
                            
                            tweetsLabel.text = [NSString stringWithFormat:@"%i", tweets];
                            followingLabel.text= [NSString stringWithFormat:@"%i", following];
                            followersLabel.text = [NSString stringWithFormat:@"%i", followers];
                            
                            NSString *lastTweet = [[(NSDictionary *)TWData objectForKey:@"status"] objectForKey:@"text"];
                            lastTweetTextView.text= lastTweet;
                            
                            
                            
                            // Get the profile image in the original resolution
                            
                            profileImageStringURL = [profileImageStringURL stringByReplacingOccurrencesOfString:@"_normal" withString:@""];
                            [self getProfileImageForURLString:profileImageStringURL];
                            
                            
                            // Get the banner image, if the user has one
                            
                            if (bannerImageStringURL) {
                                NSString *bannerURLString = [NSString stringWithFormat:@"%@/mobile_retina", bannerImageStringURL];
                                [self getBannerImageForURLString:bannerURLString];
                            } else {
                                bannerImageView.backgroundColor = [UIColor underPageBackgroundColor];
                            }
                             */
 
                        }
                    });
                }];
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
}

- (IBAction)loginButtonPressed:(id)sender {
    [self.loginActivity setHidden:NO];
    [self.loginActivity startAnimating];
    [self.loginActivity stopAnimating];
    [self.loginActivity setHidden:YES];
}
@end

//
//  ChartFinalViewController.m
//  Cornhub
//
//  Created by Blake Tsuzaki on 5/25/14.
//  Copyright (c) 2014 Swag. All rights reserved.
//

#import "ChartFinalViewController.h"
#import "UIColor-MJGAdditions.h"

@interface ChartFinalViewController ()
@property (strong, nonatomic) NSNumber *upValue;
@property (strong, nonatomic) NSNumber *downValue;
@property (strong, nonatomic) NSNumber *neutralValue;
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) NSArray *tweets;
@end

@implementation ChartFinalViewController

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
    // Do any additional setup after loading the view.
    self.upValue = [NSNumber numberWithInt:0];
    self.downValue = [NSNumber numberWithInt:0];
    self.neutralValue = [NSNumber numberWithInt:0];
    //self.pieChart = [[XYPieChart alloc] init];
    [self.pieChart setBackgroundColor:[UIColor clearColor]];
    [self.loadingChart setHidden:NO];
    [self.loadingChart startAnimating];
    [self.pieChart setDelegate:self];
    [self.pieChart setDataSource:self];
    [self.pieChart setAnimationSpeed:0.5];
    [self.pieChart setShowLabel:NO];
    self.keyword = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchKey"];
    [self setTitle:self.keyword];
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[[NSString stringWithFormat:@"http://107.170.232.159/query/?keyword=%@",self.keyword] stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!connectionError){
            NSError *error;
            id val = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            NSLog(@"Data: %@",val);
            if (val == nil){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops." message:@"It looks like the main test server might be down/offline." delegate:self cancelButtonTitle:@"Complain to Aaron" otherButtonTitles: nil];
                [alert show];
            }
            self.upValue = [NSNumber numberWithInt:[[[val objectForKey:@"statistics"] valueForKey:@"positive"] intValue]];
            self.downValue = [NSNumber numberWithInt:[[[val objectForKey:@"statistics"] valueForKey:@"negative"]intValue]];
            self.neutralValue = [NSNumber numberWithInt:[[[val objectForKey:@"statistics"] valueForKey:@"neutral"]intValue]];
            self.tweets = [val objectForKey:@"tweets"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowTweets" object:self.tweets];
            [self.loadingChart stopAnimating];
            [self.loadingChart setHidden:YES];
            [self.pieChart reloadData];
        }else{
            NSLog(@"%@",[connectionError localizedDescription]);
        }
    }];
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [aFlowLayout setItemSize:CGSizeMake(300, 100)];
    [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [aFlowLayout setHeaderReferenceSize:CGSizeMake(10, 400)];
    [aFlowLayout setFooterReferenceSize:CGSizeMake(10, 20)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleLayer:) name:@"ToggleLayer" object:nil];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    self.tweetView = [[TweetView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height) collectionViewLayout:aFlowLayout];
    [self.tweetView setDelegate:self.tweetView];
    [self.tweetView setDataSource:self.tweetView];
    [self.tweetView setShowsVerticalScrollIndicator:NO];
    [self.tweetView reloadData];
    [self.tweetView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tweetView];
    [self.view sendSubviewToBack:self.tweetView];
}

- (void)toggleLayer:(NSNotification *)notification{
    if ([[notification object] intValue] == 1){
        [self.view bringSubviewToFront:self.tweetView];
        [self.view sendSubviewToBack:self.pieChart];
    }else{
        [self.view bringSubviewToFront:self.pieChart];
        [self.view sendSubviewToBack:self.tweetView];
        
    }
}

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart{
    return 3;
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index{
    switch (index) {
        case 0:
            return [UIColor colorWithRed:115/255.0 green:255/255.0 blue:0/255.0 alpha:1];
        case 1:
            return [UIColor colorWithRed:255/255.0 green:0/255.0 blue:106/255.0 alpha:1];
        case 2:
            return [UIColor colorWithRed:0/255.0 green:102/255.0 blue:255/255.0 alpha:1];
        default:
            break;
    }
    return [UIColor clearColor];
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index{
    [self.chartLabel setHidden:NO];
    switch (index) {
        case 0:
            return [self.upValue floatValue];
        case 1:
            return [self.downValue floatValue];
        case 2:
            return [self.neutralValue floatValue];
        default:
            break;
    }
    return 0.0;
}
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index{
    switch (index) {
        case 0:
            [self.chartLabel setTextColor:[UIColor colorWithRed:115/255.0 green:255/255.0 blue:0/255.0 alpha:1]];
            [self.chartLabel setText:[NSString stringWithFormat:@"%d Positive Tweets",[self.upValue intValue]]];
            break;
        case 1:
            [self.chartLabel setTextColor:[UIColor colorWithRed:255/255.0 green:0/255.0 blue:106/255.0 alpha:1]];
            [self.chartLabel setText:[NSString stringWithFormat:@"%d Negative Tweets",[self.downValue intValue]]];
            break;
        case 2:
            [self.chartLabel setTextColor:[UIColor colorWithRed:0/255.0 green:102/255.0 blue:255/255.0 alpha:1]];
            [self.chartLabel setText:[NSString stringWithFormat:@"%d Neutral Tweets",[self.neutralValue intValue]]];
            break;
        default:
            break;
    }
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

@end

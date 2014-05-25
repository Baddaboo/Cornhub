//
//  ChartViewController.m
//  Cornhub
//
//  Created by Blake Tsuzaki on 5/24/14.
//  Copyright (c) 2014 Swag. All rights reserved.
//

#import "ChartViewController.h"

@interface ChartViewController ()
@property (strong, nonatomic) NSNumber *upValue;
@property (strong, nonatomic) NSNumber *downValue;
@property (strong, nonatomic) NSNumber *neutralValue;
@property (strong, nonatomic) NSArray *colors;
@end

@implementation ChartViewController

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
    
    [self.pieChart setDelegate:self];
    [self.pieChart setDataSource:self];
    [self.pieChart setAnimationSpeed:0.5];
    //[self.pieChart setPieCenter:[self.pieChart center]];
    [self.pieChart setShowPercentage:NO];
    
}

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart{
    return 3;
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index{
    switch (index) {
        case 0:
            return [UIColor colorWithRed:129/255.0 green:195/255.0 blue:29/255.0 alpha:1];
        case 1:
            return [UIColor colorWithRed:250/255.0 green:200/255.0 blue:0/255.0 alpha:1];
        case 2:
            return [UIColor colorWithRed:229/255.0 green:66/255.0 blue:66/255.0 alpha:1];
        default:
            break;
    }
    return [UIColor clearColor];
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index{
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

- (IBAction)upButtonPressed:(id)sender {
    self.upValue = [NSNumber numberWithInt:[self.upValue intValue] + 1];
    [self.pieChart reloadData];
}
- (IBAction)neutralButtonPressed:(id)sender {
    self.downValue = [NSNumber numberWithInt:[self.downValue intValue] + 1];
    [self.pieChart reloadData];
}
- (IBAction)downButtonPressed:(id)sender {
    self.neutralValue = [NSNumber numberWithInt:[self.neutralValue intValue] + 1];
    [self.pieChart reloadData];
}
@end

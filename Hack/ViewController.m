//
//  ViewController.m
//  Hack
//
//  Created by Megan Gebhard on 2/2/16.
//  Copyright © 2016 Megan Gebhard. All rights reserved.
//

#import "ViewController.h"
#import "SearchSpotify.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self addTextField];
    self.view.backgroundColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addTextField{
    // This allocates a label
    UILabel *prefixLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    //This sets the label text
    prefixLabel.text =@"Artist: ";
    // This sets the font for the label
    [prefixLabel setFont:[UIFont boldSystemFontOfSize:14]];
    // This fits the frame to size of the text
    [prefixLabel sizeToFit];

    // This allocates the textfield and sets its frame
    UITextField *textField = [[UITextField  alloc] initWithFrame:
                              CGRectMake(20, 50, 280, 30)];

    // This sets the border style of the text field
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.contentVerticalAlignment =
    UIControlContentVerticalAlignmentCenter;
    [textField setFont:[UIFont boldSystemFontOfSize:12]];

    //Placeholder text is displayed when no text is typed
    textField.placeholder = @"Kygo";

    //Prefix label is set as left view and the text starts after that
    textField.leftView = prefixLabel;

    //It set when the left prefixLabel to be displayed
    textField.leftViewMode = UITextFieldViewModeAlways;

    // Adds the textField to the view.
    [self.view addSubview:textField];

    // sets the delegate to the current class
    textField.delegate = self;
}


// This method is called once we click inside the textField
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"Text field did begin editing");
}

// This method is called once we complete editing
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"Text field ended editing");
//    textField.text
    [SearchSpotify searchSpotifyFollowerCount: textField.text
     completion:^(NSNumber *followerCount) {
         dispatch_async(dispatch_get_main_queue(), ^{
             textField.text = [followerCount stringValue];
         });
     }];
}

// This method enables or disables the processing of return key
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


@end

//
//  ViewController.h
//  CleverRick
//
//  Created by Rick Osborne on 5/18/13.
//  Copyright (c) 2013 rick osborne dot org. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    __weak IBOutlet UITextField *txtApiKey;
    __weak IBOutlet UIButton *btnFetch;
    __weak IBOutlet UILabel *lblSectionCount;
    __weak IBOutlet UILabel *lblStudentCount;
    __weak IBOutlet UILabel *lblStuPerSec;
    __weak IBOutlet UITextView *txtLog;
    __weak IBOutlet UIActivityIndicatorView *spinFetch;
    __weak IBOutlet UIView *viewInputs;
}
- (IBAction)fetchData:(id)sender;

@end

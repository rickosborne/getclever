//
//  ViewController.m
//  CleverRick
//
//  Created by Rick Osborne on 5/18/13.
//  Copyright (c) 2013 rick osborne dot org. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSString *apiUrl, *apiHost, *apiKeyDefault;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    apiKeyDefault = @"DEMO_KEY";
    apiUrl = @"https://api.getclever.com/v1.1/sections";
    apiHost = @"api.getclever.com";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFetchState:(Boolean)isFetching
{
    txtApiKey.enabled = !isFetching;
    btnFetch.enabled = !isFetching;
    viewInputs.alpha = isFetching ? 0.5 : 1.0;
    [viewInputs setUserInteractionEnabled:!isFetching];
    if (isFetching)
    {
        [spinFetch startAnimating];
    }
    else
    {
        [spinFetch stopAnimating];
    }
}

- (IBAction)fetchData:(id)sender
{
    [self setFetchState:YES];
	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:apiUrl]];
	NSURLConnection* conn = [NSURLConnection connectionWithRequest:request delegate:self];
	[conn start];
}

- (NSString *)apiKey
{
    if (txtApiKey.text.length > 0)
    {
        return txtApiKey.text;
    }
    return apiKeyDefault;
}

@end

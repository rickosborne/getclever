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
    NSMutableString *responseData;
}

@end

@implementation ViewController

- (void)logAndLog:(NSString*)message
{
    NSLog(@"%@", message);
    txtLog.text = [NSString stringWithFormat:@"%@\n%@", message, txtLog.text];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    apiKeyDefault = @"DEMO_KEY";
    apiUrl = @"https://api.getclever.com/v1.1/sections";
    apiHost = @"api.getclever.com";
    responseData = [[NSMutableString alloc] init];
    txtLog.text = @"";
}

//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

- (void)setFetchState:(Boolean)isFetching
{
    txtApiKey.enabled = !isFetching;
    btnFetch.enabled = !isFetching;
    viewInputs.alpha = isFetching ? 0.5 : 1.0;
    [viewInputs setUserInteractionEnabled:!isFetching];
    if (isFetching)
    {
        [spinFetch startAnimating];
        responseData = [[NSMutableString alloc] init];
    }
    else
    {
        [spinFetch stopAnimating];
        responseData = nil;
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self logAndLog:[NSString stringWithFormat:@"finished:%d", responseData.length]];
    NSError* error = nil;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    if (error == nil)
    {
        NSInteger secCount = 0, stuCount = 0;
        NSArray* sections = [json valueForKey:@"data"];
        if (sections)
        {
            secCount = sections.count;
            lblSectionCount.text = [NSString stringWithFormat:@"%d", secCount];
            for (NSObject* section in sections)
            {
                NSArray* students = [section valueForKeyPath:@"data.students"];
                if (students)
                {
                    stuCount += students.count;
                }
            }
            lblStudentCount.text = [NSString stringWithFormat:@"%d", stuCount];
            lblStuPerSec.text = [NSString stringWithFormat:@"%.2f", 1.0f * stuCount / secCount];
        }
        else
        {
            [self logAndLog:@"No sections were found"];
        }
    }
    else
    {
        [self logAndLog:[NSString stringWithFormat:@"json error:%@", error]];
    }
    [self setFetchState:NO];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	[self logAndLog:[NSString stringWithFormat:@"%@ didFailWithError:%@", connection.originalRequest.HTTPMethod, error]];
    [self setFetchState:NO];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self logAndLog:[NSString stringWithFormat:@"didReceiveData:%d", data.length]];
	if (data.length > 0)
	{
        [responseData appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self logAndLog:[NSString stringWithFormat:@"didReceiveResponse:"]];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    [self logAndLog:[NSString stringWithFormat:@"didReceiveAuthenticationChallenge"]];
	NSURLCredential* cred = [NSURLCredential credentialWithUser:[self apiKey] password:@"" persistence:NSURLCredentialPersistenceForSession];
	[challenge.sender useCredential:cred forAuthenticationChallenge:challenge];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    [self logAndLog:[NSString stringWithFormat:@"canAuthenticateAgainstProtectionSpace"]];
	return ([protectionSpace.host isEqualToString:apiHost])
    && ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodDefault]);
}


@end

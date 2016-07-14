//
//  ViewController.m
//  CompoundEyeMultiparty
//
//  Created by Charley Robinson on 7/14/16.
//  Copyright © 2016 TokBox, Inc. All rights reserved.
//

#import "ViewController.h"
#import <OpenTok/OpenTok.h>

void otk_enable_webrtc_trace(int);

@interface OpenTokObjC
+ (void)setLogBlockQueue:(dispatch_queue_t)queue;
+ (void)setLogBlock:(void (^)(NSString* message, void* argument))logBlock;
@end

@interface ViewController ()
<OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate>

@end

@implementation ViewController {
    OTSession* _session;
    OTPublisher* _publisher;
    NSMutableArray* _subscribers;
}

// *** Fill the following variables using your own Project info  ***
// ***          https://dashboard.tokbox.com/projects            ***
// Replace with your OpenTok API key
static NSString* const kApiKey = @"100";
// Replace with your generated session ID
static NSString* const kSessionId = @"1_MX4xMDB-fjE0Njg1MzIxODE2OTd-d09VbVZ0dThPRFo2d2oxUDYrc3daekFCfn4";
// Replace with your generated token
static NSString* const kToken = @"T1==cGFydG5lcl9pZD0xMDAmc2RrX3ZlcnNpb249dGJwaHAtdjAuOTEuMjAxMS0wNy0wNSZzaWc9NTMzMjUxMmU3NTQxZDFkYjRhNjA3YjEyZGZiMDViMDA4NmY2OWRkMDpzZXNzaW9uX2lkPTFfTVg0eE1EQi1makUwTmpnMU16SXhPREUyT1RkLWQwOVZiVlowZFRoUFJGbzJkMm94VURZcmMzZGFla0ZDZm40JmNyZWF0ZV90aW1lPTE0Njg1Mjk2Nzgmcm9sZT1tb2RlcmF0b3Imbm9uY2U9MTQ2ODUyOTY3OC44OTUzMTQ5NDMzNzE1MCZleHBpcmVfdGltZT0xNDcxMTIxNjc4";

#pragma mark - View lifecycle

static dispatch_queue_t logQueue;

+ (void)initialize {
    logQueue = dispatch_queue_create("log-queue", DISPATCH_QUEUE_SERIAL);
    //otk_enable_webrtc_trace(0);
    
    [OpenTokObjC setLogBlockQueue:logQueue];
    [OpenTokObjC setLogBlock:^(NSString* message, void* arg) {
        //NSLog(@"%@", message);
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _subscribers = [NSMutableArray new];
    
    // Step 1: As the view comes into the foreground, initialize a new instance
    // of OTSession and begin the connection process.
    _session = [[OTSession alloc] initWithApiKey:kApiKey
                                       sessionId:kSessionId
                                        delegate:self];
    [self doConnect];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UIUserInterfaceIdiomPhone == [[UIDevice currentDevice]
                                      userInterfaceIdiom])
    {
        return NO;
    } else {
        return YES;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self layoutSubscribers];
}

- (void)layoutSubscribers
{
    NSUInteger widgetCount = _subscribers.count;
    if (_publisher.view) {
        widgetCount++;
    }
    int columns = sqrt(widgetCount);
    NSUInteger rows = ceil((float)widgetCount / (float)columns);
    
    int widgetWidth = self.view.frame.size.width / columns;
    int widgetHeight = self.view.frame.size.height / rows;

    int x = 0;
    int y = 0;
    
    // first, handle publisher separately
    [_publisher.view removeFromSuperview];
    [_publisher.view setFrame:CGRectMake(0, 0, widgetWidth, widgetHeight)];
    [self.view addSubview:_publisher.view];
    
    // go to next row, if needed
    if (1 == columns) {
        y++;
    } else {
        x++;
    }
    
    for (OTSubscriber* subscriber in _subscribers) {
        [subscriber.view removeFromSuperview];
        [subscriber.view setFrame:CGRectMake(x * widgetWidth, y * widgetHeight, widgetWidth, widgetHeight)];
        [self.view addSubview:subscriber.view];
        
        // go to next cell
        x++;
        
        // go to next row, if needed
        if (x >= columns) {
            x = 0;
            y++;
        }
    }
}


#pragma mark - OpenTok methods

/**
 * Asynchronously begins the session connect process. Some time later, we will
 * expect a delegate method to call us back with the results of this action.
 */
- (void)doConnect
{
    OTError *error = nil;
    
    [_session connectWithToken:kToken error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
}

/**
 * Sets up an instance of OTPublisher to use with this session. OTPubilsher
 * binds to the device camera and microphone, and will provide A/V streams
 * to the OpenTok session.
 */
- (void)doPublish
{
    _publisher =
    [[OTPublisher alloc] initWithDelegate:self
                                     name:[[UIDevice currentDevice] name]];
    
    OTError *error = nil;
    [_session publish:_publisher error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
    
    [self layoutSubscribers];
}

/**
 * Cleans up the publisher and its view. At this point, the publisher should not
 * be attached to the session any more.
 */
- (void)cleanupPublisher {
    [_publisher.view removeFromSuperview];
    _publisher = nil;
    // this is a good place to notify the end-user that publishing has stopped.
}

/**
 * Instantiates a subscriber for the given stream and asynchronously begins the
 * process to begin receiving A/V content for this stream. Unlike doPublish,
 * this method does not add the subscriber to the view hierarchy. Instead, we
 * add the subscriber only after it has connected and begins receiving data.
 */
- (void)doSubscribe:(OTStream*)stream
{
    OTSubscriber* subscriber =
    [[OTSubscriber alloc] initWithStream:stream delegate:self];
    
    OTError *error = nil;
    [_session subscribe:subscriber error:&error];
    if (error)
    {
        [self showAlert:[error localizedDescription]];
    }
    
    [_subscribers addObject:subscriber];
}

/**
 * Cleans the subscriber from the view hierarchy, if any.
 */
- (void)cleanupStream:(OTStream*)stream
{
    for (OTSubscriber* subscriber in _subscribers)
    {
        if ([stream.streamId isEqualToString:subscriber.stream.streamId])
        {
            [subscriber.view removeFromSuperview];
            [_subscribers removeObject:subscriber];
        }
    }
    
    [self layoutSubscribers];
}

- (void)cleanupConnection:(OTConnection*)connection {
    for (OTSubscriber* subscriber in _subscribers)
    {
        if ([connection.connectionId
             isEqualToString:subscriber.stream.connection.connectionId])
        {
            [subscriber.view removeFromSuperview];
            [_subscribers removeObject:subscriber];
        }
    }
    
    [self layoutSubscribers];
}

# pragma mark - OTSession delegate callbacks

- (void)sessionDidConnect:(OTSession*)session
{
    NSLog(@"sessionDidConnect (%@)", session.sessionId);
    
    // Step 2: We have successfully connected, now instantiate a publisher and
    // begin pushing A/V streams into OpenTok.
    [self doPublish];
}

- (void)sessionDidDisconnect:(OTSession*)session
{
    NSString* alertMessage =
    [NSString stringWithFormat:@"Session disconnected: (%@)",
     session.sessionId];
    NSLog(@"sessionDidDisconnect (%@)", alertMessage);
}


- (void)session:(OTSession*)mySession
  streamCreated:(OTStream *)stream
{
    NSLog(@"session streamCreated (%@)", stream.streamId);

    [self doSubscribe:stream];
}

- (void)session:(OTSession*)session
streamDestroyed:(OTStream *)stream
{
    NSLog(@"session streamDestroyed (%@)", stream.streamId);
    [self cleanupStream:stream];
}

- (void)  session:(OTSession *)session
connectionCreated:(OTConnection *)connection
{
    NSLog(@"session connectionCreated (%@)", connection.connectionId);
}

- (void)    session:(OTSession *)session
connectionDestroyed:(OTConnection *)connection
{
    NSLog(@"session connectionDestroyed (%@)", connection.connectionId);
    [self cleanupConnection:connection];
}

- (void) session:(OTSession*)session
didFailWithError:(OTError*)error
{
    NSLog(@"didFailWithError: (%@)", error);
}

# pragma mark - OTSubscriber delegate callbacks

- (void)subscriberDidConnectToStream:(OTSubscriberKit*)subscriber
{
    NSLog(@"subscriberDidConnectToStream (%@)",
          subscriber.stream.connection.connectionId);
    
    [self layoutSubscribers];
}

- (void)subscriber:(OTSubscriberKit*)subscriber
  didFailWithError:(OTError*)error
{
    NSLog(@"subscriber %@ didFailWithError %@",
          subscriber.stream.streamId,
          error);
}

# pragma mark - OTPublisher delegate callbacks

- (void)publisher:(OTPublisherKit *)publisher
    streamCreated:(OTStream *)stream
{
    // do nothing
}

- (void)publisher:(OTPublisherKit*)publisher
  streamDestroyed:(OTStream *)stream
{
    [self cleanupPublisher];
}

- (void)publisher:(OTPublisherKit*)publisher
 didFailWithError:(OTError*) error
{
    NSLog(@"publisher didFailWithError %@", error);
    [self cleanupPublisher];
}

- (void)showAlert:(NSString *)string
{
    // show alertview on main UI
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"OTError"
                                                        message:string
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil] ;
        [alert show];
    });
}

@end

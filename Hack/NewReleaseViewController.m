#import "NewReleaseViewController.h"
#import <Spotify/Spotify.h>
#import "AppDelegate.h"
#import "ViewController.h"
#import "MusicControlView.h"

@interface NewReleaseViewController () <
                                        SPTAudioStreamingDelegate,
                                        SPTAudioStreamingPlaybackDelegate,
                                        SPTAuthViewDelegate
                                        >
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UILabel *fixedLabel;
@property (nonatomic, strong) NSTimer *timer;
@property MusicControlView *musicControlView;

@end

@implementation NewReleaseViewController

- (void)dealloc
{
    [self.player logout:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"sessionUpdated" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionUpdatedNotification:)
                                                 name:@"sessionUpdated"
                                               object:nil];


    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 100, 0, 200, 200)];

    self.fixedLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, self.imageView.frame.size.height, self.scrollView.frame.size.width, 60)];
    self.fixedLabel.text = [NSString stringWithFormat:@"\"%@\" got released: ", self.artistPageData.newestAlbumName];

    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.fixedLabel.frame.origin.y + 20, self.scrollView.frame.size.width, 100)];
    self.label.lineBreakMode = NSLineBreakByWordWrapping;
    self.label.numberOfLines = 3;
    self.label.textAlignment = NSTextAlignmentCenter;

    self.musicControlView = [[MusicControlView alloc] initWithFrame:self.view.frame];
    self.musicControlView.delegate = self;


    UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:self.artistPageData.albumeImageURL]];

    // Ugly code to resize image
    CGRect rect = CGRectMake(0,0,175,175);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(picture1);
    UIImage *img=[UIImage imageWithData:imageData];

    self.imageView.image = img;

    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    [self.scrollView addSubview:self.fixedLabel];
    [self.scrollView insertSubview:self.label belowSubview:self.imageView];
    [self.scrollView addSubview:self.musicControlView];

    SPTAuth *auth = [SPTAuth defaultInstance];
    if (auth.session && [auth.session isValid]) {
        [self playUsingSession:auth.session];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.timer = \
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(timerTick:)
                                       userInfo:nil
                                        repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.timer invalidate];
    self.timer = nil;
}


-(void) timerTick: (NSTimer *) timer {
    // Get conversion to months, days, hours, minutes, seconds
    NSCalendarUnit unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitSecond;
    NSDateComponents *breakdownInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:self.artistPageData.newestReleaseDate  toDate: [NSDate date]  options:0];

    NSString *countUp = [NSString stringWithFormat: @"%i months : %i days : %i hours : %i minutes : %i seconds \n ago", [breakdownInfo month], [breakdownInfo day], [breakdownInfo hour], [breakdownInfo minute] , [breakdownInfo second]];

    //    NSTimeInterval *addingtime = [now timeIntervalSinceDate:self.artistPageData.newestReleaseDate];
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MM:dd:hh:mm:ss YYYY";
    }
    self.label.text = countUp;

}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)handleNewSession {
    SPTAuth *auth = [SPTAuth defaultInstance];

    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
        self.player.playbackDelegate = self;
        self.player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
    }

    [self.player playURIs:self.artistPageData.trackURIs fromIndex:0 callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** Starting playback got error: %@", error);
            return;
        }
    }];
}

-(void)sessionUpdatedNotification:(NSNotification *)notification {
    if(self.navigationController.topViewController == self) {
        SPTAuth *auth = [SPTAuth defaultInstance];
        if (auth.session && [auth.session isValid]) {
            [self handleNewSession];
        }
    }
}

-(void)playUsingSession:(SPTSession *)session {
    // Create a new player if needed
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:[SPTAuth defaultInstance].clientID];
    }
    if (!self.player.loggedIn) {
        [self.player loginWithSession:session callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Logging in got error: %@", error);
                return;
            }

        [self.player playURIs:self.artistPageData.trackURIs fromIndex:0 callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Starting playback got error: %@", error);
                return;
            }
        }];
        }];
    }
}

#pragma mark MusicControlViewDelegate
- (void) previousClicked: (id) sender {
    [self.player skipPrevious:nil];
}

- (void) playClicked: (id) sender {
    [self.player setIsPlaying:!self.player.isPlaying callback:nil];
    [self.musicControlView setPlayImage:self.player.isPlaying?@"play":@"pause"];
}

- (void) nextClicked: (id) sender {
    [self.player skipNext:nil];
}



#pragma mark - Track Player Delegates

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message {
    NSLog(@"Message from Spotify %@: ", message);
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didFailToPlayTrack:(NSURL *)trackUri {
    NSLog(@"failed to play track: %@", trackUri);
}

- (void) audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata {
    NSLog(@"track changed = %@", [trackMetadata valueForKey:SPTAudioStreamingMetadataTrackURI]);
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    NSLog(@"is playing = %d", isPlaying);
}

#pragma mark SPTAuthViewDelegate

/**
 The user logged in successfully.

 @param authenticationViewController The view controller.
 @param session The session object with the new credentials. (Note that the session object in
	the `SPTAuth` object passed upon initialization is also updated)
 */
- (void) authenticationViewController:(SPTAuthViewController *)authenticationViewController
                  didLoginWithSession:(SPTSession *)session {
    NSLog(@"Successful login");

}

/**
 An error occured while logging in

 @param authenticationViewController The view controller.
 @param error The error (Note that the session object in the `SPTAuth` object passed upon initialization
	is cleared.)
 */
- (void) authenticationViewController:(SPTAuthViewController *)authenticationViewController
                       didFailToLogin:(NSError *)error {
    NSLog(@"Fail login");
}

/**
 User closed the login dialog.
 @param authenticationViewController The view controller.
 */
- (void) authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController {
    NSLog(@"User cancel login");
}



@end

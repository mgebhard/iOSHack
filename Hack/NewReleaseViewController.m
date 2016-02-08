#import "NewReleaseViewController.h"
#import <Spotify/Spotify.h>
#import "AppDelegate.h"

@interface NewReleaseViewController () <
                                        SPTAudioStreamingDelegate,
                                        SPTAudioStreamingPlaybackDelegate,
                                        SPTAuthViewDelegate
                                        >
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;
@end

@implementation NewReleaseViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionUpdatedNotification:)
                                                 name:@"sessionUpdated"
                                               object:nil];

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 175, 175)];
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageView.frame.size.height, self.scrollView.frame.size.width, 100)];
    self.label.text = [[NSString alloc] initWithFormat: @"It has been %f days since \nthe \"%@\" album by %@ \nwhich dropped on %@",
                       self.artistPageData.timeSinceLastRelease,
                       self.artistPageData.newestAlbumName,
                       self.artistPageData.artistName,
                       self.artistPageData.newestReleaseDate];
    self.label.lineBreakMode = NSLineBreakByWordWrapping;
    self.label.numberOfLines = 5;

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
    [self.scrollView insertSubview:self.label belowSubview:self.imageView];


    SPTAuth *auth = [SPTAuth defaultInstance];
    if (auth.session && [auth.session isValid]) {
        [self playUsingSession:auth.session];
    }
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

    [self.player playURIs:@[ self.artistPageData.trackURI ] fromIndex:0 callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** Starting playback got error: %@", error);
            return;
        }
    }];
    NSLog(@"Trying to play: %@", self.artistPageData.trackURI);

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

    [self.player loginWithSession:session callback:^(NSError *error) {
        if (error != nil) {
            NSLog(@"*** Logging in got error: %@", error);
            return;
        }

        [self.player playURIs:@[ self.artistPageData.trackURI ] fromIndex:0 callback:^(NSError *error) {
            if (error != nil) {
                NSLog(@"*** Starting playback got error: %@", error);
                return;
            }
        }];
        NSLog(@"Trying to play: %@", self.artistPageData.trackURI);
    }];
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

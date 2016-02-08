#import "NewReleaseViewController.h"
#import <Spotify/Spotify.h>
#import "AppDelegate.h"

@interface NewReleaseViewController () <SPTAudioStreamingDelegate, SPTAuthViewDelegate>
@property (nonatomic, strong) SPTAudioStreamingController *player;
@end

@implementation NewReleaseViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdatedNotification:) name:@"sessionUpdated" object:nil];

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    scrollView.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 175, 175)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.size.height, scrollView.frame.size.width, 100)];
    label.text = [[NSString alloc] initWithFormat: @"It has been %f days since \nthe \"%@\" album by %@ \nwhich dropped on %@", self.artistPageData.timeSinceLastRelease, self.artistPageData.newestAlbumName, self.artistPageData.artistName, self.artistPageData.newestReleaseDate];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 5;
    NSURL *url = [NSURL URLWithString:self.artistPageData.albumURL];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:data];


    CGRect rect = CGRectMake(0,0,175,175);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *picture1 = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData *imageData = UIImagePNGRepresentation(picture1);
    UIImage *img=[UIImage imageWithData:imageData];
    imageView.image = img;

    [self.view addSubview:scrollView];
    [scrollView addSubview:imageView];
    [scrollView insertSubview:label belowSubview:imageView];

//    self.session = [(AppDelegate *)[[UIApplication sharedApplication] delegate] session];
//    self.player = [(AppDelegate *)[[UIApplication sharedApplication] delegate] player];
//    // Call the -playUsingSession: method to play a track
//    [self playUsingSession:self.session];
    SPTAuth *auth = [SPTAuth defaultInstance];
    if (auth.session && [auth.session isValid]) {
        [self playUsingSession:auth.session];
    }


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
            [self playUsingSession:auth.session];
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
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didFailToPlayTrack:(NSURL *)trackUri {
    NSLog(@"failed to play track: %@", trackUri);
}

- (void) audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata {
    NSLog(@"track changed = %@", [trackMetadata valueForKey:SPTAudioStreamingMetadataTrackURI]);
//    [self updateUI];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying {
    NSLog(@"is playing = %d", isPlaying);
}


@end

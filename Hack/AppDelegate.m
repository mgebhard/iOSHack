#import <Spotify/Spotify.h>
#import "AppDelegate.h"
#import "ViewController.h"
#import "Config.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    UIViewController *vc = [[ViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;

    // Set authentication properties
    SPTAuth *auth = [SPTAuth defaultInstance];
    auth.clientID = @kClientId;
    auth.requestedScopes = @[SPTAuthStreamingScope];
    auth.redirectURL = [NSURL URLWithString:@kCallbackURL];

    #ifdef kTokenSwapServiceURL
        auth.tokenSwapURL = [NSURL URLWithString:@kTokenSwapServiceURL];
    #endif
    #ifdef kTokenRefreshServiceURL
        auth.tokenRefreshURL = [NSURL URLWithString:@kTokenRefreshServiceURL];
    #endif

    auth.tokenRefreshURL = @kSessionUserDefaultsKey;
    
    // Construct a login URL and open it
    NSURL *loginURL = [[SPTAuth defaultInstance] loginURL];

    // Opening a URL in Safari close to application launch may trigger
    // an iOS bug, so we wait a bit before doing so.
    [application performSelector:@selector(openURL:)
                      withObject:loginURL afterDelay:0.1];

    return YES;
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    SPTAuth *auth = [SPTAuth defaultInstance];

    SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
        // This is the callback that'll be triggered when auth is completed (or fails).

        if (error != nil) {
            NSLog(@"*** Auth error: %@", error);
            return;
        }

        auth.session = session;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sessionUpdated" object:self];
    };

    /*
     Handle the callback from the authentication service. -[SPAuth -canHandleURL:]
     helps us filter out URLs that aren't authentication URLs (i.e., URLs you use elsewhere in your application).
     */

    if ([auth canHandleURL:url]) {
        [auth handleAuthCallbackWithTriggeredAuthURL:url callback:authCallback];
        return YES;
    }
    
    return NO;
}
@end
#import "NewReleaseViewController.h"

@implementation NewReleaseViewController
- (void)viewDidLoad {
    [super viewDidLoad];

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

}

@end

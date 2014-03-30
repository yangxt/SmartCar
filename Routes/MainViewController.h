//
//  MainViewController.h
//  Routes
//
//  Created by TomTom on 3/9/12.
//  Copyright (c) 2012 TomTom. All rights reserved.
//

#import <opencv2/highgui/ios.h>
#import <TomTomLBS/TTLBSSDK.h>
#import <MapKit/MapKit.h>
#import <CoreMotion/CoreMotion.h>

@interface MainViewController : UIViewController <TTAPIRoutingDelegate, CLLocationManagerDelegate, CvVideoCameraDelegate>
{
    // This is the View that contains our map
    IBOutlet UIView* mapCanvas;
    
    // This a Text View with the Route Instructions
    // IBOutlet UITextView* instructions;
    
    // This label tells us how long is the route for.
    IBOutlet UILabel *summary;
    
    IBOutlet UITextView *restInstructions;
    IBOutlet UILabel *currentInstructionLabel;
    
    TTUIMapViewController* mapViewController;
    TTAPIRoutingOptionalParameters *params;
    
    CvVideoCamera *videoCamera;
    BOOL isCapturing;
}

@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) IBOutlet UIView *carView;
@property (strong, nonatomic) IBOutlet UIImageView *cameraView;
@property (strong, nonatomic) IBOutlet UIView *navView;

@property (strong, nonatomic) IBOutlet UILabel *routeSummaryLabel;
@property (strong, nonatomic) NSString *latitudeLabel;
@property (strong, nonatomic) NSString *longitudeLabel;

@property (strong, nonatomic) NSNumber *latitudelNumber;
@property (strong, nonatomic) NSNumber *longitudelNumber;

@property (strong, nonatomic) NSString *addressLabel;

@property (nonatomic, strong) IBOutlet UIImageView* imageView;
@property (nonatomic, strong) IBOutlet UIToolbar* toolbar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* startCaptureButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem* stopCaptureButton;

@property (nonatomic) CMMotionManager *motionManager;

// - (void)setInstructionsLabel:(NSString *)text;
- (IBAction)startCaptureButtonPressed:(id)sender;
- (IBAction)stopCaptureButtonPressed:(id)sender;

- (void)updateCurrentInstructionLabel:(NSString *)text;

@end

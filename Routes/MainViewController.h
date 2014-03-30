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
#import <Slt/Slt.h>
#import <Awb8k/Awb8k.h>
#import <OpenEars/FliteController.h>

@interface MainViewController : UIViewController <TTAPIRoutingDelegate, CLLocationManagerDelegate, CvVideoCameraDelegate, UIActionSheetDelegate>
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
    
    FliteController *fliteController;
    Slt *slt;
    Awb8k *awb8k;
    
    CvVideoCamera *videoCamera;
    BOOL isCapturing;
}

@property (strong, nonatomic) FliteController *fliteController;
@property (strong, nonatomic) Slt *slt;
@property (strong, nonatomic) Awb8k *awb8k;

@property (strong, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) IBOutlet UIView *carView;
@property (strong, nonatomic) IBOutlet UIImageView *cameraView;
@property (strong, nonatomic) IBOutlet UIView *navView;

@property (strong, nonatomic) IBOutlet UIImageView *carImageView;
@property (strong, nonatomic) IBOutlet UIImageView *currentLocationImageView;

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
- (IBAction)showSettings:(id)sender;

- (void)updateCurrentInstructionLabel:(NSString *)text;

@end

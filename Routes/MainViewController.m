//
//  MainViewController.m
//  Routes
//
//  Created by TomTom on 3/9/12.
//  Copyright (c) 2012 TomTom. All rights reserved.
//

#import "MainViewController.h"
using namespace cv;

// YOU DEVELOPER'S API KEY ...
#define API_KEY "2qux5nsev48ur3cm6cgn3msk"

@implementation MainViewController {
    CLLocationManager *locationManager;
    NSString *prevFirstInstructionStr;
}

@synthesize fliteController;
@synthesize slt;
@synthesize awb;
@synthesize awb8k;

- (FliteController *)fliteController {
	if (fliteController == nil) {
		fliteController = [[FliteController alloc] init];
	}
	return fliteController;
}

- (Slt *)slt {
	if (slt == nil) {
		slt = [[Slt alloc] init];
	}
	return slt;
}

- (Awb *)awb {
	if (awb == nil) {
		awb = [[Awb alloc] init];
	}
	return awb;
}

- (Awb8k *)awb8k {
	if (awb8k == nil) {
		awb8k = [[Awb8k alloc] init];
	}
	return awb8k;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (isCapturing) {
        [videoCamera stop];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *setDestinationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 123, 32)];
    [setDestinationButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [setDestinationButton setTitle:@"Set Destination" forState:UIControlStateNormal];
    // #define barTintColor [UIColor colorWithRed:(float)70/255 green:(float)122/255 blue:(float)255/255 alpha:1.0]
    setDestinationButton.layer.cornerRadius = 4.0f;
    setDestinationButton.layer.borderColor = [UIColor blueColor].CGColor;
    setDestinationButton.layer.borderWidth = 0.5f;
    setDestinationButton.layer.masksToBounds = YES;
    [setDestinationButton setBackgroundColor:[UIColor colorWithRed:(float)10/255 green:(float)122/255 blue:(float)255/255 alpha:1.0]];
    [setDestinationButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:setDestinationButton];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    self.mapView.layer.cornerRadius = 5.0f;
    self.mapView.layer.masksToBounds = YES;
    self.mapView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.mapView.layer.borderWidth = 0.5f;
    
    self.navView.layer.cornerRadius = 5.0f;
    self.navView.layer.masksToBounds = YES;
    self.navView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.navView.layer.borderWidth = 0.5f;
    
    self.carView.layer.cornerRadius = 5.0f;
    self.carView.layer.masksToBounds = YES;
    self.carView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.carView.layer.borderWidth = 0.5f;
    
    self.cameraView.layer.cornerRadius = 5.0f;
    self.cameraView.layer.masksToBounds = YES;
    self.cameraView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.cameraView.layer.borderWidth = 0.5f;
    
    videoCamera = [[CvVideoCamera alloc]
                        initWithParentView:self.imageView];
    videoCamera.delegate = self;
    videoCamera.defaultAVCaptureDevicePosition =
    AVCaptureDevicePositionBack;
    
    videoCamera.defaultAVCaptureSessionPreset =
    AVCaptureSessionPreset352x288;
    videoCamera.defaultAVCaptureVideoOrientation =
    AVCaptureVideoOrientationPortrait;
    videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    videoCamera.defaultFPS = 5;
    isCapturing = NO;
    
    locationManager = [[CLLocationManager alloc] init];
    
	// Do any additional setup after loading the view, typically from a nib.
    [[TTSDKContext sharedContext] setDeveloperKey:@API_KEY];
    
    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(getCurrentLocationFrequently) userInfo:nil repeats:YES];
    
    [currentInstructionLabel setText:@""];
    self.routeSummaryLabel.hidden = YES;
    [self performSelector:@selector(startCaptureButtonPressed:) withObject:nil afterDelay:1.0f];
    
    // Accident-protection system.
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 1.0;
    self.motionManager.gyroUpdateInterval = 1.0;
    
    // Acceleration
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                                                 [self outputAccelertionData:accelerometerData.acceleration];
                                                 if(error){
                                                     
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
    
    // Rotation
    [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        [self outputRotationData:gyroData.rotationRate];
                                    }];
    
    // Hardware
    [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(getCurrentHardwareInformation) userInfo:nil repeats:YES];
    
    
    // [self.fliteController say:@"Today I am feeling great! Guess what, I am at Hack Princeton!!!" withVoice:self.awb];


}

- (void) getCurrentHardwareInformation {
    // NSLog(@"Fetch data from hardware.");
    NSData *allHardwareData = [[NSData alloc] initWithContentsOfURL:
                               [NSURL URLWithString:@"https://agent.electricimp.com/putVqm5RC6EY"]];
    NSError *error;
    NSDictionary *allHardware = [NSJSONSerialization
                                 JSONObjectWithData:allHardwareData
                                 options:kNilOptions
                                 error:&error];
    NSString *distance = [allHardware objectForKey:@"distance"];
    NSLog(@"Distance: %@", distance);
}

- (void)outputAccelertionData:(CMAcceleration)acceleration
{
    if (fabs(acceleration.x) > 1||fabs(acceleration.x) > 1||fabs(acceleration.x) > 1){
        NSLog(@"Accident!");
    }
    
    // NSLog(@"%@",[NSString stringWithFormat:@" %.2fg",acceleration.x]);
    
}
- (void)outputRotationData:(CMRotationRate)rotation
{
    if (fabs(rotation.x) > 0.3 || fabs(rotation.y) > 0.3 || fabs(rotation.x) > 0.3) {
        NSLog(@"Rotation x: %@", [NSString stringWithFormat:@" %.2f",rotation.x]);
        NSLog(@"Rotation y: %@", [NSString stringWithFormat:@" %.2f",rotation.y]);
        NSLog(@"Rotation z: %@", [NSString stringWithFormat:@" %.2f",rotation.z]);
    }
    
    if (fabs(rotation.y) > 0.1) {
        
        // If rotation.y is negative, then car turns right, otherwise left! (experiment!)  :)
        
        if (rotation.y < 0) {
            
            if ([self.carImageView.layer.animationKeys count] < 1) {
                // Car turns right
                CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                rotateAnimation.fromValue = [NSNumber numberWithFloat:0];
                rotateAnimation.toValue = [NSNumber numberWithFloat:0.5*M_PI / 3];
                rotateAnimation.duration = 0.6f;
                rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                
                rotateAnimation.autoreverses = YES;
                [self.carImageView.layer addAnimation:rotateAnimation forKey:@"rotateCWAnimation"];
            }
            
        } else {
            // Car turns left
            
            if ([self.carImageView.layer.animationKeys count] < 1) {
                CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                rotateAnimation.fromValue = [NSNumber numberWithFloat:0];
                rotateAnimation.toValue = [NSNumber numberWithFloat:-0.5*M_PI / 3];
                rotateAnimation.duration = 0.6f;
                rotateAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                
                rotateAnimation.autoreverses = YES;
                [self.carImageView.layer addAnimation:rotateAnimation forKey:@"rotateCCWAnimation"];
            }
        }
    }
}


- (IBAction)startCaptureButtonPressed:(id)sender
{
    [videoCamera start];
    isCapturing = YES;
}

- (IBAction)stopCaptureButtonPressed:(id)sender
{
    [videoCamera stop];
    isCapturing = NO;
}

- (void)processImage:(cv::Mat&)image
{
    // Do some OpenCV processing with the image
    
    cv::Mat src = image;
    cv::Mat dst, cdst;
    // cv::Canny(src, dst, 50, 200, 3);
    cv::Canny(src, dst, 100, 400, 3);
    cv::cvtColor(dst, cdst, CV_GRAY2BGR);
    
    vector<Vec2f> lines;
    HoughLines(dst, lines, 1, CV_PI/180, 100, 0, 0 );
    
    for( size_t i = 0; i < lines.size(); i++ )
    {
        float rho = lines[i][0], theta = lines[i][1];
        cv::Point pt1, pt2;
        double a = cos(theta), b = sin(theta);
        double x0 = a*rho, y0 = b*rho;
        pt1.x = cvRound(x0 + 1000*(-b));
        pt1.y = cvRound(y0 + 1000*(a));
        pt2.x = cvRound(x0 - 1000*(-b));
        pt2.y = cvRound(y0 - 1000*(a));
        line( src, pt1, pt2, Scalar(0,0,255), 3, CV_AA);
    }

    src.copyTo(image);
}

-(void)setRouteLayer:(TTAPIRoutingData *)route {
    
    /**
     * You can add 2 types of route layers : Tile and Vector based.
     * the following you use when adding a Tile-based router layer.
     */
    //[mapViewController addLayer:[TTAPITileSourceFactory getIntegerRouteTileSource:route]];
    
    // Vector-based route layer.
    TTUIVectorBasedRouteLayer* source = 
    [[TTUIVectorBasedRouteLayer alloc]initForController: mapViewController key: route.summary.routeKey andParameters:params];
    [source setPath: [route getPathData]];
    
    // Let's add our route to the map
    [mapViewController addVectorBasedLayer:source];
    
    source.lineWidth=8;
    source.lineColor = [UIColor greenColor];
    source.outlineColor = [UIColor redColor];
    source.borderThickness = 2;
}

- (void)updateCurrentInstructionLabel:(TTAPIRoutingData *)route
{
    [self performSelectorOnMainThread:@selector(setRouteLayer:) withObject:route waitUntilDone:YES];
    
    NSArray *currentInstructions = [route getInstructions];
    
    NSString *firstInstructionStr = @"";
    TTAPIRouteInstruction *firstInstruction = currentInstructions[0];
    
    if (firstInstruction.text != nil || firstInstruction.roadName != nil) {
        firstInstructionStr = [NSString stringWithFormat:@"%@ %@ %@\n", firstInstructionStr, firstInstruction.text, firstInstruction.roadName] ;
        
        if (![prevFirstInstructionStr isEqualToString:firstInstructionStr]) {
            [self.fliteController say:firstInstructionStr withVoice:self.awb8k];
        }
        
        prevFirstInstructionStr = firstInstructionStr;
        
        self.routeSummaryLabel.hidden = NO;
    }
    
    NSString *restInstructionsStr = @"";
    for (int i = 1; i < [currentInstructions count]; i++) {
        TTAPIRouteInstruction *theInstruction = currentInstructions[i];
        restInstructionsStr = [NSString stringWithFormat:@"%@ - %@ %@\n\n", restInstructionsStr, theInstruction.text, theInstruction.roadName];
    }
    
    route.summary.totalDistanceMeters / 1609.34 > 1 ? [summary setText: [NSString stringWithFormat:@"Summary: %.2f Miles - %d Minutes.", route.summary.totalDistanceMeters / 1609.34, route.summary.totalTimeSeconds / 60]] : [summary setText: [NSString stringWithFormat:@"Summary: %.2f Mile - %d Minutes.", route.summary.totalDistanceMeters / 1609.34, route.summary.totalTimeSeconds / 60]];

    currentInstructionLabel.text = firstInstructionStr;
    
    restInstructions.text = restInstructionsStr;
}
 
// From the TTAPIRoutingDelegate protocol.
// This method will be called when the route data is received.
-(void)handleRoute:(TTAPIRoutingData *)route withPayload:(id)payload {
    
    [self performSelectorOnMainThread:@selector(updateCurrentInstructionLabel:) withObject:route waitUntilDone:YES];
}

- (void)getCurrentLocationFrequently
{
    CGRect mapFrame = CGRectMake(0, 0, mapCanvas.frame.size.width, mapCanvas.frame.size.height);
	mapViewController = [[TTUIMapViewController alloc] initWithFrame: mapFrame andInitialMaxConcurrentOperations: 2];
    
    // NSLog(@"Get current location.");
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = 1.0;
    
    [locationManager startUpdatingLocation];
    
    // Center the map on Paris, France.
    [mapViewController centerOnLatitude:self.latitudelNumber andLongitude:self.longitudelNumber withZoomLevel:15];
    
    // Let's make sure that the Traffic is shown in the new version
    [[TTSDKContext sharedContext] setTileStyle:2];
    
    // Let's add a traffic layer to our map ( Just because we can )
    [mapViewController addLayer:[TTAPITileSourceFactory getIntegerTrafficTileSource]];
    
    // Add the map to the map canvas
	[mapCanvas addSubview:mapViewController.view];
    
    //Let's create a Route.
    TTAPIRouting *routing = [[TTAPIRouting alloc]init];
    
    // Lot 21 latitude and longtitude: 40.344841, -74.645676
    // Lot 28: 40.340756, -74.656755
    // Princeton Metro Park: 40.319850, -74.630568

    TTCoordinates *finalCoordinates = [[TTCoordinates alloc] initWithLatitude:[NSNumber numberWithDouble:40.319850] andLongitude:[NSNumber numberWithDouble:-74.630568]];
    
    TTCoordinates *paris = [[TTCoordinates alloc]initWithLatitude:self.latitudelNumber andLongitude:self.longitudelNumber];
    
    // Ask for the Route
    params =
    [[TTAPIRoutingOptionalParameters alloc]init];
    params.includeDataPath = YES;
    params.dataPathZoomLevel = 17;
    
    [routing getRouteWithStartPoint:paris andEndPoint:finalCoordinates andRouteType:Walk andOptionalParameters:params andNotifyDelegate:self withPayload:nil];
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"didUpdateToLocation: %@", locations[0]);
    CLLocation *currentLocation = locations[0];
    
    if (currentLocation != nil) {
        self.longitudeLabel = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        self.latitudeLabel = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    NSLog(@"longitude: %@", self.longitudeLabel);
    
    self.longitudelNumber = [NSNumber numberWithFloat: currentLocation.coordinate.longitude];
    self.latitudelNumber = [NSNumber numberWithFloat: currentLocation.coordinate.latitude];
}

@end

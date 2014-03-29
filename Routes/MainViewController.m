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

}

- (void)outputAccelertionData:(CMAcceleration)acceleration
{
    if (fabs(acceleration.x) > .1||fabs(acceleration.x) > .1||fabs(acceleration.x) > .1){
        NSLog(@"Accident !");
    }
    // NSLog(@"%@",[NSString stringWithFormat:@" %.2fg",acceleration.x]);
    
}
- (void)outputRotationData:(CMRotationRate)rotation
{
    if (fabs(rotation.x) > 0.1 || fabs(rotation.y) > 0.1 || fabs(rotation.x) > 0.1) {
        NSLog(@"Rotation x: %@", [NSString stringWithFormat:@" %.2f",rotation.x]);
        NSLog(@"Rotation y: %@", [NSString stringWithFormat:@" %.2f",rotation.y]);
        NSLog(@"Rotation z: %@", [NSString stringWithFormat:@" %.2f",rotation.z]);
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
    locationManager.distanceFilter = 0.0;
    
    [locationManager startUpdatingLocation];
    
    // Center the map on Paris, France.
    [mapViewController centerOnLatitude:self.latitudelNumber andLongitude:self.longitudelNumber withZoomLevel:20];
    
    // Let's make sure that the Traffic is shown in the new version
    [[TTSDKContext sharedContext] setTileStyle:2];
    
    // Let's add a traffic layer to our map ( Just because we can )
    [mapViewController addLayer:[TTAPITileSourceFactory getIntegerTrafficTileSource]];
    
    // Add the map to the map canvas
	[mapCanvas addSubview:mapViewController.view];
    
    //Let's create a Route.
    TTAPIRouting *routing = [[TTAPIRouting alloc]init];
    
    //Lot 21 latitude and longtitude: 40.344841, -74.645676
    TTCoordinates *finalCoordinates = [[TTCoordinates alloc] initWithLatitude:[NSNumber numberWithDouble:40.344841] andLongitude:[NSNumber numberWithDouble:-74.645676]];
    
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

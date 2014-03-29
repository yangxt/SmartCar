//
//  MainViewController.m
//  Routes
//
//  Created by TomTom on 3/9/12.
//  Copyright (c) 2012 TomTom. All rights reserved.
//

#import "MainViewController.h"

// YOU DEVELOPER'S API KEY ...
#define API_KEY "2qux5nsev48ur3cm6cgn3msk"

@implementation MainViewController {
    CLLocationManager *locationManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    
	// Do any additional setup after loading the view, typically from a nib.
    [[TTSDKContext sharedContext] setDeveloperKey:@API_KEY];
    
	CGRect mapFrame = CGRectMake(0, 0, mapCanvas.frame.size.width, mapCanvas.frame.size.height);
	mapViewController = [[TTUIMapViewController alloc] initWithFrame: mapFrame andInitialMaxConcurrentOperations: 2];
}

- (void)setInstructionsLabel:(NSString *)text {
    instructions.text = text;    
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
 
// From the TTAPIRoutingDelegate protocol.
// This method will be called when the route data is received.
-(void) handleRoute:(TTAPIRoutingData *)route withPayload:(id)payload{
    
    NSArray *currentInstructions = [route getInstructions];
    NSString *tempString = @"";
    
    summary.text = [NSString stringWithFormat:@"Route: %d meters, %d minutes.",route.summary.totalDistanceMeters, route.summary.totalTimeSeconds/60];
    
    for ( TTAPIRouteInstruction *instruction in currentInstructions ) {
        tempString = [NSString stringWithFormat:@"%@. %@(%@)\n",tempString,instruction.text, instruction.roadName] ;
    }
    
    // The instructions must be updated in the main thread.
    [self performSelectorOnMainThread:@selector(setInstructionsLabel:) withObject:tempString waitUntilDone:YES];
    
    [self performSelectorOnMainThread:@selector(setRouteLayer:) withObject:route waitUntilDone:YES];
}


- (IBAction)getCurrentLocation:(id)sender {
    
    NSLog(@"Get current location.");
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
    
    TTCoordinates *amsterdam = [[TTCoordinates alloc] initWithLatitude:[NSNumber numberWithDouble:40] andLongitude:[NSNumber numberWithDouble:-70]];
    
    TTCoordinates *paris = [[TTCoordinates alloc]initWithLatitude:self.latitudelNumber andLongitude:self.longitudelNumber];
    
    // Ask for the Route
    params =
    [[TTAPIRoutingOptionalParameters alloc]init];
    params.includeDataPath = YES;
    params.dataPathZoomLevel = 17;
    [routing getRouteWithStartPoint:paris andEndPoint:amsterdam andRouteType:Walk andOptionalParameters:params andNotifyDelegate:self withPayload:nil];
    
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

/*
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        self.longitudeLabel = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        self.latitudeLabel = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
    }
    NSLog(@"longitude: %@", self.longitudeLabel);
    
    self.longitudelNumber = [NSNumber numberWithFloat: currentLocation.coordinate.longitude];
    self.latitudelNumber = [NSNumber numberWithFloat: currentLocation.coordinate.latitude];
    
    [self callRouting];
}
 */


@end

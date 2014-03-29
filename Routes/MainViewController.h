//
//  MainViewController.h
//  Routes
//
//  Created by TomTom on 3/9/12.
//  Copyright (c) 2012 TomTom. All rights reserved.
//

#import <TomTomLBS/TTLBSSDK.h>
#import <MapKit/MapKit.h>

@interface MainViewController : UIViewController <TTAPIRoutingDelegate, CLLocationManagerDelegate>
{
    // This is the View that contains our map
    IBOutlet UIView* mapCanvas;
    // This a Text View with the Route Instructions
    IBOutlet UITextView* instructions;
    // This label tells us how long is the route for.
    IBOutlet UILabel *summary;
    
    TTUIMapViewController* mapViewController;
    TTAPIRoutingOptionalParameters *params;
}

- (void)setInstructionsLabel:(NSString *)text;

@property (strong, nonatomic) NSString *latitudeLabel;
@property (strong, nonatomic) NSString *longitudeLabel;

@property (strong, nonatomic) NSNumber *latitudelNumber;
@property (strong, nonatomic) NSNumber *longitudelNumber;

@property (strong, nonatomic) NSString *addressLabel;

- (IBAction)getCurrentLocation:(id)sender;

@end

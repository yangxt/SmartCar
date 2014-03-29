//
//  RMMapContents.h
//
// Copyright (c) 2008-2009, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
#import <UIKit/UIKit.h>

#import "RMFoundation.h"
#import "RMLatLong.h"
#import "RMTile.h"

#import "RMTilesUpdateDelegate.h"


// constants for boundingMask
enum {
	// Map can be zoomed out past view limits
	RMMapNoMinBound			= 0,
	// Minimum map height when zooming out restricted to view height
	RMMapMinHeightBound		= 1,
	// Minimum map width when zooming out restricted to view width ( default )
	RMMapMinWidthBound		= 2
};

#define kDefaultInitialLatitude -33.858771
#define kDefaultInitialLongitude 151.201596

#define kDefaultMinimumZoomLevel 0.0
#define kDefaultMaximumZoomLevel 17.0
#define kDefaultInitialZoomLevel 13.0

@class RMMarkerManager;
@class RMProjection;
@class RMMercatorToScreenProjection;
@class RMTileImageSet;
@class RMTileLoader;
@class RMMapRenderer;
@class RMMapLayer;
@class RMLayerCollection;
@class RMMarker;
@class RMMapView;
@protocol RMMercatorToTileProjection;
@protocol RMTileSource;


@protocol RMMapContentsAnimationCallback <NSObject>
@optional
- (void)animationFinishedWithZoomFactor:(float)zoomFactor near:(CGPoint)p;
@end

/*! \brief The cartographic and data components of a map. Do not retain.
 
 There is exactly one RMMapContents instance for each RMMapView instance.
 
 \warning Do not retain an RMMapContents instance. Instead, ask the RMMapView for its contents 
 when you need it. It is an error for an RMMapContents instance to exist without a view, and 
 if you retain the RMMapContents, it can't go away when the RMMapView is released.
 
 At some point, it's likely that RMMapContents and RMMapView will be merged into one class.
 
 */
@interface RMMapContents : NSObject
{
	/// This is the underlying UIView's layer.
	CALayer *layer;
	
	RMMarkerManager *markerManager;
	/// subview for the image displayed while tiles are loading. Set its contents by providing your own "loading.png".
	RMMapLayer *background;
	/// subview for markers and paths
	RMLayerCollection *overlay;
	
	/// (guess) the projection object to convert from latitude/longitude to meters.
	/// Latlong is calculated dynamically from mercatorBounds.
	RMProjection *projection;
	
	id<RMMercatorToTileProjection> mercatorToTileProjection;
//	RMTileRect tileBounds;
	
	/// (guess) converts from projected meters to screen pixel coordinates
	RMMercatorToScreenProjection *mercatorToScreenProjection;
	
    /**
     * Array of RMTileSource*
    * Controls what images are used. Can be changed while the view is visible, but see http://code.google.com/p/route-me/issues/detail?id=12
     */
	NSMutableArray* tileSources;
	
    /**
     * Array of RMTileImageSet*
     */
	NSMutableArray* imagesOnScreenLayers;
    
    /**
     * Array of RMTileLoader*
     */
	NSMutableArray *tileLoaderArray;
	
	RMMapRenderer *renderer;
	NSUInteger		boundingMask;
	
	/// minimum zoom number allowed for the view. #minZoom and #maxZoom must be within the limits of #tileSource but can be stricter; they are clamped to tilesource limits if needed.
	float minZoom;
	/// maximum zoom number allowed for the view. #minZoom and #maxZoom must be within the limits of #tileSource but can be stricter; they are clamped to tilesource limits if needed.
	float maxZoom;
	
	// Drag Counter for the moving map thingie
	int mapCounter;

	id<RMTilesUpdateDelegate> tilesUpdateDelegate;
	
	RMMapView* mapView;
    
    BOOL imageUpdatesAllowed;
	
	BOOL suppressLoading;
    
    /** It is the maximun number the delay counter must get. Used while
     dragging the map */
    int maxDragCounterValue;
	
	/** Gives route-me the capacity to clear memory on memory warnings **/
	BOOL handleMemoryWarnings;
	/** When route-me receives a memory warning, it will suppress the loading of images **/
	BOOL suppressLoadingOnMemoryWarning;
	/** When route-me receives a memory warning, it will perform a clean of all tiles that are not visible **/
	BOOL removeInvisibleTilesOnMemoryWarning;
	/** When route-me receives a memory warning, it will clear its memory cache entirely **/
	BOOL clearMemoryCacheOnMemoryWarning;
	/** Route-me will clear all tiles when it receives a memory warning. Overriden by handleMemoryWarnings **/
	BOOL clearAllTilesOnMemoryWarning;
}

@property (nonatomic, assign) int maxDragCounterValue;
@property (nonatomic, assign) BOOL suppressLoading;

@property (nonatomic, assign) BOOL imageUpdatesAllowed;

@property (nonatomic, retain) RMMapView* mapView;
@property (readwrite) CLLocationCoordinate2D mapCenter;
@property (readwrite) RMProjectedRect projectedBounds;
@property (readonly)  RMTileRect tileBounds;
@property (readonly)  CGRect screenBounds;
@property (readwrite) float metersPerPixel;
/// zoom level is clamped to range (minZoom, maxZoom)
@property (readwrite) float zoom;

@property (readwrite) float minZoom;
@property (readwrite) float maxZoom;

@property (readonly) NSMutableArray* imagesOnScreenLayers;
@property (readonly)  NSMutableArray *tileLoaderArray;

@property (readonly)  RMProjection *projection;
@property (readonly)  id<RMMercatorToTileProjection> mercatorToTileProjection;
@property (readonly)  RMMercatorToScreenProjection *mercatorToScreenProjection;

@property (nonatomic, retain) NSMutableArray* tileSources;

@property (retain, readwrite) RMMapRenderer *renderer;

@property (readonly)  CALayer *layer;

@property (retain, readwrite) RMMapLayer *background;
@property (retain, readwrite) RMLayerCollection *overlay;
@property (retain, readonly)  RMMarkerManager *markerManager;
/// \bug probably shouldn't be retaining this delegate
@property (nonatomic, retain) id<RMTilesUpdateDelegate> tilesUpdateDelegate;
@property (readwrite) NSUInteger boundingMask;
/// The denominator in a cartographic scale like 1/24000, 1/50000, 1/2000000.
@property (readonly)double scaleDenominator;

@property (nonatomic, assign) BOOL handleMemoryWarnings;
@property (nonatomic, assign) BOOL suppressLoadingOnMemoryWarning;
@property (nonatomic, assign) BOOL removeInvisibleTilesOnMemoryWarning;
@property (nonatomic, assign) BOOL clearMemoryCacheOnMemoryWarning;
@property (nonatomic, assign) BOOL clearAllTilesOnMemoryWarning;

- (id)initWithView: (UIView*) view;
- (id)initWithView: (UIView*) view
		tilesource:(NSMutableArray*) newTilesources;
/// designated initializer
- (id)initWithView:(UIView*)view
		tilesource:(NSMutableArray*) tilesources
	  centerLatLon:(CLLocationCoordinate2D)initialCenter
		 zoomLevel:(float)initialZoomLevel
	  maxZoomLevel:(float)maxZoomLevel
	  minZoomLevel:(float)minZoomLevel
   backgroundImage:(UIImage *)backgroundImage;

- (void)setFrame:(CGRect)frame;

- (void)handleMemoryWarningNotification:(NSNotification *)notification;
- (void)didReceiveMemoryWarning;

- (void)moveToLatLong: (CLLocationCoordinate2D)latlong;
- (void)moveToProjectedPoint: (RMProjectedPoint)aPoint;

- (CGSize) containVerticallyIfNeeded:(CGSize) delta;
- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center;
- (void)zoomInToNextNativeZoomAt:(CGPoint) pivot animated:(BOOL) animated;
- (void)zoomOutToNextNativeZoomAt:(CGPoint) pivot animated:(BOOL) animated; 
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center animated:(BOOL) animated;
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center animated:(BOOL) animated withCallback:(id<RMMapContentsAnimationCallback>)callback;

- (void)zoomInToNextNativeZoomAt:(CGPoint) pivot;
- (void)zoomOutToNextNativeZoomAt:(CGPoint) pivot; 
- (float)adjustZoomForBoundingMask:(float)zoomFactor;
- (void)adjustMapPlacementWithScale:(float)aScale;
- (float)nextNativeZoomFactor;
- (float)prevNativeZoomFactor;

- (void) drawRect: (CGRect) rect;

//-(void)addLayer: (id<RMMapLayer>) layer above: (id<RMMapLayer>) other;
//-(void)addLayer: (id<RMMapLayer>) layer below: (id<RMMapLayer>) other;
//-(void)removeLayer: (id<RMMapLayer>) layer;

// During touch and move operations on the iphone its good practice to
// hold off on any particularly expensive operations so the user's 
+ (BOOL) performExpensiveOperations;
+ (void) setPerformExpensiveOperations: (BOOL)p;

- (CGPoint)latLongToPixel:(CLLocationCoordinate2D)latlong;
- (CGPoint)latLongToPixel:(CLLocationCoordinate2D)latlong withMetersPerPixel:(float)aScale;
- (RMTilePoint)latLongToTilePoint:(CLLocationCoordinate2D)latlong withMetersPerPixel:(float)aScale;
- (CLLocationCoordinate2D)pixelToLatLong:(CGPoint)aPixel;
- (CLLocationCoordinate2D)pixelToLatLong:(CGPoint)aPixel withMetersPerPixel:(float)aScale;

- (void)zoomWithLatLngBoundsNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)se;
- (void)zoomWithRMMercatorRectBounds:(RMProjectedRect)bounds;

/// returns the smallest bounding box containing the entire screen
- (RMSphericalTrapezium) latitudeLongitudeBoundingBoxForScreen;
/// returns the smallest bounding box containing a rectangular region of the screen
- (RMSphericalTrapezium) latitudeLongitudeBoundingBoxFor:(CGRect) rect;

- (void)setRotation:(float)angle;

- (void) tilesUpdatedRegion:(CGRect)region;

/*! \brief Clear all images from the #tileSource's caching system.
 
 All of the existing RMTileSource implementations load tile images via NSURLRequest. It's possible that some images will remain in your
 application's shared URL cache. If you need to clear this out too, use this call:
 \code
 [[NSURLCache sharedURLCache] removeAllCachedResponses];
 \endcode
 */
-(void)removeAllCachedImages;

-(void)dumpFastCacheToDB;

- (void) setTileSource: (id<RMTileSource>)newTileSource AtIndex: (NSInteger) index;

/**
 * MULTI-LAYER
 */
- (void) removeTileSourceAtIndex: (NSInteger) index;

- (void) sendLayerBack: (NSInteger) index;

@end

/// Appears to be the methods actually implemented by RMMapContents, but generally invoked on RMMapView, and forwarded to the contents object.
@protocol RMMapContentsFacade

@optional
- (void)moveToLatLong: (CLLocationCoordinate2D)latlong;
- (void)moveToProjectedPoint: (RMProjectedPoint)aPoint;

- (void)moveBy: (CGSize) delta;
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center;
- (void)zoomInToNextNativeZoomAt:(CGPoint) pivot animated:(BOOL) animated;
- (void)zoomOutToNextNativeZoomAt:(CGPoint) pivot animated:(BOOL) animated; 
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) center animated:(BOOL) animated;

- (void)zoomInToNextNativeZoomAt:(CGPoint) pivot;
- (void)zoomOutToNextNativeZoomAt:(CGPoint) pivot; 
- (float)adjustZoomForBoundingMask:(float)zoomFactor;
- (void)adjustMapPlacementWithScale:(float)aScale;

- (CGPoint)latLongToPixel:(CLLocationCoordinate2D)latlong;
- (CGPoint)latLongToPixel:(CLLocationCoordinate2D)latlong withMetersPerPixel:(float)aScale;
- (CLLocationCoordinate2D)pixelToLatLong:(CGPoint)aPixel;
- (CLLocationCoordinate2D)pixelToLatLong:(CGPoint)aPixel withMetersPerPixel:(float)aScale;

- (void)zoomWithLatLngBoundsNorthEast:(CLLocationCoordinate2D)ne SouthWest:(CLLocationCoordinate2D)se;
- (void)zoomWithRMMercatorRectBounds:(RMProjectedRect)bounds;

/// \deprecated name change pending after 0.5
- (RMSphericalTrapezium) latitudeLongitudeBoundingBoxForScreen;
/// \deprecated name change pending after 0.5
- (RMSphericalTrapezium) latitudeLongitudeBoundingBoxFor:(CGRect) rect;

- (void) tilesUpdatedRegion:(CGRect)region;
- (RMTileImageSet*) imagesOnScreen: (NSInteger)index;
- (void) allowLoadingAndUpdate;
@end





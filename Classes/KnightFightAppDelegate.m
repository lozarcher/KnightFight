//
//  KnightFightAppDelegate.m
//  KnightFight
//
//  Created by Loz Archer on 27/04/2011.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"
#import <sys/utsname.h>

#import "KnightFightAppDelegate.h"
#import "GameConfig.h"
#import "GameScene.h"
#import "MainMenuScene.h"
#import "RootViewController.h"
#import "InstructionsScene.h"
#import "ShootOutScene.h"

@implementation KnightFightAppDelegate

@synthesize window;
@synthesize tileMap;
@synthesize gameState;
@synthesize gameScene;
@synthesize playerLives, level, maxLevels;
@synthesize maxPlayerLives;
@synthesize	musicOn, soundOn, isIPad;

@synthesize coordinateFunctions;
- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if you Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

-(void)showMenu {
	NSLog(@"In showMenu, in app delegate");
	self.gameState = MainMenu;
	[[CCDirector sharedDirector] popScene];
	[SimpleAudioEngine sharedEngine].effectsVolume = 0.0f;
	if ((![[SimpleAudioEngine sharedEngine] isBackgroundMusicPlaying]) && (UIAppDelegate.musicOn)) {
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"titletheme.m4a"];
	}
}

-(void)showInstructions {
	NSLog(@"In showMenu, in app delegate");
	self.gameState = Instructions;
	[[CCDirector sharedDirector] pushScene:[InstructionsScene scene]];
}

-(void)finishedShootOut:(BOOL)successful {
	NSLog(@"Finished shootOut, in app delegate");
	[[CCDirector sharedDirector] popScene];
	self.gameState = Play;
	if (successful) {
		level++;
	} else {
		[gameScene loseLife];
	}
	[gameScene resetGame];
}

-(void)shootOut {
	NSLog(@"In shootOut, in app delegate");
	[[CCDirector sharedDirector] pushScene:[ShootOutScene scene]];
}

-(void)startGame {
	self.gameState = Play;
	maxPlayerLives = 3;
	level = 1;
	NSLog(@"In start game");
	[[CCDirector sharedDirector] pushScene: [KnightFight scene]];
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[SimpleAudioEngine sharedEngine].effectsVolume = 0.3f;

}

-(void)checkDevice {
	struct utsname systemInfo;
	uname(&systemInfo);
	NSString *device = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
	NSRange range = [device rangeOfString:@"iPad"];
	if (range.location != NSNotFound) {
		self.isIPad = YES;
	} else {
		self.isIPad = NO;
	}
}

- (void) applicationDidFinishLaunching:(UIApplication*)application
{	
	[self checkDevice];
	
	self.maxLevels = 2;
		
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		
	self.coordinateFunctions = [CoordinateFunctions coordinateFunctions];
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	CCDirector *director = [CCDirector sharedDirector];
	
	//[director setDepthBufferFormat:kDepthBuffer16];

	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:GL_DEPTH_COMPONENT16_OES		// GL_DEPTH_COMPONENT16_OES
						];
	
	[glView setMultipleTouchEnabled:YES];

	// attach the openglView to the director
	[director setOpenGLView:glView];

	
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
#else
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
	
	[director setAnimationInterval:1.0/30];
	[director setDisplayFPS:NO];
	
	// required for cc_vertexz property to work properly (if not set, cc_vertexz layers will be zoomed out!)
	[director setProjection:kCCDirectorProjection2D];
		
	// make the OpenGLView a child of the view controller
	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
	
	// Run the intro Scene
	//[[CCDirector sharedDirector] runWithScene: [KnightFight scene]];		
	
	[[CCDirector sharedDirector] runWithScene:[MainMenuScene scene]];
	if (UIAppDelegate.soundOn) {
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"titletheme.m4a"];
	}
}


- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];

	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end

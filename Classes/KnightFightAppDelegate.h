//
//  KnightFightAppDelegate.h
//  KnightFight
//
//  Created by Loz Archer on 27/04/2011.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "CoordinateFunctions.h"

@class RootViewController;

#define UIAppDelegate \
((KnightFightAppDelegate *)[UIApplication sharedApplication].delegate)

static int numberOfLevels = 2;

typedef	enum {
	GameOver,
	Play,
	MainMenu,
	Instructions,
	PowerUp,
	ShootOut
} GameState;

@interface KnightFightAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
	CCTMXTiledMap		*tileMap;
	CoordinateFunctions *coordinateFunctions;
	GameState			*gameState;
	CCLayer				*gameScene;
	int					maxPlayerLives, playerLives, level, maxLevels;
	BOOL				musicOn, soundOn, isIPad;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (nonatomic, retain) CoordinateFunctions *coordinateFunctions;
@property (nonatomic) GameState *gameState;
@property (nonatomic, retain) CCLayer *gameScene;
@property (nonatomic) int maxPlayerLives, playerLives, level, maxLevels;
@property (nonatomic) BOOL musicOn, soundOn, isIPad;

-(void)startGame;
-(void)shootOut;

@end

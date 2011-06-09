//
//  HelloWorldLayer.h
//  KnightFight
//
//  Created by Loz Archer on 27/04/2011.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "cocos2d.h"
#import "Player.h"
#import "Attacker.h"
#import "Bullet.h"
#import "Door.h"
#import "SimpleAudioEngine.h"
#import "Knight.h"
#import "HudLayer.h"

enum
{
	TileMapNode = 0,
};


// HelloWorld Layer
@interface KnightFight : CCLayer
{
	CCTMXLayer *meta;
	Player *player;
	Knight *knight;
	NSMutableArray *attackers;
	NSMutableArray *bullets;
	NSMutableArray *doors;
	float collisionsTick;
	float linesOfSightTick;
	float zPositionTick;
	float aStarUpdateTick;
	float collisionPlayerEnvironTick;
	CCLayer *_hudLayer;
	CCSprite *powerUpAlert;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;
-(void)setViewpointCenter:(CGPoint) position;
-(void)setUpHouseContents;
-(void)resetGame;
-(void)loseLife;
-(void)removeSpeedUp:(ccTime)delta;
-(void)removeTripleShots:(ccTime)delta;
-(CGPoint)getPlayerSpawn;
-(Player *)getPlayer;

@property (nonatomic, retain) CCTMXLayer *meta;
@property (nonatomic, retain) Player *player;
@property (nonatomic, retain) Knight *knight;
@property (nonatomic, retain) NSMutableArray *attackers;
@property (nonatomic, retain) NSMutableArray *bullets;
@property (nonatomic, retain) NSMutableArray *doors;
@property (nonatomic) float collisionsTick;
@property (nonatomic) float aStarUpdateTick;
@property (nonatomic) float linesOfSightTick;
@property (nonatomic) float zPositionTick;
@property (nonatomic) float collisionPlayerEnvironTick;
@property (nonatomic, retain) CCLayer *hudLayer;
@property (nonatomic, retain) CCSprite *powerUpAlert;
	

@end

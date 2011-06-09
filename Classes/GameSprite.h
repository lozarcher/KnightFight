//
//  GameSprite.h
//  KnightFight
//
//  Created by Loz Archer on 03/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameSprite : CCSprite {
	CCSequence *spriteRunAction;
	BOOL isMoving;
	BOOL alive;
	int deathTurns;
	CCAnimation *animation;
	int zOrderOffset;
	float velocity;
	CCSpriteSheet *spriteSheet;
	NSString *spritesheetBaseFilename;
}

@property (nonatomic) BOOL isMoving;
@property (nonatomic) BOOL alive;
@property (nonatomic) int deathTurns;
@property (nonatomic, retain) CCAnimation *animation;
@property (nonatomic, retain) CCSequence *spriteRunAction;
@property (nonatomic) int zOrderOffset;
@property (nonatomic) float velocity;
@property (nonatomic, retain) CCSpriteSheet *spriteSheet;
@property (nonatomic, retain) NSString *spritesheetBaseFilename;

-(CGPoint)getLocation;
-(void)changeSpriteAnimation:(NSString *)direction;
-(void)moveSpritePosition:(CGPoint)targetPosition sender:(id)sender;
-(void) updateVertexZ:(CGPoint)tilePos tileMap:(CCTMXTiledMap*)tileMap;
-(BOOL)checkIfPointIsInSight:(CGPoint)playerPos enemySprite:(GameSprite *)enemy;
-(void)deathSequence;
-(void)cacheFrames;

@end

//
//  Attacker.h
//  KnightFight
//
//  Created by Loz Archer on 05/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameSprite.h"

extern float *const velocity;

@interface Attacker : GameSprite {
	CGPoint lastPosition;
	BOOL chasingPlayer;
	BOOL followingPath;
	NSMutableArray *path;
	NSThread *thread;
}

@property (nonatomic) CGPoint lastPosition;
@property (nonatomic) BOOL chasingPlayer;
@property (nonatomic) BOOL followingPath;
@property (nonatomic, retain) NSMutableArray *path;
@property (nonatomic, retain) NSThread *thread;

+(id) attacker;
-(void)chasePlayer:(GameSprite *)player;
-(void)createPathToPlayer;
-(void)getPath:(NSArray *)tilePositions;

@end

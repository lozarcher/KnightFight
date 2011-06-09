//
//  Player.m
//  KnightFight
//
//  Created by Loz Archer on 30/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Player.h"

@implementation Player

@synthesize lastPosition;
@synthesize speedUpActive;
@synthesize tripleShotsActive;
@synthesize velocitySpeedUp, velocityOrdinary;

-(id) init {
    if ((self = [super init]))
    {
		self.zOrderOffset = 0;
		self.velocitySpeedUp = 270/1;
		self.velocityOrdinary = 180/1;
		self.velocity = velocityOrdinary;
		self.alive = YES;
		self.isMoving = NO;
		self.speedUpActive = NO;
		self.tripleShotsActive = NO;
		self.spritesheetBaseFilename = @"walking";
		[self cacheFrames];

    }
    return self;
}


+(id) player
{
	return [[[self alloc] init] autorelease];
}

@end

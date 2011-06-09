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

@interface Knight : GameSprite {
	CGPoint lastPosition;
}

@property (nonatomic) CGPoint lastPosition;

+(id) knight;
-(void)moveInRandomDirection;

@end

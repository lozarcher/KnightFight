//
//  CoordinateFunctions.h
//  KnightFight
//
//  Created by Loz Archer on 05/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameSprite.h"

@interface CoordinateFunctions : NSObject {
	CGPoint playableAreaMin;
	CGPoint playableAreaMax;
}

@property (nonatomic) CGPoint playableAreaMin;
@property (nonatomic) CGPoint playableAreaMax;

+ (id)coordinateFunctions;
-(CGPoint) tilePosFromLocation:(CGPoint)location;
-(CGPoint) locationFromTilePos:(CGPoint)tilePos;
-(CGPoint) pointRelativeToCentreFromLocation:(CGPoint)location;
-(BOOL) spritesCollided:(GameSprite *)sprite1 sprite2:(GameSprite *)sprite2;
-(bool) atDoor:(CGPoint)tilePos;
-(bool) isTilePosBlocked:(CGPoint)tilePos;
-(CGPoint) ensureTilePosIsWithinBounds:(CGPoint)tilePos;
-(BOOL) isTilePosIsWithinBounds:(CGPoint)tilePos;
-(float) getAngleBetweenPoints:(CGPoint)point1 pt2:(CGPoint)point2;
-(CGPoint)pointFromAngleAndDistance:(float)angle startPosition:(CGPoint)startPosition distance:(float)distance;
-(void) removeTile:(CGPoint)tilePos; // for debugging the pathfinding
@end

//
//  CoordinateFunctions.m
//  KnightFight
//
//  Created by Loz Archer on 05/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CoordinateFunctions.h"
#import "cocos2d.h"
#import "KnightFightAppDelegate.h"

static CoordinateFunctions *coordinateFunctions = nil;

@implementation CoordinateFunctions

@synthesize playableAreaMin, playableAreaMax;


static float arctan2(float y, float x) {
	const float ONEQTR_PI = 0.78539816339f;
	const float THRQTR_PI = 2.35619449019f;
	float r, angle;
	float abs_y = fabs(y) + 1e-10f;
	if (x < 0.0f) {
		r = (x + abs_y) / (abs_y - x);
		angle = THRQTR_PI;
	} else {
		r = (x - abs_y) / (x + abs_y);
		angle = ONEQTR_PI;
	}
	angle += (0.1963f * r * r - 0.9817f) * r;
	return (y < 0.0f) ? -angle : angle;
}

-(float) getAngleBetweenPoints:(CGPoint)point1 pt2:(CGPoint)point2 {
	float dx, dy;
	dx = point1.x - point2.x;
	dy = point1.y - point2.y;
	float radians = arctan2(dy, dx);
	float angle = CC_RADIANS_TO_DEGREES(radians);
	if (angle < 0) {
		angle = (360.0f + angle);
	}
	return angle;
}

-(CGPoint)pointFromAngleAndDistance:(float)angle startPosition:(CGPoint)startPosition distance:(float)distance {

	float angleInRadians = CC_DEGREES_TO_RADIANS(angle);
	CGPoint newPoint = ccp(startPosition.x + distance * -cos(angleInRadians),
						   startPosition.y + distance * -sin(angleInRadians));
	return newPoint;
}

-(CGPoint) tilePosFromLocation:(CGPoint)location
{
	// Tilemap position must be added as an offset, in case the tilemap position is not at 0,0 due to scrolling
	CGPoint pos = ccpSub(location, UIAppDelegate.tileMap.position);
	
	float halfMapWidth = UIAppDelegate.tileMap.mapSize.width * 0.5f;
	float mapHeight = UIAppDelegate.tileMap.mapSize.height;
	float tileWidth = UIAppDelegate.tileMap.tileSize.width;
	float tileHeight = UIAppDelegate.tileMap.tileSize.height;
	
	CGPoint tilePosDiv = CGPointMake(pos.x / tileWidth, pos.y / tileHeight);
	float mapHeightDiff = mapHeight - tilePosDiv.y;
	
	// Cast to int makes sure that result is in whole numbers, tile coordinates will be used as array indices
	int posX = (mapHeightDiff + tilePosDiv.x - halfMapWidth);
	int posY = (mapHeightDiff - tilePosDiv.x + halfMapWidth);
	
	return CGPointMake(posX, posY);
}

-(CGPoint) locationFromTilePos:(CGPoint)tilePos {
	CCTMXLayer *grass = [UIAppDelegate.tileMap layerNamed:@"Grass"];
	CCSprite *tile = [grass tileAt:tilePos];
	float x = -tile.position.x - UIAppDelegate.tileMap.tileSize.width + 32;
	float y = -tile.position.y - UIAppDelegate.tileMap.tileSize.height;
	return CGPointMake(x, y);
}

-(CGPoint) pointRelativeToCentreFromLocation:(CGPoint)location {
	return ccpSub(UIAppDelegate.tileMap.position, location);
}

-(BOOL) isTilePosIsWithinBounds:(CGPoint)tilePos
{	
	if ((tilePos.x < playableAreaMin.x) ||
		(tilePos.x > playableAreaMax.x) ||
		(tilePos.y < playableAreaMin.y) ||
		(tilePos.y > playableAreaMax.y)
		) 
	{
		return NO;
	}
	return YES;
}

-(CGPoint) ensureTilePosIsWithinBounds:(CGPoint)tilePos
{	
	// make sure coordinates are within bounds of the playable area, correcting them if not
	tilePos.x = MAX(playableAreaMin.x, tilePos.x);
	tilePos.x = MIN(playableAreaMax.x, tilePos.x);
	tilePos.y = MAX(playableAreaMin.y, tilePos.y);
	tilePos.y = MIN(playableAreaMax.y, tilePos.y);
	
	return tilePos;
}

-(void) debugTile:(CGPoint)tilePos {
	CCTMXLayer* grassLayer = [UIAppDelegate.tileMap layerNamed:@"Grass"];
	[grassLayer setTileGID:230 at:tilePos];
}

-(bool) isTilePosBlocked:(CGPoint)tilePos
{
	CCTMXLayer* metaLayer = [UIAppDelegate.tileMap layerNamed:@"Meta"];
	if (![self isTilePosIsWithinBounds:tilePos]) {
		NSLog(@"Off the map! Tile pos %f %f is not within bounds", tilePos.x, tilePos.y);
		return YES;
	}
	
	//NSLog(@"Checking if tile %f %f is collidable", tilePos.x, tilePos.y);

	unsigned int metaTileGID = [metaLayer tileGIDAt:tilePos];
	if (metaTileGID > 0)
	{
		NSDictionary *properties = [UIAppDelegate.tileMap propertiesForGID:metaTileGID];
		if (properties) {
			NSString *collision = [properties valueForKey:@"Collidable"];
			if ([collision isEqualToString:@"True"]) {
				return YES;
			} 
		}
	}
	
	return NO;
}


-(bool) atDoor:(CGPoint)tilePos
{
	CCTMXLayer* metaLayer = [UIAppDelegate.tileMap layerNamed:@"Meta"];
	
	unsigned int metaTileGID = [metaLayer tileGIDAt:tilePos];
	if (metaTileGID > 0)
	{
		NSDictionary *properties = [UIAppDelegate.tileMap propertiesForGID:metaTileGID];
		if (properties) {
			NSString *collision = [properties valueForKey:@"Door"];
			if ([collision isEqualToString:@"True"]) {
				return YES;
			} 
		}
	}
	
	return NO;
}

-(BOOL)spritesCollided:(GameSprite *)sprite1 sprite2:(GameSprite *)sprite2 {
	NSString *spriteClass1 = [NSString stringWithFormat:@"%@",[sprite1 class]];
	NSString *spriteClass2 = [NSString stringWithFormat:@"%@",[sprite1 class]];
	
	CGRect spriteRect1;
	CGRect spriteRect2;
	// Do normal collision detection for bullet.
	// Make allowances for huge transparent border for everything else.
	if ([spriteClass1 isEqual:@"Bullet"]) {
		spriteRect1 = CGRectMake(
									sprite1.position.x - (sprite1.contentSize.width/2), 
									sprite1.position.y - (sprite1.contentSize.height/2), 
									sprite1.contentSize.width, 
									sprite1.contentSize.height);
	} else {
		spriteRect1 = CGRectMake(
										sprite1.position.x - (sprite1.contentSize.width/4), 
										sprite1.position.y - (sprite1.contentSize.height/4), 
										sprite1.contentSize.width / 2, 
										sprite1.contentSize.height / 2);
	}
	if ([spriteClass2 isEqual:@"Bullet"]) {
		spriteRect2 = CGRectMake(
								 sprite2.position.x - (sprite2.contentSize.width/2), 
								 sprite2.position.y - (sprite2.contentSize.height/2), 
								 sprite2.contentSize.width, 
								 sprite2.contentSize.height);
	} else {
		spriteRect2 = CGRectMake(
								 sprite2.position.x - (sprite2.contentSize.width/4), 
								 sprite2.position.y - (sprite2.contentSize.height/4), 
								 sprite2.contentSize.width / 2, 
								 sprite2.contentSize.height / 2);
	}
	return CGRectIntersectsRect(spriteRect1, spriteRect2);
}

#pragma mark Singleton Methods
+ (id)coordinateFunctions {
	@synchronized(self) {
		if(coordinateFunctions == nil)
			coordinateFunctions = [[super allocWithZone:NULL] init];
	}
	return coordinateFunctions;
}

+ (id)allocWithZone:(NSZone *)zone {
	return [[self coordinateFunctions] retain];
}
- (id)copyWithZone:(NSZone *)zone {
	return self;
}
- (id)retain {
	return self;
}
- (unsigned)retainCount {
	return UINT_MAX; //denotes an object that cannot be released
}
- (void)release {
	// never release
}
- (id)autorelease {
	return self;
}
- (id)init {
	if( (self=[super init] )) {
	}
	return self;
}
- (void)dealloc {
	[super dealloc];
}

@end

//
//  Pathfinding.h
//  KnightFight
//
//  Created by Loz Archer on 10/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Pathfinding : CCNode {
	NSMutableArray *openList;
	NSMutableArray *closedList;	
}

@property (nonatomic, retain) NSMutableArray *openList;
@property (nonatomic, retain) NSMutableArray *closedList;

-(NSMutableArray *)search:(CGPoint)startTile targetTile:(CGPoint)targetTile;

@end
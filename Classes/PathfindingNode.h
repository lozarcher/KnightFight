//
//  PathfindingNode.h
//  KnightFight
//
//  Created by Loz Archer on 10/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface PathfindingNode : NSObject {
	CGPoint tilePos;
	PathfindingNode *parent;
	int F;
	int G;
	int H;
}

@property (nonatomic) CGPoint tilePos;
@property (nonatomic, retain) PathfindingNode *parent;
@property (nonatomic) int F;
@property (nonatomic) int G;
@property (nonatomic) int H;

@end

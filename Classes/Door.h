//
//  Door.h
//  KnightFight
//
//  Created by Loz Archer on 09/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Door : CCNode {
	CGPoint gridPos;
	NSString *contents;
}

@property (nonatomic) CGPoint tilePos;
@property (nonatomic, retain) NSString *contents;

+(id) door;

@end

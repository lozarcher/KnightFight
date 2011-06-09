//
//  Door.m
//  KnightFight
//
//  Created by Loz Archer on 09/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Door.h"


@implementation Door

@synthesize tilePos, contents;

-(id) init {
    if ((self = [super init])) {
		// Allocate house contents randomly from an array
		NSArray *houseContents = [NSArray arrayWithObjects:@"ExtraLife", @"TripleShots", @"GhostRespawn", @"SpeedUp", nil];
		int randomNumber = arc4random() % ([houseContents count]);
		self.contents = [houseContents objectAtIndex:randomNumber];
	}
    return self;
}


+(id) door
{
	return [[[self alloc] init] autorelease];
}

@end

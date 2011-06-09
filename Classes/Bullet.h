//
//  Bullet.h
//  KnightFight
//
//  Created by Loz Archer on 06/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameSprite.h"
#import "Player.h"

@interface Bullet : GameSprite {

}

+(id) bullet;
-(void)shootBullet:(CGPoint)targetPosition player:(Player*)player;

@end

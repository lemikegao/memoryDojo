//
//  NinjaStar.m
//  memoryDojo
//
//  Created by Michael Gao on 11/18/12.
//
//

#import "NinjaStar.h"

@implementation NinjaStar

-(id)init {
    self = [super init];
    if (self != nil) {
        self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_upgrades_ninjastar2.png"];
        self.gameObjectType = kGameObjectTypeNinjaStar;
        self.visible = NO;
    }
    
    return self;
}

-(void)shootNinjaStarFromNinja:(Ninja *)ninja withDirection:(DirectionTypes)direction {
    id moveAction;
    switch(direction) {
        case kDirectionTypeLeft:
        {
            self.position = ninja.position;
            moveAction = [CCSequence actions:[CCSpawn actions:[CCRotateBy actionWithDuration:1.0f angle:360.0f], [CCMoveBy actionWithDuration:1.0f position:ccp(-1*self.screenSize.width, 0)], nil], [CCCallFunc actionWithTarget:self selector:@selector(hideNinjaStar)], nil];
            break;
        }
            
        case kDirectionTypeDown:
        {
            self.position = ninja.position;
            moveAction = [CCSequence actions:[CCSpawn actions:[CCRotateBy actionWithDuration:1.0f angle:360.0f], [CCMoveBy actionWithDuration:1.0f position:ccp(0, -1*self.screenSize.height)], nil], [CCCallFunc actionWithTarget:self selector:@selector(hideNinjaStar)], nil];
            break;
        }
            
        case kDirectionTypeRight:
        {
            self.position = ninja.position;
            moveAction = [CCSequence actions:[CCSpawn actions:[CCRotateBy actionWithDuration:1.0f angle:360.0f], [CCMoveBy actionWithDuration:1.0f position:ccp(self.screenSize.width, 0)], nil], [CCCallFunc actionWithTarget:self selector:@selector(hideNinjaStar)], nil];
            break;
        }
            
        case kDirectionTypeUp:
        {
            CCLOG(@"screensize height: %f", self.screenSize.height);
            self.position = ninja.position;
            moveAction = [CCSequence actions:[CCSpawn actions:[CCRotateBy actionWithDuration:1.0f angle:360.0f], [CCMoveBy actionWithDuration:1.0f position:ccp(0, self.screenSize.height)], nil], [CCCallFunc actionWithTarget:self selector:@selector(hideNinjaStar)], nil];
            break;
        }
            
        default: {
            CCLOG(@"Direction invalid, NinjaStar.m");
        }
    }

    self.visible = YES;
    [self runAction:moveAction];
}

-(void)hideNinjaStar {
    self.visible = NO;
}

@end

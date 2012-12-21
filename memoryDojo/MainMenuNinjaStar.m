//
//  MainMenuNinjaStar.m
//  memoryDojo
//
//  Created by Michael Gao on 12/11/12.
//
//

#import "MainMenuNinjaStar.h"

@implementation MainMenuNinjaStar

-(id)init {
    self = [super init];
    if (self != nil) {
        self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_upgrades_ninjastar2.png"];
        self.gameObjectType = kGameObjectTypeNinjaStar;
        self.visible = NO;
    }
    
    return self;
}

-(void)shootNinjaStarFromNinja:(MainMenuNinja*)ninja withDirection:(DirectionTypes)direction {
    id moveAction;
    switch(direction) {
        case kDirectionTypeLeft:
        {
            self.position = ccp(ninja.position.x - ninja.boundingBox.size.width * 0.30f, ninja.position.y);
            moveAction = [CCSequence actions:[CCSpawn actions:[CCRotateBy actionWithDuration:1.0f angle:-1500.0f], [CCMoveBy actionWithDuration:1.0f position:ccp(-1*self.screenSize.height, 0)], nil], [CCCallFunc actionWithTarget:self selector:@selector(hideNinjaStar)], nil];
            break;
        }
            
        case kDirectionTypeDown:
        {
            self.position = ccp(ninja.position.x - ninja.boundingBox.size.width * 0.30f, ninja.position.y - ninja.boundingBox.size.height * 0.30f);
            moveAction = [CCSequence actions:[CCSpawn actions:[CCRotateBy actionWithDuration:1.0f angle:1500.0f], [CCMoveBy actionWithDuration:1.0f position:ccp(0, -1*self.screenSize.height)], nil], [CCCallFunc actionWithTarget:self selector:@selector(hideNinjaStar)], nil];
            break;
        }
            
        case kDirectionTypeRight:
        {
            self.position = ninja.position;
            moveAction = [CCSequence actions:[CCSpawn actions:[CCRotateBy actionWithDuration:1.0f angle:1500.0f], [CCMoveBy actionWithDuration:1.0f position:ccp(self.screenSize.height, 0)], nil], [CCCallFunc actionWithTarget:self selector:@selector(hideNinjaStar)], nil];
            break;
        }
            
        case kDirectionTypeUp:
        {
            self.position = ccp(ninja.position.x - ninja.boundingBox.size.width * 0.30f, ninja.position.y);
            moveAction = [CCSequence actions:[CCSpawn actions:[CCRotateBy actionWithDuration:1.0f angle:1500.0f], [CCMoveBy actionWithDuration:1.0f position:ccp(0, self.screenSize.height)], nil], [CCCallFunc actionWithTarget:self selector:@selector(hideNinjaStar)], nil];
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
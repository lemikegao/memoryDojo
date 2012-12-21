//
//  NinjaStar.m
//  memoryDojo
//
//  Created by Michael Gao on 11/18/12.
//
//

#import "NinjaStar.h"

@interface NinjaStar ()

@property (nonatomic, strong) NSString *scenePrefix;

@end

@implementation NinjaStar

-(id)init {
    self = [super init];
    if (self != nil) {
        self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"%@_upgrades_ninjastar2.png", self.scenePrefix]];
        self.gameObjectType = kGameObjectTypeNinjaStar;
        self.visible = NO;
    }
    
    return self;
}

-(id)initFromScene:(SceneTypes)scene {
    if (scene == kSceneTypeMainMenu) {
        self.scenePrefix = @"mainmenu";
    } else if (scene == kSceneTypeGame) {
        self.scenePrefix = @"game";
    } else {
        CCLOG(@"NinjaStar->initFromScene: Unknown scene type: %i", scene);
    }
    
    self = [self init];
    return self;
}

-(void)shootNinjaStarFromNinja:(Ninja *)ninja withDirection:(DirectionTypes)direction {
    id moveAction;
    switch(direction) {
        case kDirectionTypeLeft:
        {
            self.position = ccp(ninja.position.x - ninja.boundingBox.size.width * 0.30f, ninja.position.y + ninja.boundingBox.size.height/2);
            moveAction = [CCSequence actions:[CCSpawn actions:[CCRotateBy actionWithDuration:1.0f angle:-1500.0f], [CCMoveBy actionWithDuration:1.0f position:ccp(-1*self.screenSize.height, 0)], nil], [CCCallFunc actionWithTarget:self selector:@selector(hideNinjaStar)], nil];
            break;
        }
            
        case kDirectionTypeDown:
        {
            self.position = ccp(ninja.position.x - ninja.boundingBox.size.width * 0.30f, ninja.position.y + ninja.boundingBox.size.height * 0.30f);
            moveAction = [CCSequence actions:[CCSpawn actions:[CCRotateBy actionWithDuration:1.0f angle:1500.0f], [CCMoveBy actionWithDuration:1.0f position:ccp(0, -1*self.screenSize.height)], nil], [CCCallFunc actionWithTarget:self selector:@selector(hideNinjaStar)], nil];
            break;
        }
            
        case kDirectionTypeRight:
        {
            self.position = ccp(ninja.position.x - ninja.boundingBox.size.width * 0.30f, ninja.position.y + ninja.boundingBox.size.height/2);
            moveAction = [CCSequence actions:[CCSpawn actions:[CCRotateBy actionWithDuration:1.0f angle:1500.0f], [CCMoveBy actionWithDuration:1.0f position:ccp(self.screenSize.height, 0)], nil], [CCCallFunc actionWithTarget:self selector:@selector(hideNinjaStar)], nil];
            break;
        }
            
        case kDirectionTypeUp:
        {
            self.position = ccp(ninja.position.x - ninja.boundingBox.size.width * 0.30f, ninja.position.y + ninja.boundingBox.size.height * 0.60f);
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

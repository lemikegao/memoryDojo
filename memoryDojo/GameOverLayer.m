//
//  GameOverLayer.m
//  memoryDojo
//
//  Created by Michael Gao on 10/24/12.
//
//

#import "GameOverLayer.h"
#import "GameManager.h"

@implementation GameOverLayer

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CCLOG(@"Touches received, returning to Main Menu Scene");
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMainMenu];
}

-(id) init {
    self = [super init];
    if (self != nil) {
        self.isTouchEnabled = YES;
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"gameover_art.plist"];
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        // add background color layer first
        CCLayerColor *gameOverBg = [CCLayerColor layerWithColor:ccc4(30, 30, 30, 255) width:screenSize.width height:screenSize.height];
        [self addChild:gameOverBg z:-1];
        
        // add rays to sprite batch node
        CGPoint screenMidpoint = ccp(screenSize.width/2, screenSize.height/2);
        CCSpriteBatchNode *rayBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"game_art_bg.pvr.ccz" capacity:10];
        rayBatchNode.position = screenMidpoint;
        
        float rayAngle = 0;
        while (rayAngle < 360) {
            CCSprite *ray = [CCSprite spriteWithSpriteFrameName:@"game_transition_ray.png"];
            ray.anchorPoint = ccp(0.5, 0);
            ray.rotation = rayAngle;
            ray.position = CGPointZero;
            [rayBatchNode addChild:ray];
            
            // next ray is 40 degrees apart
            rayAngle = rayAngle + 40;
        }
        
        [gameOverBg addChild:rayBatchNode z:1];
        

        
        // add text for game over
//        NSString *gameoverString = [NSString stringWithFormat:@"Game over! Score: %i", [GameManager sharedGameManager].score];
//        CCLabelBMFont *gameOverLabel = [CCLabelBMFont labelWithString:gameoverString fntFile:@"SpaceVikingFont.fnt"];
//        gameOverLabel.position = ccp(screenSize.width/2, screenSize.height/2);
//        [self addChild:gameOverLabel];
    }
    
    return self;
}

@end

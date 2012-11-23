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

-(id) init {
    self = [super init];
    if (self != nil) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"gameover_art.plist"];
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        // add background color layer first
        CCLayerColor *gameOverBg = [CCLayerColor layerWithColor:ccc4(30, 30, 30, 255) width:screenSize.width height:screenSize.height];
        [self addChild:gameOverBg z:-1];
        
        // add rays to sprite batch node
        CCSpriteBatchNode *rayBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"game_art_bg.pvr.ccz" capacity:10];
        rayBatchNode.position = ccp(screenSize.width/2, screenSize.height/2);
        
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
        
        // add 'game over' copy
        CCSprite *gameOverCopy = [CCSprite spriteWithSpriteFrameName:@"game_over_copy.png"];
        gameOverCopy.position = ccp(screenSize.width/2, screenSize.height * 0.85f);
        [gameOverBg addChild:gameOverCopy z:5];
        
        // add game over menu bg
        CCSprite *gameOverMenuBg = [CCSprite spriteWithSpriteFrameName:@"game_transition_message_bg.png"];
        gameOverMenuBg.position = ccp(screenSize.width/2, screenSize.height/2);
        [gameOverBg addChild:gameOverMenuBg z:5];
        
        // add score copy
        CGSize gameOverMenuBgSize = gameOverMenuBg.boundingBox.size;
        CCSprite *scoreCopy = [CCLabelBMFont labelWithString:@"SCORE:" fntFile:@"score_copy.fnt"];
        scoreCopy.position = ccp(gameOverMenuBgSize.width * 0.33f, gameOverMenuBgSize.height * 0.80f);
        [gameOverMenuBg addChild:scoreCopy];
        
        // add score
        CCSprite *score = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].score] fntFile:@"score_numbers.fnt"];
        score.anchorPoint = ccp(0, 0.5);
        score.position = ccp(gameOverMenuBgSize.width * 0.52f, gameOverMenuBgSize.height * 0.80f);
        [gameOverMenuBg addChild:score];
        
        // add menu (play again, quit)
        // play again
        CCMenuItemImage *playAgainButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_over_button_playagain.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_over_button_playagain_pressed.png"] target:self selector:@selector(playAgain)];
        
        CCMenuItemImage *quitButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_quit.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_quit_pressed.png"] target:self selector:@selector(quit)];
        
        CCMenu *gameOverMenu = [CCMenu menuWithItems:playAgainButton, quitButton, nil];
        [gameOverMenu alignItemsVerticallyWithPadding:gameOverMenuBgSize.height * 0.085f];
        gameOverMenu.position = ccp(gameOverMenuBgSize.width * 0.50f, gameOverMenuBgSize.height * 0.50f);
        [gameOverMenuBg addChild:gameOverMenu z:5];
    }
    
    return self;
}

-(void)playAgain {
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeGame];
}

-(void)quit {
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMainMenu];
}

@end

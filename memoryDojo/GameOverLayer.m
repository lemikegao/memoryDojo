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
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        // add text for game over
        CCLabelBMFont *gameOverLabel = [CCLabelBMFont labelWithString:@"Game over!" fntFile:@"VikingSpeechFont64.fnt"];
        gameOverLabel.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:gameOverLabel];
    }
    
    return self;
}

@end

//
//  GameOverScene.m
//  memoryDojo
//
//  Created by Michael Gao on 10/24/12.
//
//

#import "GameOverScene.h"
#import "GameOverLayer.h"

@implementation GameOverScene

-(id)init {
    self = [super init];
    if (self != nil) {
        GameOverLayer *gameOverLayer = [GameOverLayer node];
        [self addChild:gameOverLayer];
    }
    
    return self;
}

@end

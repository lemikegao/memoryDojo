//
//  GameScene.m
//  memoryDojo
//
//  Created by Michael Gao on 10/19/12.
//
//

#import "GameScene.h"
#import "GameLayer.h"

@interface GameScene()

@property (nonatomic, strong) GameLayer *gameLayer;

@end

@implementation GameScene

@synthesize gameLayer = _gameLayer;

-(id)init {
    self = [super init];
    if (self != nil) {
        _gameLayer = [GameLayer node];
        [self addChild:_gameLayer];
    }
    
    return self;
}

@end

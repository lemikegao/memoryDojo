//
//  MainMenuScene.m
//  memoryDojo
//
//  Created by Michael Gao on 10/18/12.
//
//

#import "MainMenuScene.h"
#import "MainMenuLayer.h"

@interface MainMenuScene()

@property (nonatomic, strong) MainMenuLayer *mainMenuLayer;

@end

@implementation MainMenuScene

@synthesize mainMenuLayer = _mainMenuLayer;

-(id)init {
    self = [super init];
    if (self != nil) {
        _mainMenuLayer = [MainMenuLayer node];
        [self addChild:_mainMenuLayer];
    }
    
    return self;
}

@end

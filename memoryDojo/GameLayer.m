//
//  GameLayer.m
//  memoryDojo
//
//  Created by Michael Gao on 10/19/12.
//
//

#import "GameLayer.h"
#import "Constants.h"

@interface GameLayer()

@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeDownRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeUpRecognizer;
-(void)handleLeftSwipe;
-(void)handleDownSwipe;
-(void)handleRightSwipe;
-(void)handleUpSwipe;

@end

@implementation GameLayer

@synthesize swipeLeftRecognizer = _swipeLeftRecognizer;

-(id)init {
    self = [super init];
    if (self != nil) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCSprite *background = [CCSprite spriteWithFile:@"MainMenuBackground.png"];
        background.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:background];
        
        // comes before labelAction, otherwise action doesn't run
        [self scheduleUpdate];
        
        CCLabelBMFont *gameBeginLabel = [CCLabelBMFont labelWithString:@"Game Start" fntFile:@"SpaceVikingFont.fnt"];
        gameBeginLabel.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:gameBeginLabel];
        id labelAction = [CCSpawn actions:[CCScaleBy actionWithDuration:2.0f scale:4], [CCFadeOut actionWithDuration:2.0f], nil];
        [gameBeginLabel runAction:labelAction];
    }
    
    return self;
}

-(void)onEnter {
    [super onEnter];
    
    self.swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftSwipe)];
    self.swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [[CCDirector sharedDirector].view addGestureRecognizer:self.swipeLeftRecognizer];
    
    self.swipeDownRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleDownSwipe)];
    self.swipeDownRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [[CCDirector sharedDirector].view addGestureRecognizer:self.swipeDownRecognizer];
    
    self.swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe)];
    self.swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [[CCDirector sharedDirector].view addGestureRecognizer:self.swipeRightRecognizer];
    
    self.swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpSwipe)];
    self.swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [[CCDirector sharedDirector].view addGestureRecognizer:self.swipeUpRecognizer];
}

-(void)onExit {
    CCLOG(@"GameLayer->onExit");
    [super onExit];
    
    [[CCDirector sharedDirector].view removeGestureRecognizer:self.swipeLeftRecognizer];
    [[CCDirector sharedDirector].view removeGestureRecognizer:self.swipeDownRecognizer];
    [[CCDirector sharedDirector].view removeGestureRecognizer:self.swipeRightRecognizer];
    [[CCDirector sharedDirector].view removeGestureRecognizer:self.swipeUpRecognizer];
}

-(void)handleLeftSwipe {
    CCLOG(@"Left Swipe Detected!");
}

-(void)handleDownSwipe {
    CCLOG(@"Down Swipe Detected!");
}

-(void)handleRightSwipe {
    CCLOG(@"Right Swipe Detected!");
}

-(void)handleUpSwipe {
    CCLOG(@"Up Swipe Detected!");
}

-(void)update:(ccTime)deltaTime {
    // placeholder -- scheduleUpdate is indeed working
}

@end

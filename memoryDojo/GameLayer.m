//
//  GameLayer.m
//  memoryDojo
//
//  Created by Michael Gao on 10/19/12.
//
//

#import "GameLayer.h"
#import "Constants.h"
#import "GameManager.h"

@interface GameLayer()

@property (nonatomic, strong) NSMutableArray *sequence;
@property (nonatomic, strong) NSMutableArray *sequenceSprites;
@property (nonatomic) int currentSequencePosition;
@property (nonatomic) int currentDisplaySequencePosition;
@property (nonatomic) BOOL enableGestures;
@property (nonatomic, strong) CCProgressTimer *timer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeDownRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeUpRecognizer;
-(void)startDisplaySequenceSelector;
-(void)startGameplaySelector;
-(void)displaySequence:(ccTime)deltaTime;
-(void)handleLeftSwipe;
-(void)handleDownSwipe;
-(void)handleRightSwipe;
-(void)handleUpSwipe;
-(void)checkIfSwipeIsCorrect:(DirectionTypes)direction;
-(void)startNewRound;
-(void)playGameOverScene;

@end

@implementation GameLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        [GameManager sharedGameManager].score = 0;
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCSprite *background = [CCSprite spriteWithFile:@"MainMenuBackground.png"];
        background.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:background];
        
        // initialize sequence
        self.currentSequencePosition = 0;
        self.currentDisplaySequencePosition = 0;
        self.sequence = [[NSMutableArray alloc] initWithCapacity:100];
        self.sequenceSprites = [[NSMutableArray alloc] initWithCapacity:100];
        for (int i=0; i<4; i++) {
            self.sequence[i] = [NSNumber numberWithInt:arc4random_uniform(4) + 1];
            NSLog(@"sequence at %i: %@", i, self.sequence[i]);
        }
        
        self.timer = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"funding_bar_hd.png"]];
        self.timer.type = kCCProgressTimerTypeBar;
        self.timer.midpoint = ccp(0, 0.5f);
        self.timer.barChangeRate = ccp(1, 0);
        self.timer.percentage = 100;
        self.timer.position = ccp(screenSize.width/2, screenSize.height * .90f);
        self.timer.scaleX = 0.50f;  // temporary because of HD size
        [self addChild:self.timer z:kProgressZValue tag:kProgressTimerTagValue];
        
        self.enableGestures = NO;
        
        CCLabelBMFont *gameBeginLabel = [CCLabelBMFont labelWithString:@"Game Start" fntFile:@"SpaceVikingFont.fnt"];
        gameBeginLabel.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:gameBeginLabel];
        id labelAction = [CCSpawn actions:[CCScaleBy actionWithDuration:1.0f scale:4], [CCFadeOut actionWithDuration:1.0f], nil];
        
        // display arrows after label disappears
        id action = [CCSequence actions:labelAction, [CCCallFunc actionWithTarget:self selector:@selector(startDisplaySequenceSelector)], nil];
        
        [gameBeginLabel runAction:action];
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

-(void)startDisplaySequenceSelector {
    PLAYSOUNDEFFECT(GONG);
    PLAYSOUNDEFFECT(TEST);
    [self schedule:@selector(displaySequence:) interval:0.4];
}

-(void)startGameplaySelector {
    // hide the sequence of arrows
#warning -- doesn't hide the sprites simultaneously -- use CCSpawn action?
    for (CCSprite *arrowSprite in self.sequenceSprites) {
        arrowSprite.visible = NO;
    }
    
    self.enableGestures = YES;
    [self scheduleUpdate];
}

-(void)displaySequence:(ccTime)deltaTime {
    // display sequence, one arrow at a time
    if (self.currentDisplaySequencePosition < [self.sequenceSprites count]) {
        [self.sequenceSprites[self.currentDisplaySequencePosition] setVisible:YES];
    } else {
#warning -- reuse sprites from a batch
        CCSprite *arrow;
        switch ([self.sequence[self.currentDisplaySequencePosition] intValue]) {
            case kDirectionTypeLeft:
                arrow = [CCSprite spriteWithFile:@"left_arrow.png"];
                break;
            case kDirectionTypeDown:
                arrow = [CCSprite spriteWithFile:@"down_arrow.png"];
                break;
            case kDirectionTypeRight:
                arrow = [CCSprite spriteWithFile:@"right_arrow.png"];
                break;
            case kDirectionTypeUp:
                arrow = [CCSprite spriteWithFile:@"up_arrow.png"];
                break;
            default:
                CCLOG(@"Not a valid sequence direction to display");
                return;
                break;
        }
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        float heightMultiplier = 0.0;
        if ([self.sequenceSprites count] >= 8) {
            heightMultiplier = 2.0;
        } else if ([self.sequenceSprites count] >= 4) {
            heightMultiplier = 1.0;
        }
        
        arrow.position = ccp(screenSize.width*((self.currentDisplaySequencePosition%4)+1)/5, screenSize.height*(3.0/4.0 - heightMultiplier/4.0));
        [self addChild:arrow];
        
        [self.sequenceSprites addObject:arrow];
    }
    
    self.currentDisplaySequencePosition++;
    
    if ([self.sequence count] == self.currentDisplaySequencePosition) {
        // no more sequence to display
        [self unschedule:@selector(displaySequence:)];
        
        id action = [CCSequence actions:[CCDelayTime actionWithDuration:2.0f], [CCCallFunc actionWithTarget:self selector:@selector(startGameplaySelector)], nil];
        [self runAction:action];
    }
}

-(void)handleLeftSwipe {
    [self checkIfSwipeIsCorrect:kDirectionTypeLeft];
}

-(void)handleDownSwipe {
    [self checkIfSwipeIsCorrect:kDirectionTypeDown];
}

-(void)handleRightSwipe {
    [self checkIfSwipeIsCorrect:kDirectionTypeRight];
}

-(void)handleUpSwipe {
    [self checkIfSwipeIsCorrect:kDirectionTypeUp];
}

-(void)checkIfSwipeIsCorrect:(DirectionTypes)direction {
    if (self.enableGestures) {
        if ([self.sequence[self.currentSequencePosition] intValue] == direction) {
            self.currentSequencePosition++;
            CCLOG(@"Correct swipe detected: %i", direction);
        } else {
            CCLOG(@"You lose!");
            [self playGameOverScene];
        }
        
        // check if sequence is complete
        if ([self.sequence count] == (self.currentSequencePosition)) {
            [self startNewRound];
        }
    }
}

-(void)startNewRound {
    self.enableGestures = NO;
    [self unscheduleUpdate];
    self.timer.percentage = 100;
    self.currentSequencePosition = 0;
    self.currentDisplaySequencePosition = 0;
    [GameManager sharedGameManager].score = [self.sequence count];
    
    for (int i=0; i<2; i++) {
        self.sequence[[self.sequenceSprites count] + i] = [NSNumber numberWithInt:arc4random_uniform(4) + 1];
        NSLog(@"sequence at %i: %@", [self.sequenceSprites count] + i, self.sequence[[self.sequenceSprites count] + i]);
    }

    CGSize screenSize = [CCDirector sharedDirector].winSize;
    CCLabelBMFont *newRoundLabel = [CCLabelBMFont labelWithString:@"Nice!" fntFile:@"SpaceVikingFont.fnt"];
    newRoundLabel.position = ccp(screenSize.width/2, screenSize.height/2);
    [self addChild:newRoundLabel];
    id labelAction = [CCSpawn actions:[CCScaleBy actionWithDuration:1.0f scale:4], [CCFadeOut actionWithDuration:1.0f], nil];
    
    // display arrows after label disappears
    id action = [CCSequence actions:labelAction, [CCCallFunc actionWithTarget:self selector:@selector(startDisplaySequenceSelector)], nil];
    
    [newRoundLabel runAction:action];
}

-(void)playGameOverScene {
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeGameOver];
}

-(void)update:(ccTime)deltaTime {
    // placeholder -- scheduleUpdate is indeed working
    self.timer.percentage -= deltaTime*10;
    if (self.timer.percentage <= 0) {
        [self playGameOverScene];
    }
}

@end

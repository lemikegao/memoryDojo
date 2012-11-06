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
#import "Ninja.h"

@interface GameLayer()

@property (nonatomic) BOOL isGamePaused;
@property (nonatomic, strong) Ninja *ninja;
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
-(void)pauseGame;
-(void)pauseAllSchedulerAndActions:(CCNode*)node;
-(void)addPausedMenuItems;
-(void)resumeGame;
-(void)resumeAllSchedulerAndActions:(CCNode*)node;
-(void)confirmRestartGame;
-(void)restartGame;
-(void)goBackToPausedMenu;
-(void)confirmQuitGame;
-(void)quitGame;
-(void)playGameOverScene;

@end

@implementation GameLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        // load texture atlas
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"game_art.plist"];
        
        // do not allow swipe input until sensei performs the sequence
        self.enableGestures = NO;
        
        // game is not paused
        self.isGamePaused = NO;

        [GameManager sharedGameManager].score = 0;
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        // create topBar sprite for height; position screen separator in the middle below the top bar
        CCSprite *topBar = [CCSprite spriteWithSpriteFrameName:@"game_top_bar.png"];
        // save topBar width and height
        CGFloat topBarWidth = topBar.boundingBox.size.width;
        CGFloat topBarHeight = topBar.boundingBox.size.height;
        
        // add game screen separator
        CCSprite *screenSeparator = [CCSprite spriteWithSpriteFrameName:@"game_screen_separator.png"];
        screenSeparator.position = ccp(screenSize.width/2, (screenSize.height - topBar.boundingBox.size.height)/2);
        [self addChild:screenSeparator z:1];
        
        // add top background half
        CCSprite *backgroundTop = [CCSprite spriteWithSpriteFrameName:@"game_bg_top.png"];
        backgroundTop.anchorPoint = ccp(0, 0);
        backgroundTop.position = ccp(0, screenSeparator.position.y + screenSeparator.boundingBox.size.height/2);
        [self addChild:backgroundTop z:-1];
        
        // add top bar on top of background half
        topBar.anchorPoint = ccp(0, 0);
        topBar.position = ccp(0, screenSeparator.position.y + screenSeparator.boundingBox.size.height/2 + backgroundTop.boundingBox.size.height);
        [self addChild:topBar z:5];
        
        // add score to top bar
        CCSprite *scoreLabel = [CCSprite spriteWithSpriteFrameName:@"game_top_score.png"];
        scoreLabel.anchorPoint = ccp(0, 1);
        scoreLabel.position = ccp(topBarWidth * 0.05f, topBarHeight * 0.90f);
        [topBar addChild:scoreLabel z:10];
        
        // reset score to 0
        [GameManager sharedGameManager].score = 0;
        CCLabelBMFont *score = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].score] fntFile:@"Score.fnt"];
        score.anchorPoint = ccp(0, 1);
        score.position = ccp(topBarWidth * 0.05f, topBarHeight * 0.58f);
        [topBar addChild:score z:10];
        
        // add time to top bar
        CCSprite *timeLabel = [CCSprite spriteWithSpriteFrameName:@"game_top_time.png"];
        timeLabel.anchorPoint = ccp(0, 1);
        timeLabel.position = ccp(topBarWidth * 0.30f, topBarHeight * 0.90f);
        [topBar addChild:timeLabel z:10];
        
        self.timer = [CCProgressTimer progressWithSprite:[CCSprite spriteWithSpriteFrameName:@"game_top_time_active.png"]];
        self.timer.type = kCCProgressTimerTypeBar;
        self.timer.anchorPoint = ccp(0, 1);
        self.timer.midpoint = ccp(0, 0.5f);
        self.timer.barChangeRate = ccp(1, 0);
        self.timer.percentage = 100;
        self.timer.position = ccp(topBarWidth * 0.30f, topBarHeight * 0.58f);
        [topBar addChild:self.timer z:10];
        
        // add pause button to top bar
        CCMenuItemImage *pauseGameButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_top_button_pause.png"] selectedSprite:nil target:self selector:@selector(pauseGame)];
        pauseGameButton.anchorPoint = ccp(1, 0.5);
        pauseGameButton.position = ccp(topBarWidth * 0.95f, topBarHeight * 0.50f);
        
        CCMenu *pauseMenu = [CCMenu menuWithItems:pauseGameButton, nil];
        pauseMenu.anchorPoint = ccp(0, 0);
        pauseMenu.position = CGPointZero;
        [topBar addChild:pauseMenu z:10];
        
        // add bottom background half below separator
        CCSprite *backgroundBottom = [CCSprite spriteWithSpriteFrameName:@"game_bg_bottom.png"];
        backgroundBottom.anchorPoint = ccp(0, 1);
        backgroundBottom.position = ccp(0, screenSeparator.position.y - screenSeparator.boundingBox.size.height/2);
        [self addChild:backgroundBottom z:-1];
        
        // initialize ninja
        _ninja = [[Ninja alloc] init];
        _ninja.position = ccp(screenSize.width/2, screenSize.height * 0.27f);
        [self addChild:_ninja z:10];
        
        // initialize sequence
        self.currentSequencePosition = 0;
        self.currentDisplaySequencePosition = 0;
        self.sequence = [[NSMutableArray alloc] initWithCapacity:100];
        self.sequenceSprites = [[NSMutableArray alloc] initWithCapacity:100];
        for (int i=0; i<4; i++) {
            self.sequence[i] = [NSNumber numberWithInt:arc4random_uniform(4) + 1];
            NSLog(@"sequence at %i: %@", i, self.sequence[i]);
        }
        
        // display the rules then start the game!
        CCSprite *gameInstructions = [CCSprite spriteWithSpriteFrameName:@"game_instructions.png"];
        gameInstructions.anchorPoint = ccp(0.5f, 0);
        gameInstructions.position = ccp(screenSize.width/2, topBar.position.y);
        [self addChild:gameInstructions z:1 tag:kGameInstructionsTagValue];
        
        // display sequence after label disappears
        id moveGameInstructionsDown = [CCMoveTo actionWithDuration:1.5f position:ccp(screenSize.width/2, screenSize.height * 0.70f)];
        id pauseGameInstructions = [CCDelayTime actionWithDuration:2.0f];
        id moveGameInstructionsUp = [CCMoveTo actionWithDuration:1.5f position:ccp(screenSize.width/2, topBar.position.y)];
        id callStartDisplaySequenceSelector = [CCCallFunc actionWithTarget:self selector:@selector(startDisplaySequenceSelector)];
        
        id action = [CCSequence actions:moveGameInstructionsDown, pauseGameInstructions, moveGameInstructionsUp, callStartDisplaySequenceSelector, nil];
        [gameInstructions runAction:action];
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
    // remove instructions
    [self removeChildByTag:kGameInstructionsTagValue cleanup:YES];
    PLAYSOUNDEFFECT(GONG);
    [self scheduleUpdate];  // temp
//    [self schedule:@selector(displaySequence:) interval:0.4]; // uncomment for real game
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
    if (self.enableGestures && !self.isGamePaused) {
        [self checkIfSwipeIsCorrect:kDirectionTypeLeft];
        [self.ninja changeState:kCharacterStateLeft];
    }
}

-(void)handleDownSwipe {
    if (self.enableGestures && !self.isGamePaused) {
        [self checkIfSwipeIsCorrect:kDirectionTypeDown];
        [self.ninja changeState:kCharacterStateDown];
    }
}

-(void)handleRightSwipe {
    if (self.enableGestures && !self.isGamePaused) {
        [self checkIfSwipeIsCorrect:kDirectionTypeRight];
        [self.ninja changeState:kCharacterStateRight];
    }
}

-(void)handleUpSwipe {
    if (self.enableGestures && !self.isGamePaused) {
        [self checkIfSwipeIsCorrect:kDirectionTypeUp];
        [self.ninja changeState:kCharacterStateUp];
    }
}

-(void)checkIfSwipeIsCorrect:(DirectionTypes)direction {
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

-(void)pauseGame {
    if (self.isGamePaused == NO) {
        self.isGamePaused = YES;
        [self pauseSchedulerAndActions];
        for (CCNode *node in [self children]) {
            [self pauseAllSchedulerAndActions:node];
        }
        
        // show paused menu
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        CCSprite *pausedBg = [CCSprite spriteWithSpriteFrameName:@"game_paused_bg.png"];
        pausedBg.position = ccp(screenSize.width/2, screenSize.height/2);
        [self addChild:pausedBg z:100 tag:kGamePausedBgTagValue];
        [self addPausedMenuItems];
    }
}

-(void)pauseAllSchedulerAndActions:(CCNode*)node {
    [node pauseSchedulerAndActions];
    for (CCNode *nodeChild in [node children]) {
        if (nodeChild.children) {
            [self pauseAllSchedulerAndActions:nodeChild];
        } else {
            [nodeChild pauseSchedulerAndActions];
        }
    }
}

-(void)addPausedMenuItems {
    CCSprite *pausedBg = (CCSprite*)[self getChildByTag:kGamePausedBgTagValue];
    
    CGFloat pausedBgHeight = pausedBg.boundingBox.size.height;
    CGFloat pausedBgWidth = pausedBg.boundingBox.size.width;
    
    // add game paused label
    CCSprite *pausedText = [CCSprite spriteWithSpriteFrameName:@"game_paused_text.png"];
    pausedText.position = ccp(pausedBgWidth/2, pausedBgHeight * 0.88f);
    [pausedBg addChild:pausedText];
    
    // add game paused separator
    CCSprite *pausedSeparator = [CCSprite spriteWithSpriteFrameName:@"game_paused_line.png"];
    pausedSeparator.position = ccp(pausedBgWidth * 0.55f, pausedBgHeight * 0.77f);
    [pausedBg addChild:pausedSeparator];
    
    // create game paused resume button
    CCMenuItemImage *pausedResumeButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_resume.png"] selectedSprite:nil target:self selector:@selector(resumeGame)];
    pausedResumeButton.anchorPoint = ccp(0, 0.5f);
    
    // create game paused restart button
    CCMenuItemImage *pausedRestartButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_restart.png"] selectedSprite:nil target:self selector:@selector(confirmRestartGame)];
    pausedRestartButton.anchorPoint = ccp(0, 0.5f);
    
    CCMenuItemImage *pausedQuitButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_quit.png"] selectedSprite:nil target:self selector:@selector(confirmQuitGame)];
    pausedQuitButton.anchorPoint = ccp(0, 0.5f);
    
    CCMenu *pausedMenu = [CCMenu menuWithItems:pausedResumeButton, pausedRestartButton, pausedQuitButton, nil];
    [pausedMenu alignItemsVerticallyWithPadding:pausedBgHeight * 0.085f];
    pausedMenu.anchorPoint = ccp(0, 0.5);
    pausedMenu.position = ccp(pausedBgWidth * 0.23f, pausedBgHeight * 0.44f);
    [pausedBg addChild:pausedMenu z:10];
}

-(void)resumeGame {
    if (self.isGamePaused == YES) {
        self.isGamePaused = NO;
        [self resumeSchedulerAndActions];
        for (CCNode *node in [self children]) {
            [self resumeAllSchedulerAndActions:node];
        }
    }
    
    // remove paused menu from self
    [self removeChildByTag:kGamePausedBgTagValue cleanup:YES];
}

-(void)resumeAllSchedulerAndActions:(CCNode*)node {
    [node resumeSchedulerAndActions];
    for (CCNode *nodeChild in [node children]) {
        if (nodeChild.children) {
            [self resumeAllSchedulerAndActions:nodeChild];
        } else {
            [nodeChild resumeSchedulerAndActions];
        }
    }
}

-(void)confirmRestartGame {
    CCSprite *pausedBg = (CCSprite*)[self getChildByTag:kGamePausedBgTagValue];
    CGFloat pausedBgWidth = pausedBg.boundingBox.size.width;
    CGFloat pausedBgHeight = pausedBg.boundingBox.size.height;
    
    // remove all children from pausedBg first
    [pausedBg removeAllChildrenWithCleanup:YES];
    
    // add restart confirmation text
    CCSprite *pausedRestartConfirmation = [CCSprite spriteWithSpriteFrameName:@"game_paused_restartconfirmation_text.png"];
    pausedRestartConfirmation.position = ccp(pausedBgWidth/2, pausedBgHeight * 0.73f);
    [pausedBg addChild:pausedRestartConfirmation];
    
    // add no or yes options
    CCMenuItemImage *pausedButtonNo = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_no.png"] selectedSprite:nil target:self selector:@selector(goBackToPausedMenu)];
    pausedButtonNo.anchorPoint = ccp(0.5f, 0);
    
    CCMenuItemImage *pausedButtonYes = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_yes.png"] selectedSprite:nil target:self selector:@selector(restartGame)];
    pausedButtonYes.anchorPoint = ccp(0.5f, 0);
    
    CCMenu *pausedMenuRestartConfirmation = [CCMenu menuWithItems:pausedButtonNo, pausedButtonYes, nil];
    [pausedMenuRestartConfirmation alignItemsHorizontallyWithPadding:pausedBgWidth * 0.2f];
    pausedMenuRestartConfirmation.anchorPoint = ccp(0.5f, 0);
    pausedMenuRestartConfirmation.position = ccp(pausedBgWidth * 0.5f, pausedBgHeight * 0.30f);
    [pausedBg addChild:pausedMenuRestartConfirmation z:10];
}

-(void)restartGame {
    
}

-(void)goBackToPausedMenu {
    
}

-(void)confirmQuitGame {
    
}

-(void)quitGame {
    
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

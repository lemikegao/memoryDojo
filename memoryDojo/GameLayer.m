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
#import "Sensei.h"

@interface GameLayer()

@property (nonatomic) BOOL isGamePaused;
@property (nonatomic, strong) Ninja *ninja;
@property (nonatomic, strong) Sensei *sensei;
@property (nonatomic) int roundNumber;
@property (nonatomic, strong) CCLabelBMFont *scoreLabel;
@property (nonatomic, strong) NSMutableArray *sequence;
@property (nonatomic) int currentSequencePosition;
@property (nonatomic) int currentDisplaySequencePosition;
@property (nonatomic) BOOL enableGestures;
@property (nonatomic, strong) CCProgressTimer *timer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeLeftRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeDownRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeRightRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeUpRecognizer;
-(void)initializeGame;
-(void)removeInstructions;
-(void)removeRoundPopup:(CCSprite*)roundBg;
-(void)displaySequence:(ccTime)deltaTime;
-(void)handleLeftSwipe;
-(void)handleDownSwipe;
-(void)handleRightSwipe;
-(void)handleUpSwipe;
-(void)checkIfSwipeIsCorrect:(DirectionTypes)direction;
-(void)startNewRound;
-(void)showRoundLabelAfterNiceMessage;
-(void)pauseGame;
-(void)pauseAllSchedulerAndActions:(CCNode*)node;
-(void)addPausedMenuItems;
-(void)resumeGame;
-(void)resumeAllSchedulerAndActions:(CCNode*)node;
-(void)confirmRestartGame;
-(void)goBackToPausedMenu;
-(void)restartGame;
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
        [self initializeGame];
    }
    
    return self;
}

-(void)initializeGame {
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
    CCSprite *scoreText = [CCSprite spriteWithSpriteFrameName:@"game_top_score.png"];
    scoreText.anchorPoint = ccp(0, 1);
    scoreText.position = ccp(topBarWidth * 0.05f, topBarHeight * 0.90f);
    [topBar addChild:scoreText z:10];
    
    // reset score to 0
    [GameManager sharedGameManager].score = 0;
    self.scoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].score] fntFile:@"Score.fnt"];
    self.scoreLabel.anchorPoint = ccp(0, 1);
    self.scoreLabel.position = ccp(topBarWidth * 0.05f, topBarHeight * 0.58f);
    [topBar addChild:self.scoreLabel z:10];
    
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
    CCMenuItemImage *pauseGameButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_top_button_pause.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_top_button_pause_pressed.png"] target:self selector:@selector(pauseGame)];
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
    self.ninja = [[Ninja alloc] init];
    self.ninja.position = ccp(screenSize.width/2, screenSize.height * 0.27f);
    [self addChild:self.ninja z:1];
    
    // initialize sensei
    self.sensei = [[Sensei alloc] init];
    self.sensei.position = ccp(screenSize.width/2, screenSize.height * 0.66f);
    [self addChild:self.sensei z:1];
    
    // initialize sequence
    self.currentSequencePosition = 0;
    self.currentDisplaySequencePosition = 0;
    self.sequence = [[NSMutableArray alloc] initWithCapacity:100];
    for (int i=0; i<4; i++) {
        self.sequence[i] = [NSNumber numberWithInt:arc4random_uniform(4) + 1];
        NSLog(@"sequence at %i: %@", i, self.sequence[i]);
    }
    
    self.roundNumber = 1;
    
    // display the rules then start the game!
    CCSprite *gameInstructions = [CCSprite spriteWithSpriteFrameName:@"game_instructions.png"];
    gameInstructions.anchorPoint = ccp(0.5f, 0);
    gameInstructions.position = ccp(screenSize.width/2, topBar.position.y);
    [self addChild:gameInstructions z:2 tag:kGameInstructionsTagValue];
    
    // display sequence after label disappears
    id moveGameInstructionsDown = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width/2, screenSize.height * 0.60f)];
    id pauseGameInstructions = [CCDelayTime actionWithDuration:3.0f];
    id moveGameInstructionsUp = [CCMoveTo actionWithDuration:0.5f position:ccp(screenSize.width/2, topBar.position.y)];
    id removeInstructions = [CCCallFunc actionWithTarget:self selector:@selector(removeInstructions)];
    id callStartDisplaySequenceSelector = [CCCallFunc actionWithTarget:self selector:@selector(startDisplaySequenceSelector)];
    
    id action = [CCSequence actions:moveGameInstructionsDown, pauseGameInstructions, moveGameInstructionsUp, removeInstructions, callStartDisplaySequenceSelector, nil];
    [gameInstructions runAction:action];
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

-(void)removeInstructions {
    [self removeChildByTag:kGameInstructionsTagValue cleanup:YES];
}

-(void)removeRoundPopup:(CCSprite*)roundBg {
    [roundBg removeAllChildrenWithCleanup:YES];
    [self removeChild:roundBg cleanup:YES];
}

-(void)startDisplaySequenceSelector {
//    PLAYSOUNDEFFECT(GONG);
    [self schedule:@selector(displaySequence:) interval:0.8];
}

-(void)displaySequence:(ccTime)deltaTime {
    switch ([self.sequence[self.currentDisplaySequencePosition] intValue]) {
        case kDirectionTypeLeft:
            [self.sensei changeState:kCharacterStateLeft];
            break;
        case kDirectionTypeDown:
            [self.sensei changeState:kCharacterStateDown];
            break;
        case kDirectionTypeRight:
            [self.sensei changeState:kCharacterStateRight];
            break;
        case kDirectionTypeUp:
            [self.sensei changeState:kCharacterStateUp];
            break;
        default:
            CCLOG(@"Not a valid sequence direction to display");
            return;
            break;
    }
    
    self.currentDisplaySequencePosition++;
    
    if ([self.sequence count] == self.currentDisplaySequencePosition) {
        // no more sequence to display
        [self unschedule:@selector(displaySequence:)];
        
        // start gameplay
        
        self.enableGestures = YES;
        [self scheduleUpdate];
    }
}

-(void)handleLeftSwipe {
    if (self.enableGestures && !self.isGamePaused) {
        [self.ninja changeState:kCharacterStateLeft];
        [self checkIfSwipeIsCorrect:kDirectionTypeLeft];
    }
}

-(void)handleDownSwipe {
    if (self.enableGestures && !self.isGamePaused) {
        [self.ninja changeState:kCharacterStateDown];
        [self checkIfSwipeIsCorrect:kDirectionTypeDown];
    }
}

-(void)handleRightSwipe {
    if (self.enableGestures && !self.isGamePaused) {
        [self.ninja changeState:kCharacterStateRight];
        [self checkIfSwipeIsCorrect:kDirectionTypeRight];
    }
}

-(void)handleUpSwipe {
    if (self.enableGestures && !self.isGamePaused) {
        [self.ninja changeState:kCharacterStateUp];
        [self checkIfSwipeIsCorrect:kDirectionTypeUp];
    }
}

-(void)checkIfSwipeIsCorrect:(DirectionTypes)direction {
    if ([self.sequence[self.currentSequencePosition] intValue] == direction) {
        self.currentSequencePosition++;
        CCLOG(@"Correct swipe detected: %i", direction);
        [GameManager sharedGameManager].score++;
        self.scoreLabel.string = [NSString stringWithFormat:@"%i", [GameManager sharedGameManager].score];
    } else {
        CCLOG(@"You lose!");
        [self playGameOverScene];
    }
    
    // check if sequence is complete
    if ([self.sequence count] == (self.currentSequencePosition)) {
        int ninjaLevel = [GameManager sharedGameManager].ninjaLevel;
        BOOL shouldLevelUp = NO;
        switch (self.roundNumber) {
            case kGameLevel2Round:
                if (ninjaLevel == 1) {
                    shouldLevelUp = YES;
                }
                break;
                
            case kGameLevel3Round:
                if (ninjaLevel == 1) {
                    shouldLevelUp = YES;
                }
                break;
                
            case kGameLevel4Round:
                if (ninjaLevel == 1) {
                    shouldLevelUp = YES;
                }
                break;
                
            case kGameLevel5Round:
                if (ninjaLevel == 1) {
                    shouldLevelUp = YES;
                }
                break;
                
            case kGameLevel6Round:
                if (ninjaLevel == 1) {
                    shouldLevelUp = YES;
                }
                break;
                
            default:
                break;
        }
        
        if (shouldLevelUp == YES) {
            [self ninjaLevelUp];
        } else {
            [self startNewRound];
        }
    }
}

-(void)ninjaLevelUp {
    // stop gameplay
    self.enableGestures = NO;
    [self unscheduleUpdate];
    
    // increase ninja level
    [GameManager sharedGameManager].ninjaLevel++;
    int ninjaLevel = [GameManager sharedGameManager].ninjaLevel;
    
    // add background color layer first
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    CCLayerColor *levelUpBg = [CCLayerColor layerWithColor:ccc4(30, 30, 30, 255) width:screenSize.width height:screenSize.height];
    [self addChild:levelUpBg z:150];
    
    // add rays to sprite batch node
    CGPoint screenMidpoint = ccp(screenSize.width/2, screenSize.height/2);
    CCSpriteBatchNode *rayBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"game_art.pvr.ccz"];
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
    
    [levelUpBg addChild:rayBatchNode z:1];
    
    // spin the ray batch node
//    id rotateRayAction = [CCRepeatForever actionWithAction:[CCSequence actions:[CCDelayTime actionWithDuration:0.1f], [CCRotateBy actionWithDuration:0.1f angle:10], nil]];
    id rotateRayAction = [CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:1 angle:40]];
    [rayBatchNode runAction:rotateRayAction];
    
    // add level up message bg
    CCSprite *levelUpMessageBg = [CCSprite spriteWithSpriteFrameName:@"game_transition_message_bg.png"];
    levelUpMessageBg.position = screenMidpoint;
    [levelUpBg addChild:levelUpMessageBg z:2];
    
    CGSize levelUpMessageBgSize = levelUpMessageBg.boundingBox.size;
    
    // add level up message header
    CCLabelBMFont *levelUpMessageHeader = [CCLabelBMFont labelWithString:@"HEY LOOK!" fntFile:@"game_levelup_header.fnt"];
    levelUpMessageHeader.position = ccp(levelUpMessageBgSize.width/2, levelUpMessageBgSize.height * 0.70f);
    [levelUpMessageBg addChild:levelUpMessageHeader];
}

-(void)startNewRound {
    self.enableGestures = NO;
    [self unscheduleUpdate];
    self.timer.percentage = 100;
    self.currentSequencePosition = 0;
    self.currentDisplaySequencePosition = 0;
    
    int currentSequenceLength = [self.sequence count];
    for (int i=0; i<2; i++) {
        self.sequence[currentSequenceLength + i] = [NSNumber numberWithInt:arc4random_uniform(4) + 1];
        NSLog(@"sequence at %i: %@", currentSequenceLength + i, self.sequence[currentSequenceLength + i]);
    }

    // show new round indicator
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    CCSprite *roundBg = [CCSprite spriteWithSpriteFrameName:@"game_rounds_bg.png"];
    roundBg.position = ccp(screenSize.width/2, screenSize.height/2);
    [self addChild:roundBg z:100 tag:kGameRoundBgTagValue];
    
    // add 'nice!' message if player finished round 1
    if (self.roundNumber == 1) {
        CCLabelBMFont *niceLabel = [CCLabelBMFont labelWithString:@"Nice!" fntFile:@"Round.fnt"];
        niceLabel.position = ccp(roundBg.boundingBox.size.width/2, roundBg.boundingBox.size.height/2);
        [roundBg addChild:niceLabel];
        id niceLabelBgAction = [CCFadeIn actionWithDuration:1.0f];
        id niceLabelAction = [CCSequence actions:[CCFadeIn actionWithDuration:1.0f], [CCDelayTime actionWithDuration:1.0f], [CCFadeOut actionWithDuration:1.0f], [CCCallFunc actionWithTarget:self selector:@selector(showRoundLabelAfterNiceMessage)], nil];
        [roundBg runAction:niceLabelBgAction];
        [niceLabel runAction:niceLabelAction];
    } else {
        CCLabelBMFont *newRoundLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Round %i", self.roundNumber] fntFile:@"Round.fnt"];
        newRoundLabel.position = ccp(roundBg.boundingBox.size.width/2, roundBg.boundingBox.size.height/2);
        [roundBg addChild:newRoundLabel];
        
        
        id labelAction = [CCSequence actions:[CCFadeIn actionWithDuration:1.0f], [CCDelayTime actionWithDuration:2.0f], [CCFadeOut actionWithDuration:1.0f], nil];
        
        // have sensei perform new sequence
        id labelBgAction = [CCSequence actions:[CCFadeIn actionWithDuration:1.0f], [CCDelayTime actionWithDuration:2.0f], [CCFadeOut actionWithDuration:1.0f], [CCCallFuncN actionWithTarget:self selector:@selector(removeRoundPopup:)], [CCCallFunc actionWithTarget:self selector:@selector(startDisplaySequenceSelector)], nil];
        
        [newRoundLabel runAction:labelAction];
        [roundBg runAction:labelBgAction];
    }
    
    self.roundNumber++;
}

-(void)showRoundLabelAfterNiceMessage {
    CCSprite *roundBg = (CCSprite*)[self getChildByTag:kGameRoundBgTagValue];
    
    CCLabelBMFont *newRoundLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Round %i", self.roundNumber] fntFile:@"Round.fnt"];
    newRoundLabel.position = ccp(roundBg.boundingBox.size.width/2, roundBg.boundingBox.size.height/2);
    [roundBg addChild:newRoundLabel];
    
    
    id labelAction = [CCSequence actions:[CCFadeIn actionWithDuration:1.0f], [CCDelayTime actionWithDuration:2.0f], [CCFadeOut actionWithDuration:1.0f], nil];
    
    // have sensei perform new sequence
    id labelBgAction = [CCSequence actions:[CCDelayTime actionWithDuration:3.0f], [CCFadeOut actionWithDuration:1.0f], [CCCallFuncN actionWithTarget:self selector:@selector(removeRoundPopup:)], [CCCallFunc actionWithTarget:self selector:@selector(startDisplaySequenceSelector)], nil];
    
    [newRoundLabel runAction:labelAction];
    [roundBg runAction:labelBgAction];
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
    CCMenuItemImage *pausedResumeButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_resume.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_resume_pressed.png"] target:self selector:@selector(resumeGame)];
    pausedResumeButton.anchorPoint = ccp(0, 0.5f);
    
    // create game paused restart button
    CCMenuItemImage *pausedRestartButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_restart.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_restart_pressed.png"] target:self selector:@selector(confirmRestartGame)];
    pausedRestartButton.anchorPoint = ccp(0, 0.5f);
    
    CCMenuItemImage *pausedQuitButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_quit.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_quit_pressed.png"] target:self selector:@selector(confirmQuitGame)];
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
    CCMenuItemImage *pausedButtonNo = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_no.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_no_pressed.png"] target:self selector:@selector(goBackToPausedMenu)];
    pausedButtonNo.anchorPoint = ccp(0.5f, 0);
    
    CCMenuItemImage *pausedButtonYes = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_yes.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_yes_pressed.png"] target:self selector:@selector(restartGame)];
    pausedButtonYes.anchorPoint = ccp(0.5f, 0);
    
    CCMenu *pausedMenuRestartConfirmation = [CCMenu menuWithItems:pausedButtonNo, pausedButtonYes, nil];
    [pausedMenuRestartConfirmation alignItemsHorizontallyWithPadding:pausedBgWidth * 0.2f];
    pausedMenuRestartConfirmation.anchorPoint = ccp(0.5f, 0);
    pausedMenuRestartConfirmation.position = ccp(pausedBgWidth * 0.5f, pausedBgHeight * 0.30f);
    [pausedBg addChild:pausedMenuRestartConfirmation z:10];
}

-(void)goBackToPausedMenu {
    CCSprite *pausedBg = (CCSprite*)[self getChildByTag:kGamePausedBgTagValue];
    [pausedBg removeAllChildrenWithCleanup:YES];
    
    [self addPausedMenuItems];
}

-(void)restartGame {
    [self unscheduleAllSelectors];
    [self removeAllChildrenWithCleanup:YES];
    [self initializeGame];
}

-(void)confirmQuitGame {
    CCSprite *pausedBg = (CCSprite*)[self getChildByTag:kGamePausedBgTagValue];
    CGFloat pausedBgWidth = pausedBg.boundingBox.size.width;
    CGFloat pausedBgHeight = pausedBg.boundingBox.size.height;
    
    // remove all children from pausedBg first
    [pausedBg removeAllChildrenWithCleanup:YES];
    
    // add restart confirmation text
    CCSprite *pausedQuitConfirmation = [CCSprite spriteWithSpriteFrameName:@"game_paused_quitconfirmation_text.png"];
    pausedQuitConfirmation.position = ccp(pausedBgWidth/2, pausedBgHeight * 0.73f);
    [pausedBg addChild:pausedQuitConfirmation];
    
    // add no or yes options
    CCMenuItemImage *pausedButtonNo = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_no.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_no_pressed.png"] target:self selector:@selector(goBackToPausedMenu)];
    pausedButtonNo.anchorPoint = ccp(0.5f, 0);
    
    CCMenuItemImage *pausedButtonYes = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_yes.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"game_paused_button_yes_pressed.png"] target:self selector:@selector(quitGame)];
    pausedButtonYes.anchorPoint = ccp(0.5f, 0);
    
    CCMenu *pausedMenuRestartConfirmation = [CCMenu menuWithItems:pausedButtonNo, pausedButtonYes, nil];
    [pausedMenuRestartConfirmation alignItemsHorizontallyWithPadding:pausedBgWidth * 0.2f];
    pausedMenuRestartConfirmation.anchorPoint = ccp(0.5f, 0);
    pausedMenuRestartConfirmation.position = ccp(pausedBgWidth * 0.5f, pausedBgHeight * 0.30f);
    [pausedBg addChild:pausedMenuRestartConfirmation z:10];
}

-(void)quitGame {
    // go back to main menu
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMainMenu];
}

-(void)playGameOverScene {
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeGameOver];
}

-(void)update:(ccTime)deltaTime {
    [self.ninja updateStateWithDeltaTime:deltaTime andListOfGameObjects:nil];
    [self.sensei updateStateWithDeltaTime:deltaTime andListOfGameObjects:nil];
    
    self.timer.percentage -= deltaTime*10;
    if (self.timer.percentage <= 0) {
        [self playGameOverScene];
    }
}

@end

//
//  MainMenuNinja.m
//  memoryDojo
//
//  Created by Michael Gao on 11/6/12.
//
//

#import "MainMenuNinja.h"

@interface MainMenuNinja ()

@property (nonatomic, strong) CCSprite *ninjaOpenEyes;
@property (nonatomic) BOOL isNinjaBlinking;
@property (nonatomic, strong) CCAnimation *blinkingAnim;
@property (nonatomic) float secondsStayingIdle;
-(void)initAnimations;

@end

@implementation MainMenuNinja

-(id)init {
    self = [super initWithSpriteFrameName:@"mainmenu_ninja_up_repeat.png"];
    if (self != nil) {
        [self initAnimations];
        self.gameObjectType = kGameObjectTypeNinja;
        self.characterState = kCharacterStateIdle;
        self.isNinjaBlinking = NO;
        
        // add eyes
        self.ninjaOpenEyes = [CCSprite spriteWithSpriteFrameName:@"mainmenu_ninja_eyes_1.png"];
        self.ninjaOpenEyes.position = ccp(self.boundingBox.size.width * 0.455f, self.boundingBox.size.height * 0.63f);
        [self addChild:self.ninjaOpenEyes z:100];
    }
    
    return self;
}

-(void)initAnimations {
    self.blinkingAnim = [self loadPlistForAnimationWithName:@"blinkingAnim" andClassName:NSStringFromClass([self class])];
    self.blinkingAnim.restoreOriginalFrame = YES;
}

-(void)changeState:(CharacterStates)newState {
    [self stopAllActions];
    id action = nil;
    CharacterStates oldState = self.characterState;
    self.characterState = newState;
    self.secondsStayingIdle = 0;
    
    // adjust ninja eyes
    if (newState == kCharacterStateDown) {
        self.ninjaOpenEyes.position = ccp(self.boundingBox.size.width * 0.455f, self.boundingBox.size.height * 0.59f);
    } else {
        self.ninjaOpenEyes.position = ccp(self.boundingBox.size.width * 0.455f, self.boundingBox.size.height * 0.63f);
    }
    
    switch (newState) {
        case kCharacterStateIdle:
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_ninja_up_repeat.png"];
            break;
            
        case kCharacterStateLeft:
            // perform repeat action
            if (oldState == newState) {
                NSArray *repeatFrames = [NSArray arrayWithObjects:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_ninja_left_repeat.png"], [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_ninja_left.png"], nil];
                CCAnimation *repeatAnimation = [CCAnimation animationWithSpriteFrames:repeatFrames delay:0.1f];
                repeatAnimation.loops = 1;
                
                action = [CCAnimate actionWithAnimation:repeatAnimation];
            } else {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_ninja_left.png"];
            }
            break;
            
        case kCharacterStateDown:
            // perform repeat action
            if (oldState == newState) {
                NSArray *repeatFrames = [NSArray arrayWithObjects:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_ninja_down_repeat.png"], [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_ninja_down.png"], nil];
                CCAnimation *repeatAnimation = [CCAnimation animationWithSpriteFrames:repeatFrames delay:0.08f];
                repeatAnimation.loops = 1;
                
                id moveEyesAction = [CCSequence actions:[CCCallFunc actionWithTarget:self selector:@selector(moveEyesDownRepeat)], [CCDelayTime actionWithDuration:0.08f], [CCCallFunc actionWithTarget:self selector:@selector(moveEyesDown)], nil];
                action = [CCSpawn actions:moveEyesAction, [CCAnimate actionWithAnimation:repeatAnimation], nil];
            } else {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_ninja_down.png"];
            }
            break;
            
        case kCharacterStateRight:
            // perform repeat action
            if (oldState == newState) {
                NSArray *repeatFrames = [NSArray arrayWithObjects:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_ninja_right_repeat.png"], [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_ninja_right.png"], nil];
                CCAnimation *repeatAnimation = [CCAnimation animationWithSpriteFrames:repeatFrames delay:0.1f];
                repeatAnimation.loops = 1;
                
                action = [CCAnimate actionWithAnimation:repeatAnimation];
            } else {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_ninja_right.png"];
            }
            break;
            
        case kCharacterStateUp:
            // perform repeat action
            if (oldState == newState) {
                NSArray *repeatFrames = [NSArray arrayWithObjects:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_ninja_up_repeat.png"], [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_ninja_up.png"], nil];
                CCAnimation *repeatAnimation = [CCAnimation animationWithSpriteFrames:repeatFrames delay:0.1f];
                repeatAnimation.loops = 1;
                
                action = [CCAnimate actionWithAnimation:repeatAnimation];
            } else {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mainmenu_ninja_up.png"];
            }
            break;
            
        default:
            CCLOG(@"Unhandled state %d in Ninja", newState);
            break;
    }
    
    if (action != nil) {
        [self runAction:action];
    }
}

-(void)moveEyesDownRepeat {
    self.ninjaOpenEyes.position = ccp(self.boundingBox.size.width * 0.455f, self.boundingBox.size.height * 0.62f);
}

-(void)moveEyesDown {
    self.ninjaOpenEyes.position = ccp(self.boundingBox.size.width * 0.455f, self.boundingBox.size.height * 0.59f);
}

-(void)blink {
    self.isNinjaBlinking = YES;
    id blinkAction = [CCSequence actions:[CCAnimate actionWithAnimation:self.blinkingAnim], [CCDelayTime actionWithDuration:2.0f], [CCCallFunc actionWithTarget:self selector:@selector(stopBlinking)], nil];
    [self.ninjaOpenEyes runAction:blinkAction];
}

-(void)stopBlinking {
    self.isNinjaBlinking = NO;
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects {
    // blink every 2 seconds when idle
    self.secondsStayingIdle = self.secondsStayingIdle + deltaTime;
    if (self.secondsStayingIdle > 2.0f && self.isNinjaBlinking == NO) {
        [self blink];
    }
}

@end

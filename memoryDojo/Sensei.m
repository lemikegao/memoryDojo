//
//  Sensei.m
//  memoryDojo
//
//  Created by Michael Gao on 11/6/12.
//
//

#import "Sensei.h"

@interface Sensei()

@property (nonatomic, strong) CCSprite *senseiOpenEyes;
@property (nonatomic, strong) CCAnimation *blinkingAnim;
-(void)initAnimations;

@end

@implementation Sensei

-(id)init {
    self = [super initWithSpriteFrameName:@"game_sensei_up_repeat.png"];
    if (self != nil) {
        [self initAnimations];
        self.gameObjectType = kGameObjectTypeSensei;
        self.characterState = kCharacterStateIdle;
        
        // add eyes
        self.senseiOpenEyes = [CCSprite spriteWithSpriteFrameName:@"game_ninja_eyes_1.png"];
        self.senseiOpenEyes.position = ccp(self.boundingBox.size.width * 0.51f, self.boundingBox.size.height * 0.65f);
        [self addChild:self.senseiOpenEyes z:100];
        
        // initialize blinking
#warning -- change blinking so that the timer begins if player is IDLE (blink after 1 sec of idleness)
        
        id blinkAction = [CCRepeatForever actionWithAction:[CCSequence actions:[CCAnimate actionWithAnimation:self.blinkingAnim], [CCDelayTime actionWithDuration:2.0f], nil]];
        [self.senseiOpenEyes runAction:blinkAction];
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
    
    // adjust sensei eyes
    if (newState == kCharacterStateDown) {
        self.senseiOpenEyes.position = ccp(self.boundingBox.size.width * 0.51f, self.boundingBox.size.height * 0.605f);
    } else {
        self.senseiOpenEyes.position = ccp(self.boundingBox.size.width * 0.51f, self.boundingBox.size.height * 0.65f);
    }
    
    switch (newState) {
        case kCharacterStateIdle:
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_up_repeat.png"];
            break;
            
        case kCharacterStateLeft:
            // perform repeat action
            if (oldState == newState) {
                NSArray *repeatFrames = [NSArray arrayWithObjects:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_left_repeat.png"], [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_left.png"], nil];
                CCAnimation *repeatAnimation = [CCAnimation animationWithSpriteFrames:repeatFrames delay:0.1f];
                repeatAnimation.loops = 1;
                
                action = [CCAnimate actionWithAnimation:repeatAnimation];
            } else {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_left.png"];
            }
            break;
            
        case kCharacterStateDown:
            // perform repeat action
            if (oldState == newState) {
                NSArray *repeatFrames = [NSArray arrayWithObjects:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_down_repeat.png"], [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_down.png"], nil];
                CCAnimation *repeatAnimation = [CCAnimation animationWithSpriteFrames:repeatFrames delay:0.08f];
                repeatAnimation.loops = 1;
            
                id moveEyesAction = [CCSequence actions:[CCCallFunc actionWithTarget:self selector:@selector(moveEyesDownRepeat)], [CCDelayTime actionWithDuration:0.08f], [CCCallFunc actionWithTarget:self selector:@selector(moveEyesDown)], nil];
                action = [CCSpawn actions:moveEyesAction, [CCAnimate actionWithAnimation:repeatAnimation], nil];
            } else {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_down.png"];
            }
            break;
            
        case kCharacterStateRight:
            // perform repeat action
            if (oldState == newState) {
                NSArray *repeatFrames = [NSArray arrayWithObjects:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_right_repeat.png"], [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_right.png"], nil];
                CCAnimation *repeatAnimation = [CCAnimation animationWithSpriteFrames:repeatFrames delay:0.1f];
                repeatAnimation.loops = 1;
                
                action = [CCAnimate actionWithAnimation:repeatAnimation];
            } else {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_right.png"];
            }
            break;
            
        case kCharacterStateUp:
            // perform repeat action
            if (oldState == newState) {
                NSArray *repeatFrames = [NSArray arrayWithObjects:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_up_repeat.png"], [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_up.png"], nil];
                CCAnimation *repeatAnimation = [CCAnimation animationWithSpriteFrames:repeatFrames delay:0.1f];
                repeatAnimation.loops = 1;
                
                action = [CCAnimate actionWithAnimation:repeatAnimation];
            } else {
                self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_sensei_up.png"];
            }
            break;
            
        default:
            CCLOG(@"Unhandled state %d in Sensei", newState);
            break;
    }
    
    if (action != nil) {
        [self runAction:action];
    }
}

-(void)moveEyesDownRepeat {
    self.senseiOpenEyes.position = ccp(self.boundingBox.size.width * 0.51f, self.boundingBox.size.height * 0.63f);
}

-(void)moveEyesDown {
    self.senseiOpenEyes.position = ccp(self.boundingBox.size.width * 0.51f, self.boundingBox.size.height * 0.605f);
}

@end
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
@property (nonatomic, strong) CCAnimation *blinkingAnim;
-(void)initAnimations;

@end

@implementation MainMenuNinja

-(id)init {
    self = [super initWithSpriteFrameName:@"mainmenu_ninja.png"];
    if (self != nil) {
        [self initAnimations];
        self.gameObjectType = kGameObjectTypeNinja;
        self.characterState = kCharacterStateIdle;
        
        // add eyes
        self.ninjaOpenEyes = [CCSprite spriteWithSpriteFrameName:@"mainmenu_ninja_eyes_1.png"];
        self.ninjaOpenEyes.position = ccp(self.boundingBox.size.width * 0.455f, self.boundingBox.size.height * 0.63f);
        [self addChild:self.ninjaOpenEyes z:100];
        
        // initialize blinking
#warning -- change blinking so that the timer begins if player is IDLE (blink after 1 sec of idleness)
        
        id blinkAction = [CCRepeatForever actionWithAction:[CCSequence actions:[CCAnimate actionWithAnimation:self.blinkingAnim], [CCDelayTime actionWithDuration:2.0f], nil]];
        [self.ninjaOpenEyes runAction:blinkAction];
    }
    
    return self;
}

-(void)initAnimations {
    self.blinkingAnim = [self loadPlistForAnimationWithName:@"blinkingAnim" andClassName:NSStringFromClass([self class])];
    self.blinkingAnim.restoreOriginalFrame = YES;
}

-(void)changeState:(CharacterStates)newState {
    // changeState is currently NOT called
    
    [self stopAllActions];
    id action = nil;
    self.characterState = newState;
    
    // adjust ninja eyes
    if (newState == kCharacterStateDown) {
        self.ninjaOpenEyes.position = ccp(self.boundingBox.size.width * 0.455f, self.boundingBox.size.height * 0.574f);
    } else {
        self.ninjaOpenEyes.position = ccp(self.boundingBox.size.width * 0.455f, self.boundingBox.size.height * 0.63f);
    }
    
    switch (newState) {
        case kCharacterStateIdle:
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_ninja_neutral"];
            break;
            
        case kCharacterStateLeft:
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_ninja_left.png"];
            break;
            
        case kCharacterStateDown:
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_ninja_down.png"];
            break;
            
        case kCharacterStateRight:
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_ninja_right.png"];
            break;
            
        case kCharacterStateUp:
            self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"game_ninja_up.png"];
            break;
            
        default:
            CCLOG(@"Unhandled state %d in Ninja", newState);
            break;
    }
    
    if (action != nil) {
        [self runAction:action];
    }
}

@end

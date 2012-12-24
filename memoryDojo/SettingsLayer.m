//
//  SettingsLayer.m
//  memoryDojo
//
//  Created by Michael Gao on 12/24/12.
//
//

#import "SettingsLayer.h"

@implementation SettingsLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        CCLayerColor *background = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
        [self addChild:background];
        
        CCLabelBMFont *placeholder = [CCLabelBMFont labelWithString:@"SETTINGS LAYER" fntFile:@"grobold_30px_nostroke.fnt"];
        placeholder.position = ccp(screenSize.width/2, screenSize.height/2);
        [background addChild:placeholder];
        
        // add back button
        CCMenuItemLabel *backButton = [CCMenuItemLabel itemWithLabel:[CCLabelBMFont labelWithString:@"BACK" fntFile:@"grobold_21px_nostroke.fnt"] block:^(id sender) {
            // move the settings layer back down
            [self.mainMenuSceneDelegate hideSettings];
        }];
        backButton.anchorPoint = ccp(0, 1);
        backButton.position = ccp(screenSize.width * 0.05f, screenSize.height * 0.95f);
        
        CCMenu *settingsMenu = [CCMenu menuWithItems:backButton, nil];
        settingsMenu.position = CGPointZero;
        [background addChild:settingsMenu];
    }
    
    return self;
}

@end

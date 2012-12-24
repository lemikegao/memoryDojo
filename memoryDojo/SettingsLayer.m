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
        CCLOG(@"SettingsLayer->init");
        CCLayerColor *background = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
        [self addChild:background];
        
        CCLabelBMFont *placeholder = [CCLabelBMFont labelWithString:@"SETTINGS LAYER" fntFile:@"grobold_30px_nostroke.fnt"];
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        placeholder.position = ccp(screenSize.width/2, screenSize.height/2);
        [background addChild:placeholder];
    }
    
    return self;
}

@end

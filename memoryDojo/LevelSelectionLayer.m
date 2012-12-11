//
//  LevelSelectionLayer.m
//  memoryDojo
//
//  Created by Michael Gao on 12/10/12.
//
//

#import "LevelSelectionLayer.h"

@implementation LevelSelectionLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        [self addLevelSelectionMenu];
    }
    
    return self;
}

-(void)addLevelSelectionMenu {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    ccColor3B levelLabelColor = ccc3(165, 149, 109);
    CCLayerColor *levelSelectionMenuSeparator = [CCLayerColor layerWithColor:ccc4(30, 30, 30, 255) width:157.5f height:5.0f];
    CCSprite *levelSelectBox = [CCSprite spriteWithSpriteFrameName:@"mainmenu_level_select_box.png"];
    CGSize levelMenuItemSize = levelSelectBox.boundingBox.size;
    CCArray *levelMenuItems = [CCArray arrayWithCapacity:6];
    int numberOfLevels = 6;
    
    // build level selection background with separators
    // level 1
    for (int i=1; i<=numberOfLevels; i++) {
        CCMenuItemImage *levelMenuItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_level_select_box.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_level_select_box_pressed.png"] block:^(id sender) {
//            [self selectLevel:i];
        }];
        
        if (i<6) {
            CCSprite *levelAvatar = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mainmenu_level_select%i.png", i]];
            levelAvatar.position = ccp(levelMenuItemSize.width * 0.50f, levelMenuItemSize.height * 0.50f);
            [levelMenuItem addChild:levelAvatar];
        }
        
        CCLabelBMFont *levelLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", i] fntFile:@"grobold_30px_nostroke.fnt"];
        levelLabel.color = levelLabelColor;
        levelLabel.position = ccp(levelMenuItemSize.width * 0.85f, levelMenuItemSize.height/2);
        [levelMenuItem addChild:levelLabel];
        
        [levelMenuItems addObject:levelMenuItem];
    }
    
    CCMenu *levelSelectionMenu = [CCMenu menuWithArray:[levelMenuItems getNSArray]];
    levelSelectionMenu.anchorPoint = ccp(0, 0.5f);
    levelSelectionMenu.position = ccp(levelMenuItemSize.width/2, screenSize.height * 0.49f);
    [levelSelectionMenu alignItemsVerticallyWithPadding:levelSelectionMenuSeparator.boundingBox.size.height];
    
    // add level selection separators
    for (int i=1; i<numberOfLevels; i++) {
        CCLayerColor *separator = [CCLayerColor layerWithColor:ccc4(30, 30, 30, 255) width:157.5f height:5.1f];
        separator.ignoreAnchorPointForPosition = NO;
        separator.anchorPoint = ccp(0, 1);
        separator.position = ccp(0, [(CCMenuItem*)[levelMenuItems objectAtIndex:i-1] position].y + levelSelectionMenu.position.y - levelMenuItemSize.height /2);
        [self addChild:separator z:100];
    }
    
    [self addChild:levelSelectionMenu];
}

@end

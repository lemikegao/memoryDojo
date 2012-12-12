//
//  LevelSelectionLayer.m
//  memoryDojo
//
//  Created by Michael Gao on 12/10/12.
//
//

#import "LevelSelectionLayer.h"
#import "GameManager.h"

@interface LevelSelectionLayer ()

@property (nonatomic) CGSize levelMenuItemSize;
@property (nonatomic) BOOL isLevelMenuExtended;
@property (nonatomic, strong) CCArray *levelMenuItems;
@property (nonatomic, strong) CCLabelBMFont *levelLabel;

@end

@implementation LevelSelectionLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.isLevelMenuExtended = NO;
        [self addLevelSelectionMenu];
    }
    
    return self;
}

-(void)addLevelSelectionMenu {
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    ccColor3B levelLabelColor = ccc3(165, 149, 109);
    CCLayerColor *levelSelectionMenuSeparator = [CCLayerColor layerWithColor:ccc4(30, 30, 30, 255) width:157.5f height:5.0f];
    CCSprite *levelSelectBox = [CCSprite spriteWithSpriteFrameName:@"mainmenu_level_select_box.png"];
    self.levelMenuItemSize = levelSelectBox.boundingBox.size;
    self.levelMenuItems = [CCArray arrayWithCapacity:6];
    int numberOfLevels = 6;
    int currentLevel = [GameManager sharedGameManager].ninjaLevel;
    int highLevel = [GameManager sharedGameManager].highNinjaLevel;
    
    // build level selection background with separators
    for (int i=1; i<=numberOfLevels; i++) {
        CCMenuItemImage *levelMenuItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_level_select_box.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_level_select_box_pressed.png"] block:^(id sender) {
            [self selectLevel:i];
        }];
        
        // set level select box to _pressed color for currently selected level
        if (i == currentLevel) {
            levelMenuItem.normalImage = [CCSprite spriteWithSpriteFrameName:@"mainmenu_level_select_box_pressed.png"];
        }
        
#warning - remove (i<6) statement when given level 6 avatar
        if (i<=highLevel && i<6) {
            CCSprite *levelAvatar = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mainmenu_level_select%i.png", i]];
            levelAvatar.position = ccp(self.levelMenuItemSize.width/2, self.levelMenuItemSize.height/2);
            [levelMenuItem addChild:levelAvatar z:10];
        } else {
            // show question mark in place of avatar
            CCLabelBMFont *missingLevelAvatar = [CCLabelBMFont labelWithString:@"???" fntFile:@"grobold_25px_nostroke-hd.fnt"];
            missingLevelAvatar.color = ccc3(25, 25, 25);
            missingLevelAvatar.position = ccp(self.levelMenuItemSize.width * 0.40f, self.levelMenuItemSize.height * 0.44f);
            [levelMenuItem addChild:missingLevelAvatar z:10];
        }
        
        CCLabelBMFont *levelLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", i] fntFile:@"grobold_30px_nostroke.fnt"];
        levelLabel.color = levelLabelColor;
        levelLabel.position = ccp(self.levelMenuItemSize.width * 0.85f, self.levelMenuItemSize.height * 0.45f);
        [levelMenuItem addChild:levelLabel z:10];
        
        [self.levelMenuItems addObject:levelMenuItem];
    }
    
    // add menu offscreen
    CCMenu *levelSelectionMenu = [CCMenu menuWithArray:[self.levelMenuItems getNSArray]];
    levelSelectionMenu.position = ccp(-1 * self.levelMenuItemSize.width/2, screenSize.height * 0.49f);
    [levelSelectionMenu alignItemsVerticallyWithPadding:levelSelectionMenuSeparator.boundingBox.size.height];
    
    // add level selection separators
    for (int i=1; i<numberOfLevels; i++) {
        CCLayerColor *separator = [CCLayerColor layerWithColor:ccc4(30, 30, 30, 255) width:157.5f height:5.1f];
        separator.ignoreAnchorPointForPosition = NO;
        separator.anchorPoint = ccp(0.5, 1);
        separator.position = ccp(-1 * self.levelMenuItemSize.width/2, [(CCMenuItem*)[self.levelMenuItems objectAtIndex:i-1] position].y + levelSelectionMenu.position.y - self.levelMenuItemSize.height /2);
        [self addChild:separator z:100];
    }
    
    // level select button
    CCMenuItemImage *selectLevelButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_level_select_tab.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_level_select_tab_pressed.png"] target:self selector:@selector(moveSelectLevelMenu)];
    selectLevelButton.anchorPoint = ccp(0, 0);
    selectLevelButton.position = ccp(0, screenSize.height * 0.197f);
    
    CGSize selectLevelButtonSize = selectLevelButton.boundingBox.size;
    
    // add level copy to level select button
    CCLabelBMFont *levelCopyLabel = [CCLabelBMFont labelWithString:@"LEVEL" fntFile:@"grobold_21px_nostroke.fnt"];
    levelCopyLabel.color = ccc3(165, 149, 109);
    levelCopyLabel.anchorPoint = ccp(0, 0.5);
    levelCopyLabel.position = ccp(selectLevelButtonSize.width * 0.09f, selectLevelButtonSize.height * 0.45f);
    [selectLevelButton addChild:levelCopyLabel];
    
    // add level to level select button
    self.levelLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].ninjaLevel] fntFile:@"grobold_25px_nostroke.fnt"];
    self.levelLabel.color = ccc3(229, 214, 172);
    self.levelLabel.anchorPoint = ccp(0, 0.5);
    self.levelLabel.position = ccp(levelCopyLabel.boundingBox.size.width + levelCopyLabel.position.x + selectLevelButtonSize.width * 0.09f, levelCopyLabel.position.y);
    [selectLevelButton addChild:self.levelLabel];
    
    CCMenu *selectLevelButtonMenu = [CCMenu menuWithItems:selectLevelButton, nil];
    selectLevelButtonMenu.position = CGPointZero;
    
    [self addChild:levelSelectionMenu];
    [self addChild:selectLevelButtonMenu];
}

-(void)moveSelectLevelMenu {
    id moveSelectLevelMenuAction;
    
    if (self.isLevelMenuExtended == NO) {
        self.isLevelMenuExtended = YES;
        moveSelectLevelMenuAction = [CCMoveBy actionWithDuration:0.25f position:ccp(self.levelMenuItemSize.width, 0)];
    } else {
        self.isLevelMenuExtended = NO;
        moveSelectLevelMenuAction = [CCMoveBy actionWithDuration:0.25f position:ccp(-1 * self.levelMenuItemSize.width, 0)];
    }
    
    // move entire layer
    [self runAction:moveSelectLevelMenuAction];
}

-(void)selectLevel:(int)level {
    int currentLevel = [GameManager sharedGameManager].ninjaLevel;
    int highLevel = [GameManager sharedGameManager].highNinjaLevel;
    
    if (level > highLevel) {
        CCLOG(@"level is not unlocked yet -- add some message to the player");
    } else {
        if (currentLevel == level) {
            // if player selects the same level, do nothing
        } else {
            [GameManager sharedGameManager].ninjaLevel = level;
            
            // change level menu item background to _pressed color
            CCMenuItemImage *selectedMenuItem = [self.levelMenuItems objectAtIndex:(level-1)];
            selectedMenuItem.normalImage = [CCSprite spriteWithSpriteFrameName:@"mainmenu_level_select_box_pressed.png"];
            
            // change current level menu item background to regular color
            CCMenuItemImage *currentSelectedMenuItem = [self.levelMenuItems objectAtIndex:(currentLevel-1)];
            currentSelectedMenuItem.normalImage = [CCSprite spriteWithSpriteFrameName:@"mainmenu_level_select_box.png"];
            
            // change level label to new selected level
            self.levelLabel.string = [NSString stringWithFormat:@"%i", level];
        }
    }
    
    
}

@end

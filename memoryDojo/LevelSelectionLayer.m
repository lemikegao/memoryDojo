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
@property (nonatomic, strong) CCLayerColor *dimLayer;
@property (nonatomic, strong) CCMenu *levelSelectionMenu;
@property (nonatomic, strong) CCMenu *selectLevelButtonMenu;
@property (nonatomic) BOOL isScreenDimmed;

@end

@implementation LevelSelectionLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.isTouchEnabled = YES;  // for dimmed screen
        self.isLevelMenuExtended = NO;
        self.isScreenDimmed = NO;
        [self addLevelSelectionMenu];
    }
    
    return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isScreenDimmed == YES) {
        // remove dimmed screen
        [self.dimLayer removeAllChildrenWithCleanup:YES];
        [self.dimLayer removeFromParentAndCleanup:YES];
        self.isScreenDimmed = NO;
        
        // enable menus
        [self.mainMenuSceneDelegate enableAllMenus];
    }
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
        
        if (i<=highLevel) {
            CCSprite *levelAvatar = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"mainmenu_level_select%i.png", i]];
            levelAvatar.position = ccp(self.levelMenuItemSize.width/2, self.levelMenuItemSize.height/2);
            [levelMenuItem addChild:levelAvatar z:10];
        } else {
            // show question mark in place of avatar
            CCLabelBMFont *missingLevelAvatar = [CCLabelBMFont labelWithString:@"???" fntFile:@"grobold_25px.fnt"];
            missingLevelAvatar.color = ccc3(25, 25, 25);
            missingLevelAvatar.position = ccp(self.levelMenuItemSize.width * 0.40f, self.levelMenuItemSize.height * 0.44f);
            [levelMenuItem addChild:missingLevelAvatar z:10];
        }
        
        CCLabelBMFont *levelLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", i] fntFile:@"grobold_30px.fnt"];
        levelLabel.color = levelLabelColor;
        levelLabel.position = ccp(self.levelMenuItemSize.width * 0.85f, self.levelMenuItemSize.height * 0.45f);
        [levelMenuItem addChild:levelLabel z:10];
        
        [self.levelMenuItems addObject:levelMenuItem];
    }
    
    // add menu offscreen
    self.levelSelectionMenu = [CCMenu menuWithArray:[self.levelMenuItems getNSArray]];
    self.levelSelectionMenu.position = ccp(-1 * self.levelMenuItemSize.width/2, screenSize.height * 0.488f);
    [self.levelSelectionMenu alignItemsVerticallyWithPadding:levelSelectionMenuSeparator.boundingBox.size.height];
    
    // add level selection separators
    for (int i=1; i<numberOfLevels; i++) {
        CCLayerColor *separator = [CCLayerColor layerWithColor:ccc4(30, 30, 30, 255) width:self.levelMenuItemSize.width height:5.2f];
        separator.ignoreAnchorPointForPosition = NO;
        separator.anchorPoint = ccp(0.5, 1);
        separator.position = ccp(-1 * self.levelMenuItemSize.width/2, [(CCMenuItem*)[self.levelMenuItems objectAtIndex:i-1] position].y + self.levelSelectionMenu.position.y - self.levelMenuItemSize.height/2 + 0.1f);
        [self addChild:separator z:100];
    }
    
    // level select button
    CCMenuItemImage *selectLevelButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_level_select_tab.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"mainmenu_level_select_tab_pressed.png"] target:self selector:@selector(moveSelectLevelMenu)];
    selectLevelButton.anchorPoint = ccp(0, 0);
    selectLevelButton.position = ccp(0, self.levelSelectionMenu.position.y + [(CCMenuItem*)[self.levelMenuItems objectAtIndex:numberOfLevels-1] position].y - self.levelMenuItemSize.height * 0.34f);
    
    CGSize selectLevelButtonSize = selectLevelButton.boundingBox.size;
    
    // add level copy to level select button
    CCLabelBMFont *levelCopyLabel = [CCLabelBMFont labelWithString:@"LEVEL" fntFile:@"grobold_21px.fnt"];
    levelCopyLabel.color = ccc3(165, 149, 109);
    levelCopyLabel.anchorPoint = ccp(0, 0.5);
    levelCopyLabel.position = ccp(selectLevelButtonSize.width * 0.09f, selectLevelButtonSize.height * 0.45f);
    [selectLevelButton addChild:levelCopyLabel];
    
    // add level to level select button
    self.levelLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%i", [GameManager sharedGameManager].ninjaLevel] fntFile:@"grobold_25px.fnt"];
    self.levelLabel.color = ccc3(229, 214, 172);
    self.levelLabel.anchorPoint = ccp(0, 0.5);
    self.levelLabel.position = ccp(levelCopyLabel.boundingBox.size.width + levelCopyLabel.position.x + selectLevelButtonSize.width * 0.09f, levelCopyLabel.position.y);
    [selectLevelButton addChild:self.levelLabel];
    
    self.selectLevelButtonMenu = [CCMenu menuWithItems:selectLevelButton, nil];
    self.selectLevelButtonMenu.position = CGPointZero;
    
    [self addChild:self.levelSelectionMenu];
    [self addChild:self.selectLevelButtonMenu];
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

-(void)disableAllMenus {
    self.levelSelectionMenu.isTouchEnabled = NO;
    self.selectLevelButtonMenu.isTouchEnabled = NO;
}

-(void)enableAllMenus {
    self.levelSelectionMenu.isTouchEnabled = YES;
    self.selectLevelButtonMenu.isTouchEnabled = YES;
}

-(void)selectLevel:(int)level {
    int currentLevel = [GameManager sharedGameManager].ninjaLevel;
    int highLevel = [GameManager sharedGameManager].highNinjaLevel;
    
    if (level > highLevel) {
        // disable menu
        [self.mainMenuSceneDelegate disableAllMenus];
        
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        // dim background
        self.dimLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 200) width:screenSize.width height:screenSize.height];
        self.dimLayer.position = ccp(-1*self.levelMenuItemSize.width, 0);
        [self addChild:self.dimLayer z:500];
        
        self.isScreenDimmed = YES;
        
        // add message to player
        CCSprite *messageBg = [CCSprite spriteWithSpriteFrameName:@"game_transition_message_bg.png"];
        messageBg.position = ccp(self.dimLayer.boundingBox.size.width*0.5, screenSize.height/2);
        [self.dimLayer addChild:messageBg];
        
        CCLabelBMFont *message = [CCLabelBMFont labelWithString:@"REACH ROUND XX IN LEVEL Y TO UNLOCK!" fntFile:@"grobold_25px.fnt" width:messageBg.boundingBox.size.width * 0.70f alignment:kCCTextAlignmentCenter];
        switch (level) {
            case 2:
                message.string = [NSString stringWithFormat:@"REACH ROUND %i IN LEVEL 1 TO UNLOCK!", kGameLevel2Round];
                break;
            case 3:
                message.string = [NSString stringWithFormat:@"REACH ROUND %i IN LEVEL 2 TO UNLOCK!", kGameLevel3Round];
                break;
            case 4:
                message.string = [NSString stringWithFormat:@"REACH ROUND %i IN LEVEL 3 TO UNLOCK!", kGameLevel4Round];
                break;
            case 5:
                message.string = [NSString stringWithFormat:@"REACH ROUND %i IN LEVEL 4 TO UNLOCK!", kGameLevel5Round];
                break;
            case 6:
                message.string = [NSString stringWithFormat:@"REACH ROUND %i IN LEVEL 5 TO UNLOCK!", kGameLevel6Round];
                break;
            default:
                CCLOG(@"LevelSelectionLayer.m->selectLevel: Unknown level %i", level);
                break;
        }
        
        message.color = ccc3(153, 136, 94);
        message.position = ccp(messageBg.boundingBox.size.width/2, messageBg.boundingBox.size.height/2);
        [messageBg addChild:message];
        
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
            
            // show upgrades for newly selected level
            [self.delegate showUpgradesForLevel:level fromLevel:currentLevel];
        }
    }
    
    
}

@end

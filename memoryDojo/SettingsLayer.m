//
//  SettingsLayer.m
//  memoryDojo
//
//  Created by Michael Gao on 12/24/12.
//
//

#import "SettingsLayer.h"
#import "GameManager.h"

@interface SettingsLayer ()

@property (nonatomic, strong) CCMenuItem *SFXOnItem;
@property (nonatomic, strong) CCMenuItem *SFXOffItem;
@property (nonatomic, strong) CCMenuItem *musicOnItem;
@property (nonatomic, strong) CCMenuItem *musicOffItem;

@end

@implementation SettingsLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        
        CCLayerColor *background = [CCLayerColor layerWithColor:ccc4(153, 136, 94, 255)];
        [self addChild:background];
        
#warning - modify position for iphone 4 and 5
        // add menu background for top black bar
        CCLayerColor *menuBgTop = [CCLayerColor layerWithColor:ccc4(30, 30, 30, 255) width:screenSize.width height:60];
        CGSize menuBgSize = menuBgTop.boundingBox.size;
        menuBgTop.ignoreAnchorPointForPosition = NO;
        menuBgTop.anchorPoint = ccp(0, 1);
        menuBgTop.position = ccp(0, screenSize.height-44);
        [background addChild:menuBgTop];
        
        // add logo
        CCSprite *logo = [CCSprite spriteWithSpriteFrameName:@"settings_logo.png"];
        logo.anchorPoint = ccp(0, 0.5);
        logo.position = ccp(menuBgSize.width * 0.05f, menuBgSize.height/2);
        [menuBgTop addChild:logo];
        
        // add social media chiclets
        CCMenuItemImage *facebook = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"settings_chiclet_fb.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"settings_chiclet_fb_pressed.png"] block:^(id sender) {
            CCLOG(@"facebook chiclet pressed");
        }];
        

        CCMenuItemImage *twitter = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"settings_chiclet_tw.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"settings_chiclet_tw_pressed.png"] block:^(id sender) {
            CCLOG(@"twitter chiclet pressed");
        }];

        CCMenu *socialChicletsMenu = [CCMenu menuWithItems:facebook, twitter, nil];
        [socialChicletsMenu alignItemsHorizontallyWithPadding:screenSize.width * 0.05f];
        socialChicletsMenu.position = ccp(menuBgSize.width * 0.825f, menuBgSize.height/2);
        [menuBgTop addChild:socialChicletsMenu];
        
        
        // add menu background for bottom black bar
        CCLayerColor *menuBgBottom = [CCLayerColor layerWithColor:ccc4(30, 30, 30, 255) width:screenSize.width height:60];
        menuBgBottom.ignoreAnchorPointForPosition = NO;
        menuBgBottom.anchorPoint = ccp(0, 0);
        menuBgBottom.position = ccp(0, 44);
        [background addChild:menuBgBottom];
        
        // add labels for bottom menu
        CCLabelBMFont *SFXLabel = [CCLabelBMFont labelWithString:@"SFX" fntFile:@"settings_label.fnt"];
        SFXLabel.anchorPoint = ccp(0, 0.5);
        SFXLabel.position = ccp(menuBgSize.width * 0.05f, menuBgSize.height/2);
        SFXLabel.color = ccc3(91, 81, 64);
        [menuBgBottom addChild:SFXLabel];
        
        CCLabelBMFont *musicLabel = [CCLabelBMFont labelWithString:@"Music" fntFile:@"settings_label.fnt"];
        musicLabel.position = ccp(menuBgSize.width * 0.35f, menuBgSize.height/2);
        musicLabel.color = ccc3(91, 81, 64);
        [menuBgBottom addChild:musicLabel];
        
        // add bottom menu
        // add sfx toggle
        self.SFXOnItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"settings_button_sfx_on.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"settings_button_sfx_on.png"]];
        self.SFXOffItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"settings_button_sfx_off.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"settings_button_sfx_off.png"]];
        CCMenuItemToggle *SFXMenuItemToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(sfxButtonTapped:) items:self.SFXOnItem, self.SFXOffItem, nil];
        SFXMenuItemToggle.position = ccp(menuBgSize.width * 0.20f, menuBgSize.height/2);
        if ([GameManager sharedGameManager].isSoundEffectsOn == YES) {
            SFXMenuItemToggle.selectedIndex = 0;
        } else {
            SFXMenuItemToggle.selectedIndex = 1;
        }
        
        // add music toggle
        self.musicOnItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"settings_button_music_on.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"settings_button_music_on.png"]];
        self.musicOffItem = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"settings_button_music_off.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"settings_button_music_off.png"]];
        CCMenuItemToggle *musicMenuItemToggle = [CCMenuItemToggle itemWithTarget:self selector:@selector(musicButtonTapped:) items:self.musicOnItem, self.musicOffItem, nil];
        musicMenuItemToggle.position = ccp(menuBgSize.width * 0.47f, menuBgSize.height/2);
        if ([GameManager sharedGameManager].isMusicOn == YES) {
            musicMenuItemToggle.selectedIndex = 0;
        } else {
            musicMenuItemToggle.selectedIndex = 1;
        }
        
        CCMenu *menuBottom = [CCMenu menuWithItems:SFXMenuItemToggle, musicMenuItemToggle, nil];
        menuBottom.position = ccp(0, 0);
        [menuBgBottom addChild:menuBottom];
        
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

-(void)sfxButtonTapped:(id)sender {
    CCMenuItemToggle *toggleItem = (CCMenuItemToggle*)sender;
    if (toggleItem.selectedItem == self.SFXOnItem) {
        // turn sfx on
        CCLOG(@"Switched SFX on");
        [GameManager sharedGameManager].isSoundEffectsOn = YES;
    } else {
        // turn sfx off
        CCLOG(@"Switched SFX off");
        [GameManager sharedGameManager].isSoundEffectsOn = NO;
    }
}

-(void)musicButtonTapped:(id)sender {
    CCMenuItemToggle *toggleItem = (CCMenuItemToggle*)sender;
    if (toggleItem.selectedItem == self.musicOnItem) {
        // turn music on
        CCLOG(@"Switched music on");
        [GameManager sharedGameManager].isMusicOn = YES;
    } else {
        // turn music off
        CCLOG(@"Switched music off");
        [GameManager sharedGameManager].isMusicOn = NO;
    }
}

@end

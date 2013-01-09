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
        
        CCSprite *logo = [CCSprite spriteWithSpriteFrameName:@"settings_logo.png"];
        
        // add menu background for top black bar
        CCLayerColor *menuBgTop = [CCLayerColor layerWithColor:ccc4(30, 30, 30, 255) width:screenSize.width height:logo.boundingBox.size.height * 1.10f];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            menuBgTop.contentSize = CGSizeMake(screenSize.width, logo.boundingBox.size.height * 1.0f);
        }
        CGSize menuBgSize = menuBgTop.boundingBox.size;
        menuBgTop.ignoreAnchorPointForPosition = NO;
        menuBgTop.anchorPoint = ccp(0, 1);
        menuBgTop.position = ccp(0, screenSize.height);
        [background addChild:menuBgTop z:100];
        
        // add logo
        logo.anchorPoint = ccp(0, 0.5);
        logo.position = ccp(menuBgSize.width * 0.05f, menuBgSize.height/2);
        [menuBgTop addChild:logo];
        
        // add social media chiclets
        CCMenuItemImage *facebook = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"settings_chiclet_fb.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"settings_chiclet_fb_pressed.png"] block:^(id sender) {
            NSURL *urlSafari = [NSURL URLWithString:@"http://facebook.com/ChinAndCheeks"];
            NSURL *urlApp = [NSURL URLWithString:@"fb://profile/132298090255663"];
            
            if ([[UIApplication sharedApplication] canOpenURL:urlApp]){
                [[UIApplication sharedApplication] openURL:urlApp];
            } else {
                [[UIApplication sharedApplication] openURL:urlSafari];
            }
        }];
        

        CCMenuItemImage *twitter = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"settings_chiclet_tw.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"settings_chiclet_tw_pressed.png"] block:^(id sender) {
            // redirect to twitter app if installed. if not, open safari
            NSURL *urlSafari = [NSURL URLWithString:@"http://twitter.com/ChinAndCheeks"];
            NSURL *urlApp = [NSURL URLWithString:@"twitter:///user?screen_name=ChinAndCheeks"];
            NSURL *urlTweetbot = [NSURL URLWithString:@"tweetbot:///user_profile/ChinAndCheeks"];
            
            if ([[UIApplication sharedApplication] canOpenURL:urlTweetbot]){
                [[UIApplication sharedApplication] openURL:urlTweetbot];
            } else if ([[UIApplication sharedApplication] canOpenURL:urlApp]) {
                [[UIApplication sharedApplication] openURL:urlApp];
            } else {
                [[UIApplication sharedApplication] openURL:urlSafari];
            }
        }];

        CCMenu *socialChicletsMenu = [CCMenu menuWithItems:facebook, twitter, nil];
        [socialChicletsMenu alignItemsHorizontallyWithPadding:screenSize.width * 0.03f];
        socialChicletsMenu.position = ccp(menuBgSize.width * 0.815f, menuBgSize.height/2);
        [menuBgTop addChild:socialChicletsMenu];
        
        
        // add menu background for bottom black bar
        CCMenuItemImage *backButton = [CCMenuItemImage itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"settings_button_back.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"settings_button_back_pressed.png"] block:^(id sender) {
            // move the settings layer back down
            [self.mainMenuSceneDelegate hideSettings];
        }];
        
        CCLayerColor *menuBgBottom = [CCLayerColor layerWithColor:ccc4(30, 30, 30, 255) width:screenSize.width height:menuBgTop.boundingBox.size.height];
        menuBgBottom.ignoreAnchorPointForPosition = NO;
        menuBgBottom.anchorPoint = ccp(0, 0);
        menuBgBottom.position = ccp(0, 0);
        [background addChild:menuBgBottom z:100];

/*
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
 */
        
        // add back button
        backButton.position = ccp(menuBgSize.width * 0.80f, menuBgSize.height/2);
        
        CCMenu *menuBottom = [CCMenu menuWithItems:backButton, nil];
        menuBottom.position = ccp(0, 0);
        [menuBgBottom addChild:menuBottom];
        
        // add copy bg
        CCSprite *copyBg = [CCSprite spriteWithSpriteFrameName:@"game_transition_message_bg.png"];
        copyBg.position = ccp(screenSize.width/2, screenSize.height * 0.57f);
        [background addChild:copyBg];
        
        CGSize copyBgSize = copyBg.boundingBox.size;
        
        // add copy
        CCLabelTTF *topCopy1 = [CCLabelTTF labelWithString:@"Hope you've enjoyed our first game! As a special" dimensions:CGSizeMake(copyBg.boundingBox.size.width * 0.80f, copyBg.boundingBox.size.height * 0.20f) hAlignment:kCCTextAlignmentCenter fontName:@"Helvetica" fontSize:18];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            topCopy1.fontSize = 38;
        }
        topCopy1.color = ccc3(165, 149, 109);
        topCopy1.position = ccp(copyBgSize.width/2, copyBg.boundingBox.size.height * 0.75f);
        [copyBg addChild:topCopy1];
        
        CCLabelTTF *topCopy2 = [CCLabelTTF labelWithString:@"thanks, " dimensions:CGSizeMake(copyBg.boundingBox.size.width * 0.25f, copyBg.boundingBox.size.height * 0.10f) hAlignment:kCCTextAlignmentCenter fontName:@"Helvetica" fontSize:18];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            topCopy2.fontSize = 38;
        }
        topCopy2.color = ccc3(165, 149, 109);
        topCopy2.position = ccp(copyBgSize.width * 0.268f, copyBgSize.height * 0.658f);
        [copyBg addChild:topCopy2];
        
        CCLabelTTF *topCopy3 = [CCLabelTTF labelWithString:@"we'll be sending" dimensions:CGSizeMake(copyBg.boundingBox.size.width * 0.75f, copyBg.boundingBox.size.height * 0.10f) hAlignment:kCCTextAlignmentCenter fontName:@"Helvetica" fontSize:18];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            topCopy3.fontSize = 38;
        }
        topCopy3.color = ccc3(229, 214, 172);
        topCopy3.position = ccp(copyBgSize.width * 0.608f, topCopy2.position.y);
        [copyBg addChild:topCopy3];
        
        CCLabelTTF *topCopy4 = [CCLabelTTF labelWithString:@"a gift to whoever reaches level 6 first!" dimensions:CGSizeMake(copyBg.boundingBox.size.width * 0.70f, copyBg.boundingBox.size.height * 0.20f) hAlignment:kCCTextAlignmentCenter fontName:@"Helvetica" fontSize:18];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            topCopy4.fontSize = 38;
        }
        topCopy4.color = ccc3(229, 214, 172);
        topCopy4.position = ccp(copyBgSize.width/2, copyBgSize.height * 0.536f);
        [copyBg addChild:topCopy4];
        
        CCLabelTTF *bottomCopy = [CCLabelTTF labelWithString:@"We'd like to thank our friends and family, cocos2d, and Guy Buhry (Grobold font)" dimensions:CGSizeMake(copyBg.boundingBox.size.width * 0.80f, copyBgSize.height * 0.30f) hAlignment:kCCTextAlignmentCenter fontName:@"Helvetica" fontSize:14];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            bottomCopy.fontSize = 30;
        }
        bottomCopy.color = ccc3(165, 149, 109);
        bottomCopy.position = ccp(copyBgSize.width/2, copyBgSize.height * 0.24f);
        [copyBg addChild:bottomCopy];
        
        // add ninja
        CCSprite *ninja = [CCSprite spriteWithSpriteFrameName:@"mainmenu_ninja_up_repeat.png"];
        ninja.position = ccp(screenSize.width * 0.25f, copyBg.position.y - copyBg.boundingBox.size.height * 0.74);
        [background addChild:ninja z:50];
        
        CCSprite *ninjaEyes = [CCSprite spriteWithSpriteFrameName:@"mainmenu_ninja_eyes_1.png"];
        ninjaEyes.position = ccp(ninja.boundingBox.size.width * 0.455f, ninja.boundingBox.size.height * 0.63f);
        [ninja addChild:ninjaEyes];
        
        // add copyright
        CCLabelTTF *copyright = [CCLabelTTF labelWithString:@"\u00A9 2012 by Chin and Cheeks LLC" dimensions:CGSizeMake(screenSize.width * 0.65f, screenSize.height * 0.05f) hAlignment:kCCTextAlignmentRight fontName:@"Helvetica" fontSize:10];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            copyright.fontSize = 21;
        }
        copyright.color = ccc3(91, 81, 64);
        copyright.anchorPoint = ccp(1, 0);
        copyright.position = ccp(screenSize.width * 0.97f, menuBgBottom.position.y + menuBgBottom.boundingBox.size.height * 0.90f);
        [background addChild:copyright];
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

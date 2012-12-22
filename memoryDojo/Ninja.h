//
//  Ninja.h
//  memoryDojo
//
//  Created by Michael Gao on 11/4/12.
//
//

#import "GameObject.h"
#import "Constants.h"

@interface Ninja : GameObject

-(id)initFromScene:(SceneTypes)scene;
-(void)removeBlinkingEyes;
-(void)addNinjaStarWithDirection:(DirectionTypes)direction;
-(void)removeNinjaStar;
-(void)showNinjaStar;
-(void)hideNinjaStar;
-(void)switchToSenseiWithDirection:(DirectionTypes)direction;
-(void)switchToNinjaWithDirection:(DirectionTypes)direction;

@end

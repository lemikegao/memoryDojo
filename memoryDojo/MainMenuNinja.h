//
//  MainMenuNinja.h
//  memoryDojo
//
//  Created by Michael Gao on 11/6/12.
//
//

#import "GameObject.h"
#import "Constants.h"

@interface MainMenuNinja : GameObject

-(void)addNinjaStarWithDirection:(DirectionTypes)direction;
-(void)showNinjaStar;
-(void)hideNinjaStar;
-(void)switchToSenseiWithDirection:(DirectionTypes)direction;
-(void)switchToNinjaWithDirection:(DirectionTypes)direction;

@end

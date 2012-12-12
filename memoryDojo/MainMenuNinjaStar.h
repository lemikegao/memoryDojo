//
//  MainMenuNinjaStar.h
//  memoryDojo
//
//  Created by Michael Gao on 12/11/12.
//
//

#import "GameObject.h"
#import "Constants.h"
#import "MainMenuNinja.h"

@interface MainMenuNinjaStar : GameObject

-(void)shootNinjaStarFromNinja:(MainMenuNinja*)ninja withDirection:(DirectionTypes)direction;

@end

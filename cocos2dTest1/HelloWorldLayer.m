//
//  HelloWorldLayer.m
//  cocos2dTest1
//
//  Created by Nasit Sarwar Sony on 7/30/13.
//  Copyright IMpulse BD Ltd 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

//Needed to add background music
#import "SimpleAudioEngine.h"

#import "GameOverLayer.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)gameLogic:(ccTime)dt {
    [self addMonster];
}


-(void) addMonster {
    
    CCSprite * monster = [CCSprite spriteWithFile:@"monster.png"];
    monster.tag = 1;
    [_monsters addObject:monster];
    
    // Determine where to spawn the monster along the Y axis
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int minY = monster.contentSize.height / 2;
    int maxY = winSize.height - monster.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    // Create the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    monster.position = ccp(winSize.width + monster.contentSize.width/2, actualY);
    [self addChild:monster];
    
    // Determine speed of the monster
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    // Create the actions
    CCMoveTo * actionMove = [CCMoveTo actionWithDuration:actualDuration
                                                position:ccp(-monster.contentSize.width/2, actualY)];
    CCCallBlockN * actionMoveDone = [CCCallBlockN actionWithBlock:^(CCNode *node) {
        //[node removeFromParentAndCleanup:YES];
        [_monsters removeObject:node];
        CCScene *gameOverScene = [GameOverLayer sceneWithWon:NO];
        [[CCDirector sharedDirector] replaceScene:gameOverScene];

    }];
    [monster runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
    
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // Choose one of the touches to work with
    UITouch *touch = [touches anyObject];
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    // Set up initial location of projectile
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCSprite *projectile = [CCSprite spriteWithFile:@"projectile.png"];
    
    projectile.tag = 2;
    [_projectiles addObject:projectile];

    projectile.position = ccp(20, winSize.height/2);
    //[[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
    
    // Determine offset of location to projectile
    CGPoint offset = ccpSub(location, projectile.position);
    
    // Bail out if you are shooting down or backwards
    if (offset.x <= 0) return;
    
    // Ok to add now - we've double checked position
    [self addChild:projectile];
    
    int realX = winSize.width + (projectile.contentSize.width/2);
    float ratio = (float) offset.y / (float) offset.x;
    int realY = (realX * ratio) + projectile.position.y;
    CGPoint realDest = ccp(realX, realY);
    
    // Determine the length of how far you're shooting
    int offRealX = realX - projectile.position.x;
    int offRealY = realY - projectile.position.y;
    float length = sqrtf((offRealX*offRealX)+(offRealY*offRealY));
    float velocity = 480/1; // 480pixels/1sec
    float realMoveDuration = length/velocity;
    
    // Move projectile to actual endpoint
    [projectile runAction:
     [CCSequence actions:
      [CCMoveTo actionWithDuration:realMoveDuration position:realDest],
      [CCCallBlockN actionWithBlock:^(CCNode *node) {
         //[node removeFromParentAndCleanup:YES];
         [_projectiles removeObject:node];
     }],
      nil]];
    
}

- (void)update:(ccTime)dt {
    
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    for (CCSprite *projectile in _projectiles) {
        
        NSMutableArray *monstersToDelete = [[NSMutableArray alloc] init];
        for (CCSprite *monster in _monsters) {
            
            if (CGRectIntersectsRect(projectile.boundingBox, monster.boundingBox)) {
                [monstersToDelete addObject:monster];
            }
        }
        
        for (CCSprite *monster in monstersToDelete) {
            [_monsters removeObject:monster];
            
            [self removeChild:monster cleanup:YES];
            _monstersDestroyed++;
            if (_monstersDestroyed > 30) {
                CCScene *gameOverScene = [GameOverLayer sceneWithWon:YES];
                [[CCDirector sharedDirector] replaceScene:gameOverScene];
            }

        }
        
        if (monstersToDelete.count > 0) {
            [projectilesToDelete addObject:projectile];
        }
        [monstersToDelete release];
    }
    
    for (CCSprite *projectile in projectilesToDelete) {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
    [projectilesToDelete release];
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super initWithColor:ccc4(255, 255, 255, 255)]) ) {
		
        _monsters = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
      //  [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCSprite *player = [CCSprite spriteWithFile:@"player.png"];
        player.position = ccp(player.contentSize.width/2, winSize.height/2);
        [self addChild:player];

	}
    [self schedule:@selector(gameLogic:) interval:1.0];
    [self schedule:@selector(update:)];
    [self setIsTouchEnabled:YES];
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	[_monsters release];
    _monsters = nil;
    [_projectiles release];
    _projectiles = nil;
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end

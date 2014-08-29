/* 
 * Copyright (c) 2011, salesforce.com, inc.
 * Author: Jonathan Hersh jhersh@salesforce.com
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided 
 * that the following conditions are met:
 * 
 *    Redistributions of source code must retain the above copyright notice, this list of conditions and the 
 *    following disclaimer.
 *  
 *    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and 
 *    the following disclaimer in the documentation and/or other materials provided with the distribution. 
 *    
 *    Neither the name of salesforce.com, inc. nor the names of its contributors may be used to endorse or 
 *    promote products derived from this software without specific prior written permission.
 *  
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED 
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A 
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR 
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED 
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import "FollowButton.h"
#import <QuartzCore/QuartzCore.h>
#import "SFRestAPI+Blocks.h"
#import "SFRestAPI+QueryBuilder.h"
#import "SFOAuthCredentials.h"
#import "SFOAuthCoordinator.h"

@implementation FollowButton

@synthesize parentId, followButtonState, followId, delegate, sheet;

+ (id) followButtonWithParentId:(NSString *)pId {    
    FollowButton *button = [[FollowButton alloc] initWithTitle:NSLocalizedString(@"Loading...", nil)
                    style:UIBarButtonItemStyleBordered
                   target:nil
                   action:@selector(buttonTapped:)];
    
    button.parentId = pId;
    button.followId = nil;
    button.target = button;
        
    return [button autorelease];
}

- (void) loadTitle {
    NSString *title = nil;
        
    switch( followButtonState ) {
        case FollowLoading:            
            title = @"";
            break;
        case FollowError:
            title = NSLocalizedString(@"Error", @"Error loading following state");
            break;
        case FollowFollowing:
            title = NSLocalizedString(@"Following", @"Following");
            break;
        case FollowNotFollowing:
            title = NSLocalizedString(@"Follow", @"Follow");
            break;
    }

    [self setTitle:title];
}

- (void) loadFollowState {
    if( !parentId || !self.delegate )
        return;
    
    [self changeStateToState:FollowLoading isUserAction:NO];
    
    NSString *query = [SFRestAPI SOQLQueryWithFields:[NSArray arrayWithObject:@"Id"]
                                            sObject:@"EntitySubscription"
                                              where:[NSString stringWithFormat:@"subscriberid='%@' and parentid='%@'",
                                                             [[[[SFRestAPI sharedInstance] coordinator] credentials] userId],
                                                             parentId]
                                              limit:1];
    
    [[SFRestAPI sharedInstance] performSOQLQuery:query
                                       failBlock:^(NSError *e) {
                                           self.followButtonState = FollowError;
                                           [self loadTitle];         
                                           
                                           if( [self.delegate respondsToSelector:@selector(followButtonDidReceiveError:error:)] )
                                               [self.delegate followButtonDidReceiveError:self error:e];
                                           
                                           return;
                                       }
                                   completeBlock:^(NSDictionary *response) {
                                       if( [[response objectForKey:@"records"] count] > 0 ) {
                                           self.followId = [[[response objectForKey:@"records"] objectAtIndex:0] objectForKey:@"Id"];
                                           [self changeStateToState:FollowFollowing isUserAction:NO];
                                       } else
                                           [self changeStateToState:FollowNotFollowing isUserAction:NO];
                                   }];
}

- (void) changeStateToState:(FollowButtonState)state isUserAction:(BOOL)isUserAction {
    if( !self.delegate )
        return;
    
    if( [self.delegate respondsToSelector:@selector(followButtonWillChangeState:toState:isUserAction:)] )
        [self.delegate followButtonWillChangeState:self toState:state isUserAction:isUserAction];
    
    self.followButtonState = state;
    [self loadTitle];
    
    if( [self.delegate respondsToSelector:@selector(followButtonDidChangeState:toState:isUserAction:)] )
        [self.delegate followButtonDidChangeState:self toState:self.followButtonState isUserAction:isUserAction];
}

- (void) toggleFollow {
    if( self.followButtonState == FollowFollowing ) {
        if( !followId )
            return;
        
        [self changeStateToState:FollowLoading isUserAction:YES];
        
        [self performSelector:@selector(loadFollowState) withObject:nil afterDelay:5.0];
        
        [[SFRestAPI sharedInstance] performDeleteWithObjectType:@"EntitySubscription"
                                                       objectId:self.followId
                                                      failBlock:^(NSError *e) {
                                                          [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadFollowState) object:nil];
                                                          self.followButtonState = FollowFollowing;
                                                          [self loadTitle];      
                                                          
                                                          if( [self.delegate respondsToSelector:@selector(followButtonDidReceiveError:error:)] )
                                                              [self.delegate followButtonDidReceiveError:self error:e];
                                                      }
                                                  completeBlock:^(NSDictionary *response) {
                                                      [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadFollowState) object:nil];
                                                      [self changeStateToState:FollowNotFollowing isUserAction:YES];
                                                      followId = nil;
                                                  }];
    } else if( self.followButtonState == FollowNotFollowing ) {
        [self changeStateToState:FollowLoading isUserAction:YES];
        
        [self performSelector:@selector(loadFollowState) withObject:nil afterDelay:5.0];
        
        [[SFRestAPI sharedInstance] performCreateWithObjectType:@"EntitySubscription"
                                                         fields:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 parentId, @"parentId",
                                                                 [[[[SFRestAPI sharedInstance] coordinator] credentials] userId], @"subscriberId",
                                                                 nil]
                                                      failBlock:^(NSError *e) {
                                                          [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadFollowState) object:nil];
                                                          self.followButtonState = FollowNotFollowing;
                                                          [self loadTitle];            
                                                          
                                                          if( [self.delegate respondsToSelector:@selector(followButtonDidReceiveError:error:)] )
                                                              [self.delegate followButtonDidReceiveError:self error:e];
                                                      }
                                                  completeBlock:^(NSDictionary *results) {
                                                      [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadFollowState) object:nil];
                                                      
                                                      if( [[results objectForKey:@"success"] boolValue] ) {
                                                          self.followId = [results objectForKey:@"id"];
                                                          [self changeStateToState:FollowFollowing isUserAction:YES];
                                                      } else 
                                                          [self loadFollowState];
                                                  }];
    } else {
        // reload state
        [self loadFollowState];
    }
}

// Capture tapping a field
- (void) buttonTapped:(FollowButton *)sender {    
    if( self.sheet ) {
        [self.sheet dismissWithClickedButtonIndex:-1 animated:YES];
        self.sheet = nil;
        return;
    }
    
    switch( followButtonState ) {
        case FollowFollowing:
            self.sheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                    destructiveButtonTitle:NSLocalizedString(@"Unfollow", @"Unfollow")
                                         otherButtonTitles:nil] autorelease];
            
            [sheet showFromBarButtonItem:self animated:YES];
            break;
        case FollowNotFollowing:
            [self toggleFollow];
            break;
        case FollowError:
            [self loadFollowState];
            break;
        default: break;
    }
}

// We've clicked a button in this contextual menu
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {        
    if( buttonIndex == actionSheet.destructiveButtonIndex ) {
        [self toggleFollow];
    }
    
    self.sheet = nil;
}

- (void)dealloc {
    [parentId release];
    [followId release];
    [sheet release];
    delegate = nil;
    [super dealloc];
}

@end

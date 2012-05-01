# iOS Native Mobile Components #

A collection of native Objective-C/Cocoa iOS UI widgets and other components to simplify and jump-start your own native iOS application that connects to Salesforce.

In this document:

- Mobile Components License
- Reference Implementations
- Installation
- Component Listing

## Mobile Components License ##

Copyright (c) 2012, salesforce.com, inc. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of salesforce.com, inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Reference Implementations ##

- Many (as of this writing, all) of these iOS-Native components originally appeared in Salesforce for iPad, a free, unofficial, unsupported, open-source app that's [available on GitHub](https://github.com/ForceDotComLabs/Salesforce-for-iPad).

## Installation ##

0. These components have a *required dependency* on the [Force.com Mobile SDK for iOS](https://github.com/forcedotcom/SalesforceMobileSDK-iOS). First ensure you have it added to your app.
1. Grab the component source code: `git clone https://github.com/ForceDotCom/MobileComponents.git`
2. iOS Native components are in the iOS-Native directory. Copy the component(s) of your choice into your xcode project. 

## Component Listing ##

### Follow Button ###

A `UIBarButtonItem` intended to make it easy to create a follow/unfollow toggle between the running user and any other user or Chatter-enabled record.

Usage:

1. Create a new button with the parent object's ID (the id of the user/record to follow/unfollow). Use the built-in constructor. `FollowButton *myFollowButton = [FollowButton followButtonWithParentId:@"00530000001emdl"];`
2. Set the follow button's delegate to your viewcontroller (`myFollowButton.delegate = self;`), add the `FollowButtonDelegate`to your viewcontroller's header, and add the button itself to your view.
3. Once your view has loaded, instruct your follow button to load its current follow state. `[myFollowButton loadFollowState];`
4. When the user taps the button, it will call your delegate with `followButtonWillChangeState` and `followButtonDidChangeState`. Salesforce for iPad uses these delegate events to swap out the `FollowButton` in favor of an activity loading spinner to indicate to the user that a network operation is in progress, but that's entirely optional. When the follow or unfollow action is completed, the button should update its state and displayed text.
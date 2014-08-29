# Mobile Components for Visualforce #

Mobile Components for Visualforce is a free, open-source Force.com library to simplify the development of mobile apps. The framework contains lightweight Visualforce UI components that generate cross-platform HTML5 output that runs well on smartphones and tablets. The apps can be deployed in the browser or embedded inside Container from the Salesforce Mobile SDK. 
Note: The library is still in heavy development and is missing certain features as well as complete documentation.
This document is intended to introduce you to the app's architecture and design and make it as easy as possible for you to jump in, run it, and start contributing.

- What's included
- Installation Steps
- Salesforce Mobile Container Setup
- Extending Component Framework
- Roadmap
- Third-party Code
- FAQ
- Mobile Components for Visualforce License

## What's Included ##
1. **App Component**: Component to provide wrapper for any mobile application. This component provides all the settings and architecture pieces (including jQuery and jQuery Mobile) for mobile app development.
2. **SplitView Template**: SplitView Template is a Page template to provide the split view components on the page. In landscape mode, it provides a left menu section and a broad main section and in portrait mode, it turns the left menu into a popover.
3. **List Component**: List Component provides a quick and easy way to render a record list for any sobject. One can easily manage the behavior of the component by using the various attributes or the javascript hooks on this component.
4. **Detail Component**: Detail Component provides a quick and easy way to render the details for any sobject. One can easily manage the behavior of the component by using the various attributes or the javascript hooks on this component.
5. **Page Component**: Page Component provides a jQuery Mobile wrapper with `data-role="page"`.
6. **Header Component**: Header Component provides a jQuery Mobile wrapper with `data-role="header"` for header sections inside a Page component.
7. **Content Component**: Content Component provides a jQuery Mobile wrapper with `data-role="content"` for content sections inside a Page component.
8. **Footer Component**: Footer Component provides a jQuery Mobile wrapper with `data-role="footer"` for footer sections inside a Page component.
9. **Navigation Component**: Navigation Component can be used to create hooks for navigation between various jQuery Mobile pages.

 
## Installation Steps ##
1. Grab the source code: `git clone https://github.com/ForceDotCom/MobileComponents.git`
2. Deploy the Force.com metadata under MobileComponents/Visualforce/src folder to your destination org. You can deploy that using [Force.com Migration Tool](http://wiki.developerforce.com/index.php/Force.com_Migration_Tool) or by using [Force.com IDE](http://wiki.developerforce.com/index.php/Force.com_IDE)
3. Login into your destination org and setup following:
    1. Remote Site: Under Setup -> Administration Setup -> Security Controls -> Remote Site Settings, create a new Remote Site and specify your org's instance URL for the Remote Site URL. Eg. if your org is on instance NA1, the Remote Site URL will be `https://na1.salesforce.com`.

You should now be all set and ready to use the app! To see the sample contact viewer app in action, navigate to the following VF page: `/apex/MobilePage`

## Salesforce Mobile Container Setup ##
1. Create a new **Hybrid Force.com App** project and point the `startData` to `/apex/MobilePage`.
2. Add the **ExternalHost** whitelist:
	- Open the file **PhoneGap.plist** under **Supporting Files** folder in the xcode project.
	- In the PhoneGap.plist, expand the **ExternalHosts** section and add the following 2 domains to the existing list: ajax.microsoft.com, code.jquery.com
3. And you must be all set to run this Visualforce application as a native app.


## Extending Component Framework ##
There are two ways to extend or override Mobile Web SDK’s client-side behavior: listen for and act upon events and/or extend standard Mobile Web SDK Javascript components.

### Events
Mobile Web SDK Javascript events provide hooks into key user-interaction and Mobile Web SDK’s lifecycle points. When an event is fired, an event listener may augment the firing component’s behavior by changing or adding to passed parameters. Event listeners may also perform functions based on user trigger actions, such as change styling when an List component item is selected. Additionally, event listener may act upon standard jQuery Mobile events such as page loading (see jQuery Mobile documentation).

For Example: When a List component’s item is selected, the following with open a dialog box:

        $(document).on('listitemselect', function(e, context) {
            alert('You selected id: ' + context.data.Id);
        });

### Extending Mobile Web SDK Javascript Components
For more extensive customizations, Mobile Web SDK’s Javascript components may be extended to override or provide additional functionality to standard component behavior or styling.  For example, the Visualforce.Mobile.ListComponent Javascript component provides a basic list item template for each row in a list.  To customize the template, create a new Javascript class by extending Visualforce.Mobile.ListComponent and re-implement the getTemplate method.  Lastly, register the new class with the List component’s compHandler attribute.  When the List component is instantiated, an instance of the custom ListComponent will be created and its Mobile Web SDK lifecycle methods invoked.  Class customizations may call the parent class’s implementation before or after additional functionality or replace the underlying implementations altogether.  Custom implementations must extend Visualforce.Mobile.Component to hook into Mobile Web SDK lifecycle.

For Example: To provide a custom list item template:

        MyListComponent = Visualforce.Mobile.ListComponent.extend({
            getTemplate: function() {
                return '<h3 class="my-heading">${' + this.config.labelField + '}</h3>');
            }
        }
        <c:List ... compHandler="MyListComponent"/>


## Roadmap ##
- Edit Component
- Phone Navigation
- Chatter Component

## Third-party Code ##

This library makes use of a number of third-party components:

- [jQuery](http://jquery.com), the javascript library to make it easy to write javascript.
- [jQuery Mobile](http://jquerymobile.com), Touch-Optimized Web Framework for Smartphones & Tablets.
- [jQuery Templates](http://api.jquery.com/category/plugins/templates/), the jQuery plugin for easy text manipulation.


## FAQ ##

Q: Why did we create this library?  
A: HTML5 developers need a robust set of components to build mobile apps. This library provides a way to share the lessons learned creating Contact Viewer and provide re-usable components that can be plugged into Visualforce. 

Q: Is this library dependent on jQuery Mobile?  
A: jQuery Mobile is primarily used for transitions and UI components and makes it easy to incorporate other JQM components and plugins in your apps. Since the primary data components, such as List and Detail component, are independent of jQuery Mobile, one can also rip out and integrate with Sencha Touch or other frameworks.

Q: Will these components get incorporated into Visualforce?  
A: Not directly, although enhancements will be made to Visualforce to provide a better mobile experience.

Q: Can I customize the components?  
A: Absolutely! Please share your experience

Q: Where should I provide feedback and bug reports?  
A: We’re going to use GitHub for all collaboration.

Q: Can I distribute this in my app?  
A: Yes

Q: How is this framework supported?  
A: This is unsupported software from the Force.com development community. We will make our best efforts to fix bugs and add enhancements. We also encourage the community to fork the code and make independent changes.

## Mobile Components for Visualforce License ##
Copyright (c) 2012, salesforce.com, inc. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
- Neither the name of salesforce.com, inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

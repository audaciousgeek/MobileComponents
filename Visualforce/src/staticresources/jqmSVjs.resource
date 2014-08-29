/*
 * Copyright (c) 2012, salesforce.com <http://salesforce.com> , inc.
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided 
 * that the following conditions are met:
 * 
 *    Redistributions of source code must retain the above copyright notice, this list of conditions and the 
 *    following disclaimer.
 *  
 *    Redistributions in binary form must reproduce the above copyright notice, this list of conditions and 
 *    the following disclaimer in the documentation and/or other materials provided with the distribution. 
 *    
 *    Neither the name of salesforce.com <http://salesforce.com> , inc. nor the names of its contributors may be used to endorse or 
 *    promote products derived from this software without specific prior written permission.
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
 
(function($){
  $(document).on('mobileinit', function(){
    console.log('mobileinit called');
    //some class for css to detect touchscreens
    if($.support.touch){
      $('html').addClass('touch');
    }
    var $query = $.mobile.media('screen and (min-width: 480px)')/* && ($.mobile.media('(-webkit-max-device-pixel-ratio: 1.2)') || $.mobile.media('(max--moz-device-pixel-ratio: 1.2)'))*/;
    $.support.splitview = ($query || ($.mobile.browser.ie && $(this).width() >= 480)) && $.mobile.ajaxEnabled;
    if ($.support.splitview) {
    
      var init = function(menuPanel, mainPanel) {
        var firstPageMain, firstPageMenu;
        
        if(menuPanel && mainPanel) {
            firstPageMenu=menuPanel.children(':jqmData(role="page"):first');
            firstPageMain=mainPanel.children(':jqmData(role="page"):first');
            
            if((menuPanel.children(':visible').length || firstPageMenu.length) && 
              (mainPanel.children(':visible').length || firstPageMain.length)) {
              
                menuPanel.parent().addClass('splitview');   
                menuPanel.addClass('ui-panel-left');
                mainPanel.addClass('ui-panel-right');
                
                if (!$.mobile.hashListeningEnabled || !$.mobile.path.stripHash( location.hash ) ) {
                    if( firstPageMenu.length){
                      $.mobile.activePage = $.mobile.firstPage = firstPageMenu;
                      $.mobile.changePage(firstPageMenu, {transition:'none', fromPage:firstPageMenu, changeHash:false, pageContainer:menuPanel, allowSamePageTransition:true});
                    }
                
                    if( firstPageMain.length ) {
                      $.mobile.activePage = $.mobile.firstPage = firstPageMain;
                      $.mobile.changePage(firstPageMain, {transition:'none', fromPage:firstPageMain, changeHash:false, pageContainer:mainPanel, allowSamePageTransition:true});
                    } //no need to trigger a hashchange here cause the other page is handled by core.
                }
        
                // setup the layout for splitview and jquerymobile will handle first page init
                $(window).trigger('orientationchange');
                
                //REVIEW: Should this happen for any content block inside split view or only the first level children
                menuPanel.add(mainPanel).find(':jqmData(role="content")').on('touchend touchcancel',
                    function(e) {
                        var target = e.currentTarget, onScroll = function(e) {
                            if (e.currentTarget.offsetHeight + e.currentTarget.scrollTop >= e.currentTarget.scrollHeight) {
                                $(e.currentTarget).scrollTop(e.currentTarget.scrollTop-1);
                            } else if (e.currentTarget.scrollTop == 0) {
                                $(e.currentTarget).scrollTop(1);
                            }
                            $(e.currentTarget).off('throttledscroll');
                        }
                        $(target).on('throttledscroll', onScroll);
                    }
                );
                menuPanel.add(mainPanel).on('touchmove', function (e) {
                   if ( !$(':jqmData(role="content")').has(e.target).length ) {
                        e.preventDefault();
                   } 
                }); 
           
            } else {
                $.support.splitview = false;
                if ( menuPanel.children(':visible').length ) {
                    menuPanel.css('-webkit-box-flex', '1');
                    mainPanel.hide();
                } else if ( mainPanel.children(':visible').length ) {
                    mainPanel.css('-webkit-box-flex', '1');
                    menuPanel.hide();
                }
            }
        } else {
            $.support.splitview = false;
        }
      }
      
      //on window.ready() execution:
      $(function() {
        var $parentPage, menuPanel, mainPanel;
        menuPanel = $(':jqmData(role="panel"):jqmData(id="menu")');
        mainPanel = $(':jqmData(role="panel"):jqmData(id="main")');
            
        if (menuPanel.length == 1 && mainPanel.length == 1 && menuPanel.next().is(mainPanel)) {
            menuPanel.add(mainPanel).children(':jqmData(role="page")').find(':jqmData(position="fixed")').attr('data-position', '');
            $parentPage = menuPanel.parents(':jqmData(role="page")');
            if (!$parentPage.length) {
                $(window).on('pagecontainercreate', function() { init(menuPanel, mainPanel); });
            } else {
                $(document).on('pagebeforechange', function(e, data) {
                    if ( typeof data.toPage != "string" ) 
                        $.support.splitview = ( data.toPage.has(menuPanel).length > 0)
                });
                
                $parentPage.on('pageinit', function(e) {
                    if($parentPage.is(e.target)) init(menuPanel, mainPanel);
                });
            }
        } else {
            $.support.splitview = false;
        }
      });
      
      var resetPageStyle = function($pages) {
           console.log('resetPageStyle called');
           $pages.each(function() {
               var $target = $(this);
               var pageCss = {'min-height': 0/*, padding: '0px', height: '100%'*/};
               $target.css(pageCss);
           });
       }
       
       $(document).on('pageinit updatelayout pageshow pagehide pagebeforeshow webkitAnimationStart animationstart pagechange pagebeforechange', function(e) { 
           console.log('Event: ' + e.type);
           if ($.support.splitview) {
               resetPageStyle($(':jqmData(role="page").' + $.mobile.activePageClass));
           }
       });
       
       $(document).on('pageload', function(e, callback) {
           var $target, $page, $container; 
           console.log('Event: ' + e.type);
           console.log('pageload called');
           if ($.support.splitview) {
               $page = $(e.target);
               //$container = $(':jqmData(role="panel"):jqmData(id="main")');
                if (!$page.is(':jqmData(role="page")')) $page = $page.parents(':jqmData(role="page"):first');
                $container = $page.parent(':jqmData(role="panel")');
                if ($page.length && $container.length) {
                    $.mobile.activePage = $.mobile.firstPage = $page;
                    $.mobile.changePage($page, {transition:'slide', fromPage:$page, changeHash:false, pageContainer: $container, allowSamePageTransition:true});
                }
            }
       });
       
       var onWindowResize = function() {
           if ($.support.splitview) {
               //Adding timeout so that this reset happens after other dom updates
               setTimeout(function() { resetPageStyle($(':jqmData(role="page").' + $.mobile.activePageClass)); }, 100);
           }
       }
       
       $(window).on('throttledresize.resetPageHeight', onWindowResize);
      
      //DONE: bind orientationchange and resize - the popover
      var _orientationHandler = function(event){
        console.log('orientationchange called');
        if ($.support.splitview) {
            var $menu=$('div:jqmData(id="menu")'),
                $main=$('div:jqmData(id="main")'),
                $mainHeader = $main.find(':jqmData(role="header"):visible:first'),
                $window=$(window);
            
            if (!$mainHeader.length) $mainHeader = $main.find('div:jqmData(role="header"):first');
            
            function popoverBtn(header) {
                if(!header.children('.popover-btn').length){
                    header.prepend('<span class="popover-btn">Menu</span>');
                    //popover button click handler - from http://www.cagintranet.com/archive/create-an-ipad-like-dropdown-popover/
                    header.children('.popover-btn').on('tap', function(e){ 
                        $('.panel-popover').fadeToggle('fast'); 
                        if ($('.popover-btn').hasClass($.mobile.activeBtnClass)) { 
                            $('.popover-btn').removeClass($.mobile.activeBtnClass); 
                        } else { 
                            $('.popover-btn').addClass($.mobile.activeBtnClass); 
                        }
                    });          
                }
            }
    
            function replaceBackBtn(header) {
              if($.mobile.urlHistory.stack.length > 1 && !header.children('a:jqmData(rel="back")').length && header.jqmData('backbtn')!=false){ 
                header.prepend("<a href='#' class='ui-btn-left' data-"+ $.mobile.ns +"rel='back' data-"+ $.mobile.ns +"icon='arrow-l'>Back</a>" );
                header.children('a:jqmData(rel="back")').buttonMarkup();
              }
            };
    
            function popover(){
              $menu.addClass('panel-popover')
                   .removeClass('ui-panel-left')
                   .css({/*'width':'25%', 'min-width':'250px', */'display':'', 'overflow-x':'visible'});     
              if(!$menu.children('.popover_triangle').length){ 
                $menu.prepend('<div class="popover_triangle"></div>'); 
              }
              $menu.children('.' + $.activePageClass).css('min-height', '100%');
              /*$main.removeClass('ui-panel-right')
                   .css('width', '');*/
              popoverBtn($mainHeader);
    
              $main.off('div:jqmData(role="page")', 'pagebeforeshow.splitview');
              $main.on('div:jqmData(role="page")','pagebeforeshow.popover', function(){
                var $thisHeader=$(this).children('div:jqmData(role="header")');
                popoverBtn($thisHeader);
              });

              // TODO: unbind resetActivePageHeight for popover pages
    
            };
    
            function splitView(){
              $menu.removeClass('panel-popover')
                   .addClass('ui-panel-left')
                   .css({/*'width':'25%', 'min-width':'250px',*/ 'display':''});
              $menu.children('.popover_triangle').remove();
              /*$main.addClass('ui-panel-right')
                   .width(function(){
                     return $(window).width()-$('div:jqmData(id="menu")').width();  
                   });*/
              $mainHeader.children('.popover-btn').remove();
              
              // replaceBackBtn($mainHeader);
    
              $main.off('div:jqmData(role="page")', 'pagebeforeshow.popover');
              $main.on('div:jqmData(role="page")', 'pagebeforeshow.splitview', function(){
                var $thisHeader=$(this).children('div:jqmData(role="header")');
                $thisHeader.children('.popover-btn').remove();
                // replaceBackBtn($thisHeader);
              });
            }
    
            if(event.orientation){
              if(event.orientation == 'portrait'){
                popover();            
              } 
              else if(event.orientation == 'landscape') {
                splitView();
              } 
            }
            else if($window.width() < 768 && $window.width() > 480){
              popover();
            }
            else if($window.width() > 768){
              splitView();
            }
            onWindowResize();
        }
      };

      $(window).on('orientationchange', _orientationHandler);
      
      $(document).tap(function(event) {
        if ($.support.splitview && !$(event.target).closest('.panel-popover').length && !$(event.target).closest('.popover-btn').length) {
            $(".panel-popover").stop(true, true).hide(); 
            $('.popover-btn').removeClass($.mobile.activeBtnClass); 
        }; 
      });
      
      $('.panel-popover').live('hide', function(event) { 
        if ($.support.splitview) { 
            $(".panel-popover").stop(true, true).hide(); 
            $('.popover-btn').removeClass($.mobile.activeBtnClass); 
        }; 
      });
    }
   });
})(jQuery);
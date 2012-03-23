if (!window.Visualforce) Visualforce = {};
if (!Visualforce.Mobile) Visualforce.Mobile = {};
$V = Visualforce.Mobile;

/**
 * Simple JavaScript Inheritance
 * By John Resig http://ejohn.org/
 * MIT Licensed.
 */
(function(){
    var initializing = false, fnTest = /xyz/.test(function(){xyz;}) ? /\b_super\b/ : /.*/;
    // The base Class implementation (does nothing)
    $V.Class = function(){};

    // Create a new Class that inherits from this class
    $V.Class.extend = function(prop) {
        var _super = this.prototype;

        // Instantiate a base class (but only create the instance,
        // don't run the init constructor)
        initializing = true;
        var prototype = new this();
        initializing = false;

        // Copy the properties over onto the new prototype
        for (var name in prop) {
          // Check if we're overwriting an existing function
          prototype[name] = typeof prop[name] == "function" &&
            typeof _super[name] == "function" && fnTest.test(prop[name]) ?
            (function(name, fn){
              return function() {
                var tmp = this._super;

                // Add a new ._super() method that is the same method
                // but on the super-class
                this._super = _super[name];

                // The method only need to be bound temporarily, so we
                // remove it when we're done executing
                var ret = fn.apply(this, arguments);
                this._super = tmp;

                return ret;
              };
            })(name, prop[name]) :
            prop[name];
        }

        // The dummy class constructor
        function Class() {
          // All construction is actually done in the init method
          if ( !initializing && this.init )
            this.init.apply(this, arguments);
        }

        // Populate our constructed prototype object
        Class.prototype = prototype;

        // Enforce the constructor to be what we expect
        Class.prototype.constructor = Class;

        // And make this class extendable
        Class.extend = arguments.callee;

        return Class;
    };
})();

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

(function($) {
    // Extending jQuery for more functions.
    $.extend({
        getUrlVars: function(){
            var vars = [], hash;
            var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
            for(var i = 0; i < hashes.length; i++) {
              hash = hashes[i].split('=');
              vars.push(hash[0]);
              vars[hash[0]] = hash[1];
            }
            return vars;
        },
        getUrlVar: function(name){
            return $.getUrlVars()[name];
        }
    });
    
    /**
     * Application controller managing application lifecycle including managing pages and components
     */
    $V.App = (function() {
        // privates
        var init = function(config) {
                this.config = config;
                this.pages = {};
                this.components = {};
                this.debug = this.config.debug;
                this.nextPage = {};
    
                function parseHash(hash) {
                    var idx;
                    if (hash) {
                        // FIXME: use regex
                        idx = hash.indexOf('#');
                        if (idx > -1) {
                            hash = hash.substring(idx + 1);
                        }
                        idx = hash.indexOf('?');
                        if (idx > -1) {
                            hash = hash.substring(0, idx);
                        }
                    }
                    return hash;
                }
    
                // listeners; wrap to give $V.App scope
                (function(that) {
                $(document).bind("pagebeforeload", function(evt, context) {
                    if (evt.target) {
                    that.log.debug('pagebeforeload: ' + (context && context.url ? context.url : 'unknown'));
                    }
                });
    
                // invoke page lifecycle for re-rendering (called every time a page is requested)
                $(document).bind("pagebeforechange", function(evt, context) {
                    var toPage, page;
                    if (evt.target && context) {
                        toPage = context && context.toPage && context.toPage.length > 0 ? context.toPage[0].id : null;
                        that.log.debug('pagebeforechange: ' + (toPage ? toPage : 'unknown'));
                        $V.App.nextPage = toPage;
                        if (toPage) {
                            page = that.getPage(parseHash(toPage));
                            // render page
                            if (page && page.rerender) {
                                that.log.debug('Rerendering page: ' + page.config.id);
                                page.rerender();
                            }
                        }
                    }
                });
    
                // invoke page lifecycle for creating page instance (first visited)
                $(document).bind("pagebeforecreate", function(evt, context) {
                    var page;
                    if (evt.target && evt.target.id) {
                        that.log.debug('pageinit: ' + (evt.target.id ? evt.target.id : 'unknown'));
                        if (evt.target.id) {
                            page = that.getPage(evt.target.id);
                            if (page && !(page instanceof $V.Page)) {
                                page = new $V.Page(page);
                                that.pages[page.config.id] = page;
                                that.log.debug('Init\'ing page: ' + page.config.id);
                            }
                        }
                    }
                });
    
                // invoke page lifecycle for rendering page for the first time
                $(document).bind("pageinit", function(evt, context) {
                    var page;
                    if (evt.target && evt.target.id) {
                        that.log.debug('pageinit: ' + (evt.target.id ? evt.target.id : 'unknown'));
                        if (evt.target.id) {
                            page = that.getPage(evt.target.id);
                            if (page && page.render) {
                                that.log.debug('Rendering page: ' + page.config.id);
                                page.render();
                            }
                        }
                    }
                });
    
                $(document).bind("pagechange", function(evt, context) {
                    var page;
                    if (evt.target) {
                    page = context && context.toPage && context.toPage.length > 0 ? context.toPage[0].id : null;
                        that.log.debug('pagechange: ' + (page !== null ? page : 'unknown'));
                        if (page) {
                            page = that.getPage(page);
                            if (page && page.postrender) page.postrender();
                        }
                    }
                });
    
                $(document).bind("pagechangefailed", function(evt, context) {
                    if (evt.target) {
                        that.log.debug('pagechangefailed: ' + (context && context.toPage ? context.toPage : 'unknown'));
                    }
                });
    
                if (that.config.debug === true) {
                    // Hook for remoting before call
                    Visualforce.remoting.RemotingProvider.on('beforecall',function(pdr,tx,m){
                        that.log.debug('VF Remoting beforecall', tx.data);
                    });
                }
            })(this);
        },
        registerPage = function(id, page) {
            if (!id) {
                //JQM adds a page automatically if no page found.
                this.log.info('Ignore page registration. No id specified'); 
                return;
            }
            
            page = page || this.pages[id] || new $V.Page(id);
            if (!(page instanceof $V.Page)) throw Error('Page must be instance of $V.Page');
            if (id != page.config.id) throw Error('Id and Page config id must match.'); 
            
            this.pages[id] = page;
                            
            return page;
        },
        registerComponent = function(id, config) {
            var $parentPage, page, handlerFn, handlerFnExt, comp;
            
            config.id = id || config.id;
            if (!config.id) throw Error('Component must have id');
            
            handlerFn = $V.App.getFn(config.compHandler);
            if (!handlerFn) throw Error('Component handler function is not defined or not found (' + config.compHandler + ')');
            if (this.components[config.id]) return; // avoid re-registering same component
            comp = new handlerFn(config);
            if (!(comp instanceof $V.Component)) throw Error('Component handler must extend Visualforce.Mobile.Component');
            this.components[config.id] = comp;
            
            $parentPage = $('[id="'+ config.id + '"]').parents('[data-role="page"]:first');
            if ($parentPage.length) page = this.pages[$parentPage.attr('id')] || this.registerPage($parentPage.attr('id'));
            if (page) {
                page.comps.push(comp);
            }
    
            // register fields to be processed later - gather metadata about each field
            if (comp.fields) {
                if (!this.config.fields) this.config.fields = [];
                for (var i=0, len=comp.fields.length; i<len; i++) {
                    if ($.inArray(comp.fields[i], this.config.fields) == -1) this.config.fields.push(comp.fields[i]);
                }
                delete comp.fields;
            }
        },
        prepare = function() {
            // change viewport designation
            $('span').removeClass('ui-mobile-viewport');
            $('#'+this.config.eid).addClass("ui-mobile-viewport");
            $.mobile.pageContainer = $('#'+this.config.eid);
    
            // fetch user metadata
            $V.App.getFn(this.config.cntrl).getUser(
                (function(that) {
                    return function(result, event) {
                        if (event.status && result && !result.errors) {
                            that.config.user = result;
                        } else {
                            $V.App.handleRemoteErrs(result, event, null, true);
                        }
                    };
                })(this)
            );
    
            // fetch field metadata
            if (this.config.fields && this.config.fields.length > 0) {
            $V.App.getFn(this.config.cntrl).getFieldMetadata(
                    this.config.fields,
                    (function(that) {
                        return function(result, event) {
                            if (event.status && result && !result.errors) {
                                that.config.fields = result;
                                that.log.debug('Field metadata', that.config.fields);
                            } else {
                                $V.App.handleRemoteErrs(result, event, null, true);
                            }
                        };
                    })(this)
                );
            }
            
            if ($.isEmptyObject(this.pages) && !$.isEmptyObject(this.components)) {
                for (compId in this.components) {
                    this.components[compId].render();
                }
            } 
        },
        getPage = function(id) {
            return this.pages[id];
        },
        getFn = function (name, context) {
            if (!name) return null;
            context = context || window;
            var namespaces, func = name;
            if (name.indexOf('.') > -1) {
                namespaces = name.split(".");
                func = namespaces.pop();
                for (var i = 0; i < namespaces.length; i++) {
                    context = context[namespaces[i]];
                }
            }
            return context[func];
        },
        // utils
        log = {
            prefix: 'Mobile VF: ',
            info: function(msg, obj) {
                msg = this.prefix + msg;
                if (console && console.log && console.groupCollapsed && console.groupEnd) {
                    if (obj) {
                        console.groupCollapsed(msg);
                        console.log(JSON.stringify(obj, undefined, 2));
                        console.groupEnd();
                    } else {
                        console.log(msg);
                    }
                }
            },
            debug: function(msg, obj) {
                if ($V.App && $V.App.debug && $V.App.debug == true) this.info(msg, obj);
            },
            error: function(msg, obj) {
                if (console && console.error) {
                    console.error(msg, obj);
                }
            }
        },
        toObject = function(arr) {
            if (!$.isArray(arr)) return arr;
            var rv = {};
            for (var i = 0; i < arr.length; ++i)
                if (arr[i] !== undefined) rv[arr[i]] = null;
            return rv;
        },
        getFieldVal = function(rec, fieldPath) {
            var fieldSplit = fieldPath.split('\.');
            if (fieldSplit.length > 1) {
                return getFieldVal(rec[fieldSplit[0]], fieldPath.substring(fieldSplit[0].length+1));
            }
            return rec[fieldSplit[0]];
        },
        getFieldValTemplate = function(fieldPath) {
            var fieldParts = fieldPath.split('.'),
                temp = '${' + fieldPath + '}';
                
            if (fieldParts.length > 1) {
                while (fieldParts.pop() && fieldParts.length) {
                    temp = ('{{if ' + fieldParts.join('.') + '}}' + temp + '{{/if}}');
                }
            }
            return temp;
        },
        // messages
        handleRemoteErrs = function(result, event, $el, display) {
            var markup = [], msg;
            markup.push('Errors:');
            if(event.status && result && !result.success) {
                if (result.errors) {
                    for (var i=0, len=result.errors.length; i < len; i++) {
                        markup.push('<br/>');
                        markup.push(result.errors[i].message);
                    }
                } else {
                    markup.join(' Unknown');
                }
            } else {
                markup.push(event.message, ' ', event.where);
            }
            msg = markup.join('');
            if (display && display === true) $V.App.displayMsgs(msg);
            if ($el && $el.trigger) $el.trigger('error', event, result);
            this.log.info(msg);
        },
        displayMsgs = function(msg) {
            //FIX:Needs to fix
        },
        clearMsgs = function() {
			//FIX:Needs to fix
        }; 
        // end var
    
        return {
            init: init,
            registerPage: registerPage,
            registerComponent: registerComponent,
            prepare: prepare,
            // utils
            debug: false,
            currentPage: null,
            getPage: getPage,
            getFn: getFn,
            log: log,
            toObject: toObject,
            getFieldVal: getFieldVal,
            getFieldValTemplate: getFieldValTemplate,
            // msgs
            handleRemoteErrs: handleRemoteErrs,
            displayMsgs: displayMsgs,
            clearMsgs: clearMsgs
        };
    }());
    
    /**
     * Base class for components.  Extend this class for custom components.
     */
    $V.Component = $V.Class.extend({
        init: function(config) {
            this.config = config || {};
            if (!config.id) throw Error('Config must have either id');
            this.$me = $('[id="'+ config.id + '"]');
            if (!config.id) throw Error('Element does not exist: ' + config.id);
        },
        prepare: function() {
            // to be implemented by extending class
            // any lazy loading that's required before render call
            this.prepared = true;
        },
        render: function() {
            this.prepare();
            // to be implemented by extending class
        },
        getContext: function() {
            return this.context;
        },
        parseField: function(field) {
            var idx = field.indexOf('.');
            if (idx > -1) return field.split('.');
            return [ null, field ];
        }
    });
    
    /**
     * Class representing pages and their lifecycle.
     */
    $V.Page = $V.Component.extend({
        init: function(id) {
            this._super({id: id});
            if (!this.comps) this.comps = [];
        },
        render: function() {
            this._super();
            if (this.comps) {
                $.each(this.comps, function() {
                    if (this.render) this.render();
                });
            }
        },
        rerender: function() {
            // when page is re-rendered
            if (this.comps) {
                $.each(this.comps, function() {
                    if (this.rerender) this.rerender();
                });
            }
        },
        postrender: function() {
            if (this.comps) {
                $.each(this.comps, function() {
                    if (this.postrender) this.postrender();
                });
            }
        }
    });
    
    /**
     * Class representing nav components and their lifecycle.  Extend to override standard nav component functionality.
     */
    $V.NavComponent = $V.Component.extend({
        init: function(config) {
            this._super(config);
            if (!this.config.pages) throw Error('Expected navigation config');
            try {
                this.config.nav = jQuery.parseJSON(this.config.pages.replace(/'/g, '"'));
            }catch(err) {
                $V.App.log.error('Unable to render navbar', err);
                return;
            }
            if (!this.config.nav && !$.isArray(this.config.nav)) throw Error('Expected navigation config to be an array');
        },
        render: function() {
            this.renderer();
        },
        renderer: function() {
            if (!this.config.nav) return;
            var markup = [], finalMarkup, $ul;
            for (var i=0, len=this.config.nav.length; i<len; i++) {
                if (!this.config.nav[i].page) continue;
                markup.push('<li><a href="', this.config.nav[i].page, '"');
                if (this.config.nav[i].iconCls) markup.push(' data-icon="', this.config.nav[i].iconCls, '"');
                markup.push('>');
                if (this.config.nav[i].name) markup.push(this.config.nav[i].name);
                markup.push('</a></li>');
            }
    
            finalMarkup = markup.join('');
            $V.App.log.debug('nav markup', finalMarkup);
            $ul = this.$me.find('ul');
            $ul.html(finalMarkup);
            $ul.parent().navbar(); // FIXME: rendering buttons on top instead of side-by-side
        },
        postrender: function() {
            this.$me.find('a').each(function(){
                var el = $(this);
                if ($V.App.nextPage && el.attr('href').indexOf($V.App.nextPage) > 0)
                    el.addClass('ui-btn-active');
            });
        }
    });
})(jQuery);

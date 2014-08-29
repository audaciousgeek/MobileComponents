(function($) {

    /**
     * Class representing list components and their lifecycle.  Extend to override standard list component functionality.
     */
    $V.ThumbnailListController = $V.Component.extend({
    
        // Override Component.init
        init: function(config) {
            this._super(config);
    
            // compile row template
            //$.template(this.config.elemId, this.getTemplate());
            
            // Attach event listeners.
            // When a list item is selected, we will navigate to nextPage,
            //   passing context.data to it.
            $(document).on('listitemselect', function(e, context) {
                var params = [];
                //if (context.config && context.config.nextPage) {
                    // only pass data for external pages - added as query params
                    // internal pages can use $V.App.context
                    //$.mobile.changePage(context.config.nextPage,
                       //(!$.mobile.path.isEmbeddedPage(context.config.nextPage) ? { data: context.data } : null));
                //}
            });
        },
        
        // Override Component.render
        render: function() {
            this._super();
            //this.load(this.renderer);
            
            // Load records from the server, and give it a function to handle the response.
            $.mobile.showPageLoadingMsg();
            var serverRecords = this.requestRecords(this.requestRecordsHandler);
            $.mobile.hidePageLoadingMsg();
            
            // Transform them to fit the structure of the template
            
        },
        
        requestRecords: function(responseHandler) {
            $V.App.log.debug('this.config: ', this.config);
            /*
            $V.App.getFn(this.config.serverCtlrName).getRecordsForConfigTest(
                {
                    testParam:'testtest'
                }
                ,
                // Callback
                (function(that, fn) {
                    return function(result, event) {
                            fn.apply(that, arguments);
                            //$.mobile.hidePageLoadingMsg();
                        };
                })(this, responseHandler)
            );
            */
            /*
            $V.App.getFn(this.config.serverCtlrName).getRecordsForConfig(
                {
                    sObjectType: this.config.sObjectType,
                    labelField: this.config.labelField,
                    subLabelField: this.config.subLabelField,
                    sortByField: this.config.sortByField
                },
                // Callback
                (function(that, fn) {
                    return function(result, event) {
                            fn.apply(that, arguments);
                            //$.mobile.hidePageLoadingMsg();
                        };
                })(this, responseHandler)
            );
            */
            var configProxy = {
                    sObjectType: this.config.sObjectType,
                    imageUrlField: this.config.imageUrlField,
                    labelField: this.config.labelField,
                    subLabelField: this.config.subLabelField,
                    sortByField: this.config.sortByField
                };
            $V.App.log.debug('configProxy: ', configProxy);
            $V.App.getFn(this.config.serverCtlrName).getRecordsForConfig(
                this.config
                ,
                // Callback
                (function(that, fn) {
                    return function(result, event) {
                            fn.apply(that, arguments);
                            //$.mobile.hidePageLoadingMsg();
                        };
                })(this, responseHandler)
            );
            
        },
        
        requestRecordsHandler: function(result, event) {
            // See what the response looks like.
            $V.App.log.debug(this.config.serverCtlrName + '.getRecords response: ', result);
            
            // Transform the response list of records to match the template.
            var model = {};
            model.records = [];
            for (var i = 0; i < result.length; i++) {
                var record = result[i];
                $V.App.log.debug('Received record: ', record);
                model.records.push(record)
            }
            $V.App.log.debug('Finished model: ', model);
            /*
            var model = new Object();
            model.list = result;
            $V.App.log.debug('Finished model: ', model);
            */
            
            // Push the data into the template.
            var listItemsMarkup = ich.rowItemTempl(model, true);
            $V.App.log.debug('Template result: ', listItemsMarkup);
            
            // Render the markup to the DOM.
            $ul = this.$me.find('ul');
            $ul.html(listItemsMarkup);
            
            // After mark up is rendered, apply events.
            this.applyEvents($ul);
        },
        
        
        // Helper method for render method.
        // Shows loading indicator while we load data from server.
        load: function(handler) {
            $.mobile.showPageLoadingMsg();
            $V.App.getFn(this.config.serverCtlrName).invoke(
                { config: {
                       stype: this.config.stype,
                       labelField: this.config.labelField,
                       subLabelField: this.config.subLabelField,
                       sortByField: this.config.sortByField,
                       filter: this.config.filter,
                       filterClause: this.config.filterClause }
                },
                (function(that, fn) {
                    return function(result, event) {
                            fn.apply(that, arguments);
                            $.mobile.hidePageLoadingMsg();
                        };
                })(this, handler)
            );
        },
        
        // Helper method for render method.
        // This method is called on the response from the server controller.
        // Finds each record and renders it to the DOM using the specified
        //   template.
        renderer: function(result, event) {
            var markup = [],
                isStringSorted = (typeof this.config.sortByField == 'string'),
                tmpAlpha,
                currAlpha = '',
                finalMarkup,
                $ul,
                rec;
                
            if (event.status && result && result.success && result.records) {
                // TODO: What does 'this' refer to here?
                this.records = {};
                for (var i=0, len=result.records.length; i<len; i++) {
                    rec = result.records[i];
                    this.records[rec.Id] = rec;
                    
                    // TODO: validate that all fields are present: this.config.fields, this.config.sortField
                    // Add list dividers if the sort by field is string.
                    if (isStringSorted) {
                        // Get first letter of the value of the sortByField...
                        tmpAlpha = $V.App.getFieldVal(result.records[i], this.config.sortByField);
                        if (tmpAlpha)
                          tmpAlpha = tmpAlpha.substr(0, 1).toUpperCase();
                        else
                          tmpAlpha = '-';
                        
                        //...and add it to the markup.
                        if (tmpAlpha !== currAlpha) {
                            markup.push('<li data-role="list-divider"');
                            if (this.config.listDividerStyleClass) 
                              markup.push(' class="', this.config.listDividerStyleClass, '"');
                            else
                              markup.push('>');
                            markup.push(tmpAlpha, '</li>');
                            currAlpha = tmpAlpha;
                        }
                    }
                    
                    //
                    markup.push('<li data-item-context='+ rec['Id']);
                    if (this.config.listItemStyleClass) markup.push(' class="' + this.config.listItemStyleClass);
                    markup.push('>');
                    
                    //Hmmm.
                    $.tmpl(this.config.elemId, rec).each(
                      function() {
                        markup.push(this.outerHTML);
                      });
                      
                    markup.push('</li>');
                }
                
                // Set the HTML of the root element to what we just generated.
                finalMarkup = markup.join('');
                $V.App.log.info('listview markup', finalMarkup);
                $ul = this.$me.find('ul');
                $ul.html(finalMarkup);
    
                // After mark up is rendered, apply events.
                this.applyEvents($ul);
            } else {
                $V.App.handleRemoteErrs(result, event, this.$me, true);
            }
        },
        
        // Helper method for renderer method.
        // Adds 'listitemselect' event to each element.
        applyEvents: function($el) {
            $el.tap(
                (function(comp) {
                    return function(e) {
                        var data, $target = $(e.target).closest('li', comp.$me);
                        e.preventDefault();
                        if ($target && !$target.is('[data-role="list-divider"]')) {
                            comp.$me.removeClass('cellselected');
                            $target.addClass('cellselected');
                            //data = [{config: {stype: comp.config.sObjectType, nextPage: comp.config.nextPage}, data: comp.records[$target.attr('data-item-context')]}];
                            //data = [];
                            // REVIEWME: narrow event firing scope to this component?
                            $(document).trigger('listitemselect', data);
                            $target.trigger('hide');
                        }
                    }
                })(this));
        },
        getTemplate: function() {
        }
    });
    
})(jQuery);

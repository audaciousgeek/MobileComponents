(function($) {
    
    /**
     * Class representing detail components and their lifecycle.  Extend to override standard detail component functionality.
     */
    $V.DetailComponent = $V.Component.extend(
    (function() {
        // REVIEWME: how come?
        //Private methods.
        var getLayoutMarkup = function(layout) {
            var markup = ['<div class="layout">'];
            $.each(layout.detailSections, function() {
                var section = this;
                markup.push('<section class="layoutSection">');
                if (section.heading) {
                    markup.push('<header>');
                    markup.push('<h4 style="font-weight: bold; font-size: 16px;  border-bottom: 3px solid #1797C0;padding: 0 0 8px; margin: 20px 25px 8px;display: inline-block;">');
                    markup.push(section.heading);
                    markup.push('</h4>');
                    markup.push('<hr style="height: 1px; padding-left: 25px; border: 1px solid rgb(220, 220, 220); margin-top: -11px;"/>');
                    markup.push('</header>');
                }
                markup.push('<fieldset style="margin: 0px 25px;">');
                for (var idx=0; idx < section.items.length;) {
                    markup.push('<div class="ui-grid-a">');
                    for (var col=0; col < section.columns && section.items.length > (idx+col) ; col++) {
                        var item = section.items[idx+col];
                        if (col == 0) markup.push('<dl class="ui-block-a">');
                        else markup.push('<dl class="ui-block-b">');
                        markup.push('<dt class="fieldLbl">');
                        markup.push(item.label);
                        markup.push('</dt>');
                        markup.push('<dd class="fieldVal">');
                        markup.push(item.valueTemplate);
                        markup.push('</dd>');
                        markup.push('</dl>');
                    }
                    markup.push('</div>');
                    idx += section.columns;
                }
                markup.push('</fieldset>');
                markup.push('</section>');
            });
            markup.push('</div>');
            return markup.join('');
        }
        
        var tmplOptions = {
            //REVIEW: Encode values?
            value: function(type, val) {
                var markup = [];
                switch (type) {
                    case 'DATETIME': markup.push(new Date(val)); 
                         break;
                    case 'DATE': markup.push(new Date(val).toDateString()); 
                         break;
                    case 'PHONE': markup.push('<a href="tel:');
                         markup.push(val.trim().substring(0,1) == '+' ? '+' : '');
                         markup.push(val.replace(/[^0-9]/g,''));
                         markup.push('">' + val + '</a>');
                         break;
                    case 'EMAIL': markup.push('<a href="mailto:' + val.trim() + '">');
                         markup.push(val + '</a>');
                         break;
                    case 'URL': markup.push('<a target="_blank" href="' + val.trim() + '">');
                         markup.push(val + '</a>');
                         break;
                    case 'BOOLEAN': markup.push('<input type="checkbox"');
                         markup.push( val ? 'checked' : 'unchecked');
                         markup.push(' readonly disabled/>');
                         break;
                    default: markup.push(val);
                }
                return markup.join('');
            }
        }
        
        return {
            //Constructor
            init: function(config) {
                var that = this;
                that._super(config);
                
                //$(document).on('listitemselect', function(e, context) {
                    //if (context.config.stype == that.config.stype) that.render(context.data.Id);
                //});
            },
            //Before render. Get data from server and create HTML templates.
            prepare: function() {
                if (!this.prepared && !this.layouts) {
                    this._super();
                    //Fetch layout metadata, create HTML template for each record type.
                    $V.App.getFn(this.config.serverCtlrName).invoke({config: {stype: this.config.stype}},
                        (function(comp) {
                            return function(result, event) {
                                // TODO: handle errors
                                if (result && result.success) {
                                    comp.layouts = result.layouts;
                                    comp.allFields = [];
                                    $.each(comp.layouts, function() {
                                        comp.allFields = comp.allFields.concat(this.sFieldNames);
                                        $.template(comp.config.stype+'.'+this.recordTypeId, getLayoutMarkup(this));
                                    });
                                    if (comp.layouts.length > 1) comp.allFields.push('RecordTypeId');
                                    //Filter unique fields
                                    comp.allFields = comp.allFields.sort().filter(
                                        function(val, idx, arr) {
                                            return (!idx || arr[idx-1] != val);
                                        }
                                    );
                                }
                            }
                        })(this), {escape: false}
                    );
                }
            },
            //Generate HTML and insert into DOM.
            render: function(sobjectId) {
                this._super();
                //FIX:If there is id in Url, pick that and load, else do nothing
                //this.load(sobjectId, this.renderer);
                if (sobjectId) {
                    var that = this;
                    if (!that.allFields) setTimeout(function() { that.render(sobjectId); }, 100);
                    else that.load(sobjectId, that.renderer);
                }
            },
            //Load data from server, then pass to renderer.
            load: function(sobjectId, handler) {
                this.$me.trigger('pageload');
                $.mobile.showPageLoadingMsg();
                this.$me.empty();
                $V.App.getFn(this.config.serverCtlrName).querySObject(
                    {stype: this.config.stype}, sobjectId, this.allFields, 
                    (function(that, fn) {
                        return function(result, event) {
                            fn.apply(that, arguments);
                            $.mobile.hidePageLoadingMsg();
                        };
                    })(this, handler)
                );
            },
            //Render JSON records into template cached in prepare method.
            renderer: function(result, event) {
                var markup = [], layout, data;
                if (event.status && result && result.success && result.records) {
                    if ($.isArray(result.records) && result.records.length == 1) {
                        if (this.layouts.length > 1)  {
                            layout = this.layouts.filter(function(val) {
                            if (result.records[0].RecordTypeId) return val.recordTypeId == result.records[0].RecordTypeId;
                                else return val.defaultRecordTypeMapping; 
                            })[0];
                        } else if (this.layouts.length == 1) layout = this.layouts[0];
                        
                        this.$me.empty();
                        $.tmpl(this.config.stype + '.' + layout.recordTypeId, result.records[0], tmplOptions).appendTo(this.$me);
                        data = [{config: {stype: this.config.stype}, data: result.records[0]}];
                        // REVIEWME: narrow event firing scope to this component?
                        $(document).trigger('detailloaded', data);
    
                        $V.App.log.debug('detail markup added');
                    } else {
                        // REVIEWME: what if >1 recs are returned?  assume first?
                    }
                } else {
                    $V.App.handleRemoteErrs(result, event, this.$me, true);
                }
            }
        }//end return statement
     })()
    );
    
})(jQuery);

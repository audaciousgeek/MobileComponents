(function($) {

    /**
     * Class representing list components and their lifecycle.  Extend to override standard list component functionality.
     */
    $V.ListComponent = $V.Component.extend({
        init: function(config) {
            this._super(config);
    
            // compile row template
            $.template(this.config.elemId, this.getTemplate());
            
            $(document).on('listitemselect', function(e, context) {
                var params = [];
                if (context.config && context.config.nextPage) {
                    // only pass data for external pages - added as query params
                    // internal pages can use $V.App.context
                    $.mobile.changePage(context.config.nextPage,
                       (!$.mobile.path.isEmbeddedPage(context.config.nextPage) ? { data: context.data } : null));
                }
            });
        },
        render: function() {
            this._super();
            this.load(this.renderer);
        },
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
        renderer: function(result, event) {
            var markup = [],
                alphaGrp = (typeof this.config.sortByField == 'string'),
                tmpAlpha,
                currAlpha = '',
                finalMarkup,
                $ul,
                rec;
            if (event.status && result && result.success && result.records) {
                this.records = {};
                for (var i=0, len=result.records.length; i<len; i++) {
                    rec = result.records[i];
                    this.records[rec.Id] = rec;
                    // TODO: validate that all fields are present: this.config.fields, this.config.sortField
                    if (alphaGrp) {
                        tmpAlpha = $V.App.getFieldVal(result.records[i], this.config.sortByField);
                        if (tmpAlpha) tmpAlpha = tmpAlpha.substr(0, 1).toUpperCase();
                        else tmpAlpha = '-';
                        
                        if (tmpAlpha !== currAlpha) {
                            markup.push('<li data-role="list-divider"');
                            if (this.config.listDividerStyleClass) 
                                markup.push(' class="', this.config.listDividerStyleClass, '"');
                            else markup.push('>');
                            markup.push(tmpAlpha, '</li>');
                            currAlpha = tmpAlpha;
                        }
                    }
                    markup.push('<li data-item-context='+ rec['Id']);
                    if (this.config.listItemStyleClass) markup.push(' class="' + this.config.listItemStyleClass);
                    markup.push('>');
                    $.tmpl(this.config.elemId, rec).each(function() { markup.push(this.outerHTML); });
                    markup.push('</li>');
                }
                // apply generated markup
                finalMarkup = markup.join('');
                $V.App.log.info('listview markup', finalMarkup);
                $ul = this.$me.find('ul');
                $ul.html(finalMarkup);
    
                // after mark up is rendered, apply events
                this.applyEvents($ul);
                } else {
                $V.App.handleRemoteErrs(result, event, this.$me, true);
            }
        },
        applyEvents: function($el) {
            $el.tap(
                (function(comp) {
                    return function(e) {
                        var data, $target = $(e.target).closest('li', comp.$me);
                        e.preventDefault();
                        if ($target && !$target.is('[data-role="list-divider"]')) {
                            comp.$me.removeClass('cellselected');
                            $target.addClass('cellselected');
                            data = [{config: {stype: comp.config.stype, nextPage: comp.config.nextPage}, data: comp.records[$target.attr('data-item-context')]}];
                            // REVIEWME: narrow event firing scope to this component?
                            $(document).trigger('listitemselect', data);
                            $target.trigger('hide');
                        }
                    }
                })(this));
        },
        getTemplate: function() {
            var template = [], lblFieldParts, subLblFieldParts, temp;
            if (this.config.labelField) {
                template.push('<h3 class="ui-li-heading">');
                template.push($V.App.getFieldValTemplate(this.config.labelField));
                template.push('</h3>');
            }
            if (this.config.subLabelField) {
                template.push('<p class="ui-li-desc">');
                template.push($V.App.getFieldValTemplate(this.config.subLabelField));
                template.push('</p>');
            }
            return template.join('');
        }
    });
    
})(jQuery);

(function($) {

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

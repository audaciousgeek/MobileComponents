(function($) {

     /**
     * Class representing pages and their lifecycle.
     */
    $V.Page = $V.Component.extend({
        init: function(id) {
            this._super({elemId: id});
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
    
})(jQuery);

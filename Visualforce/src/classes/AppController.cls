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

/**
 * Controller for App component.
 */
public class AppController extends BaseConfigController {

    private final static String JQUERY_JS = 'http://code.jquery.com/jquery-1.7.1.min.js';
    private final static String JQUERY_JS_DEBUG = 'http://code.jquery.com/jquery-1.7.1.js';
    private final static String JQUERY_TEMPLATE_JS = 'http://ajax.microsoft.com/ajax/jquery.templates/beta1/jquery.tmpl.min.js';
    private final static String JQUERY_TEMPLATE_JS_DEBUG = 'http://ajax.microsoft.com/ajax/jquery.templates/beta1/jquery.tmpl.js';
    private final static String JQUERY_MOBILE_JS = 'jqm11js';
    private final static String I_CAN_HAZ_JS = 'ICanHaz';
    private final static String MOBILE_SPLIT_VIEW_JS = 'jqmSVjs';
    private final static String MOBILE_SDK_JS = 'MobileVisualforceSDKjs';

    /**
     * App component config options.
     */
    public virtual class AppConfig extends BaseConfig {
        public Boolean debug { get; set; }
        String serverCtlrName = getFullyQualifiedClassName(AppController.class);
    }

    public AppController() {
        super(new AppConfig());
    }

    public AppConfig getConfig() {
        return (AppConfig)config;
    }

    public String getJqueryJsUrl() {
        return getConfig().debug ? JQUERY_JS_DEBUG : JQUERY_JS;
    }

    public String getJqueryTemplateJsUrl() {
        return getConfig().debug ? JQUERY_TEMPLATE_JS_DEBUG : JQUERY_TEMPLATE_JS;
    }

    public String getJqueryMobileJs() {
        return getConfig().debug ? JQUERY_MOBILE_JS : (JQUERY_MOBILE_JS + 'Min');
    }
    
    public String getICanHazJs() {
    	return getConfig().debug ? I_CAN_HAZ_JS : (I_CAN_HAZ_JS + 'Min');
    }

    public String getMobileSplitViewJs() {
        return getConfig().debug ? MOBILE_SPLIT_VIEW_JS : (MOBILE_SPLIT_VIEW_JS + 'Min');
    }
    
    public String getMobileSDKJs() {
        return getConfig().debug ? MOBILE_SDK_JS : (MOBILE_SDK_JS + 'Min');
    }
    
    public Component.Apex.OutputPanel getAdditionalScripts() {
    	Component.Apex.OutputPanel panel = new Component.Apex.OutputPanel(layout='none');
	
        return panel;
    }

    @RemoteAction
    public static Map<String,Object> getUser() {
        Map<String,Object> user = new Map<String,Object>();
        user.put('name', UserInfo.getName());
        user.put('locale', UserInfo.getLocale());
        user.put('orgId', UserInfo.getOrganizationId());
        user.put('orgName', UserInfo.getOrganizationName());
        return user;
    }

    @RemoteAction
    public static Map<String,SObjectController.FieldMetadata> getFieldMetadata(List<String> fullyQualifiedFields) {
        return SObjectController.getFieldMetadata(fullyQualifiedFields);
    }
}

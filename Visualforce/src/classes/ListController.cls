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
 * Controller for List component.
 */
public class ListController extends SObjectController {

    // config for list component
    public virtual class ListConfig extends SObjectConfig {

        public String labelField { get;
            set {
                labelField = value;
                addField(labelField);
            }}
        public String subLabelField { get;
            set {
                subLabelField = value;
                addField(subLabelField);
            }}
        public String filter { get; set; }
        public String listItemStyleClass { get; set; }
        public String listDividerStyleClass { get; set; }
        public String goToPage { get; set; } // FIXME: rename


        public String cntrl = getFullyQualifiedClassName(ListController.class);
    }

    // incoming list-based remote request
    public class ListRequest extends RemoteRequest {
        protected ListConfig config;
        public ListRequest(ListConfig config, Map<String, String> values) {
            super(values);
            this.config = config;
        }

        public ListConfig getConfig() {
            return config;
        }
    }

    // constructors
    public ListController() {
        super(new ListConfig());
    }

    public ListController(ListConfig config) {
        super(config);
    }

    public ListConfig getConfig() {
        return (ListConfig)config;
    }

    @RemoteAction
    public static SObjectResponse invoke(ListRequest listRequest) {
        ListController controller = new ListController(listRequest.getConfig());

        return new SObjectResponse(controller.getDescribe().getSObjectType(), controller.getList(), DateTime.now());
    }

    public List<SObject> getList() {
        DescribeSObjectResult descInfo = this.getDescribe();
        Map<String, SObjectField> fieldMap = descInfo.fields.getMap();

        String soql = 'SELECT ';
        String sortByFilter = '';

        Set<String> fieldsToQuery = new Set<String>();
        fieldsToQuery.add('id');
        if (SchemaManager.isFieldAccessible(descInfo.getSobjectType(), getConfig().labelField))
            fieldsToQuery.add(getConfig().labelField);

        if (SchemaManager.isFieldAccessible(descInfo.getSobjectType(), getConfig().subLabelField))
            fieldsToQuery.add(getConfig().subLabelField);

        if (SchemaManager.isFieldAccessible(descInfo.getSobjectType(), getConfig().sortByField)) {
            fieldsToQuery.add(getConfig().sortByField);
            sortByFilter = (' ORDER BY ' + getConfig().sortByField);
        }

        for (String field : fieldsToQuery) soql += (field + ',');
        soql = soql.subString(0, soql.length()-1);

        soql += (' FROM ' + this.getName());

        if (getConfig().filter != null && getConfig().filter.length() > 0) {
            if (getConfig().filter.equalsIgnoreCase('owner')) soql += (' WHERE ownerId = \'' + UserInfo.getUserId() + '\'');
            else if (this.isFeedEnabled() && getConfig().filter.equalsIgnoreCase('follow')) {
                soql += (' WHERE Id IN (SELECT ParentId FROM EntitySubscription WHERE parent.type = \'' + this.getName() + '\'' +
                                        ' AND SubscriberID = \'' + UserInfo.getUserId() + '\')');
            }
        }

        soql += (sortByFilter + ' LIMIT 500'); // FIXME: reduce to much less, say 25 or 50, at most

        return Database.query(soql);
    }
}
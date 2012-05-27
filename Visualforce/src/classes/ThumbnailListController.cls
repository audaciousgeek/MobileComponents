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
//public class ListController extends SObjectController {
public class ThumbnailListController {
    
    private final static String THUMBNAIL_LIST_JS = 'ThumbnailListJS';
    public ThumbnailListConfig config {get; set;}
    
    // Parameter object to pass between JS controller and server controller.
    public virtual class ThumbnailListConfig {

        public Boolean debug { get; set; }
        // The elemId is generated in VF and sent to client. The controller gets
        //   it when a remoting call is made.
        public String elemId {get; set;}
        public String sObjectType {get; set;}
        public String imageUrlField {get; set;}
        public String labelField {get; set;}
        public String subLabelField {get; set;}
        public String sortByField {get; set;}
        public String filter { get; set; }
        public String filterClause {get; set;}
        public String listItemStyleClass { get; set; }
        public String listDividerStyleClass { get; set; }
        public String nextPage { get; set; }
        //public String serverCtlrName = SObject.getFullyQualifiedClassName(ListController.class);
        public String serverCtlrName = 'ThumbnailListController';
        public String jsCtlrName {get; set;}
    }

    // constructors
    public ThumbnailListController() {
        this.config = new ThumbnailListConfig();
    }
    public ThumbnailListController(ThumbnailListConfig config) {
        this.config = config;
    }

    public String getThumbnailListJS() {
        return config.debug ? THUMBNAIL_LIST_JS : (THUMBNAIL_LIST_JS + 'Min');
    }
    
    public virtual String getConfigAsJson() {
        String configStr = JSON.serialize(this.config);
        System.debug(configStr);
        return configStr;
    }
    
    /*
    @RemoteAction
    public static SObjectResponse invoke(ListRequest listRequest) {
        ListController controller = new ListController(listRequest.getConfig());

        return new SObjectResponse(controller.getDescribe().getSObjectType(), controller.getList(), DateTime.now());
    }
    */
    
    public class TestResponse {
        public String testParam {get; set;}
        public String testParam2 {get; set;}
    }
    
    @RemoteAction
    public static String getRecordsForConfigTest(TestResponse test) {
        System.debug(' testing... ' + test);
        return ' testing success!';
    }
    
    @RemoteAction
    public static List<Sobject> getRecordsForConfig(ThumbnailListConfig config) {
        System.debug('--- config: ' + config);
        Set<String> fieldsToQuerySet = new Set<String>();
        fieldsToQuerySet.add(config.imageUrlField);
        fieldsToQuerySet.add(config.labelField);
        fieldsToQuerySet.add(config.subLabelField);
        fieldsToQuerySet.add(config.sortByField);
        
        List<Sobject> recordList = ThumbnailListController.getRecords(
                config.sObjectType,
                fieldsToQuerySet,
                UserInfo.getUserId()
                );
        
        return recordList;
    }
    
    public static List<Sobject> getRecords(
            String sObjectType,
            Set<String> fieldsToQuerySet,
            Id userId) {
        
        List<Sobject> recordList = new List<Sobject>();
        
        String queryString = '';
        
        // Build the Select clause.
        queryString += 'SELECT ';
        for (String field : fieldsToQuerySet)
            queryString += (field + ',');
        queryString = queryString.subString(0, queryString.length()-1);
            
        // Build the From clause.
        queryString += ' FROM ' + sObjectType;
        
        // Build the Where clause.
        queryString += ' WHERE ';
        queryString += ' LastModifiedById = \'' + userId + '\'';
        
        System.debug('queryString: ' + queryString);
        
        recordList = Database.query(queryString);
        
        return recordList;
    }
    


/*
    public List<SObject> getList() {
        DescribeSObjectResult descInfo = this.getDescribe();
        Map<String, SObjectField> fieldMap = descInfo.fields.getMap();
        ListConfig config = (ListConfig)this.config;
        
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
        
        String whereClause = '';

        if (getConfig().filter != null && getConfig().filter.length() > 0) {
            if (getConfig().filter.equalsIgnoreCase('owner')) soql += (' WHERE ownerId = \'' + UserInfo.getUserId() + '\'');
            else if (this.isFeedEnabled() && getConfig().filter.equalsIgnoreCase('follower')) {
                whereClause += (' Id IN (SELECT ParentId FROM EntitySubscription WHERE parent.type = \'' + this.getName() + '\'' +
                                        ' AND SubscriberID = \'' + UserInfo.getUserId() + '\')');
            }
        }
        if (config.filterClause != null && config.filterClause != '') {
            whereClause += (whereClause != '') ? ' AND ' : '';
            whereClause += config.filterClause;//REVIEWME: Worry about escaping this?
        }
        
        if (whereClause.length() > 0) {
            soql += ' WHERE ' + whereClause;
        }
        
        soql += (sortByFilter + ' LIMIT 500'); // FIXME: reduce to much less, say 25 or 50, at most
        System.debug('soql: ' + soql);

        return Database.query(soql);
    }
    */
}

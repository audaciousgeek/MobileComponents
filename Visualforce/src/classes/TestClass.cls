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

@isTest(SeeAllData=true)
public class TestClass {
    
    static testmethod void testListController() {
    	if (SchemaManager.getObject('account') != null) {
    		List<SObject> accounts = Database.query('SELECT id from Account limit 1');
    		if (accounts != null && !accounts.isEmpty()) {
    			ListController.ListConfig config = new ListController.ListConfig();
    			config.stype = 'account';
    			config.labelField = 'name';
    			config.subLabelField = 'name';
    			config.sortByField = 'name';
    			ListController.ListRequest req = new ListController.ListRequest(config, null);
    			SObjectResponse resp = ListController.invoke(req);
    			System.assert(resp != null, 'List response must not be null.');
    			System.assert(resp.records != null && !resp.records.isEmpty(), 'SObject records must not be null.');
    			
    			//Try with owner filter
    			config.filter = 'owner';
    			resp = ListController.invoke(req);
    			System.assert(resp != null, 'List response must not be null.');
    			
    			//Try with follow filter
    			config.filter = 'follow';
                resp = ListController.invoke(req);
                System.assert(resp != null, 'List response must not be null.');
                
                //Just for code coverage
                ListController controller = new ListController();
    		}
    	}
    }
    
    static testmethod void testDetailControllerQuery() {
        if (SchemaManager.getObject('account') != null) {
            List<SObject> accounts = Database.query('SELECT id from Account limit 1');
            if (accounts != null && !accounts.isEmpty()) {
            	Map<String, SObjectField> fieldMap = SchemaManager.getDescribe('account').fields.getMap();
            	List<String> fields = new List<String>();
            	fields.addAll(fieldMap.keyset());
            	
                DetailController.DetailConfig config = new DetailController.DetailConfig();
                config.stype = 'account';

                SObjectResponse resp = DetailController.querySObject(config, accounts[0].id, fields);
                System.assert(resp != null, 'List response must not be null.');
                System.assert(resp.records != null && !resp.records.isEmpty(), 'SObject records must not be null.');
                                
                //Just for code coverage
                DetailController controller = new DetailController();
            }
        }
    }
    
    static testmethod void testDetailControllerLayout() {
        if (SchemaManager.getObject('account') != null) {
        	SFDCPartnerSoap.DescribeLayoutResult layoutInfo = new SFDCPartnerSoap.DescribeLayoutResult();
        	
        	SFDCPartnerSoap.RecordTypeMapping recordTypeMap = new SFDCPartnerSoap.RecordTypeMapping();
        	recordTypeMap.layoutId = '00hd000000N1STj';
        	recordTypeMap.recordTypeId = '012d00000003n8L';
        	recordTypeMap.defaultRecordTypeMapping = true;
        	layoutInfo.recordTypeMappings = new SFDCPartnerSoap.RecordTypeMapping[]{recordTypeMap};
        	
        	SFDCPartnerSoap.DescribeLayout layoutDesc = new SFDCPartnerSoap.DescribeLayout();
        	layoutDesc.id = '00hd000000N1STj';
        	layoutInfo.layouts = new SFDCPartnerSoap.DescribeLayout[]{layoutDesc};
        	
        	SFDCPartnerSoap.DescribeLayoutSection sectionDesc = new SFDCPartnerSoap.DescribeLayoutSection();
        	sectionDesc.heading = 'Section heading';
        	sectionDesc.columns = 2;
        	layoutDesc.detailLayoutSections = new SFDCPartnerSoap.DescribeLayoutSection[]{sectionDesc};
        	
        	SFDCPartnerSoap.DescribeLayoutRow row = new SFDCPartnerSoap.DescribeLayoutRow();
        	sectionDesc.layoutRows = new SFDCPartnerSoap.DescribeLayoutRow[]{row};
        	
        	SFDCPartnerSoap.DescribeLayoutItem itemDesc = new SFDCPartnerSoap.DescribeLayoutItem();
        	itemDesc.label = 'Item Label';
        	row.layoutItems = new SFDCPartnerSoap.DescribeLayoutItem[]{itemDesc};
        	
        	SFDCPartnerSoap.DescribeLayoutComponent comp = new SFDCPartnerSoap.DescribeLayoutComponent();
        	comp.type_x = 'Field';
        	comp.value = 'Name';
        	itemDesc.layoutComponents = new SFDCPartnerSoap.DescribeLayoutComponent[]{comp};
            
            DetailController.DetailConfig config = new DetailController.DetailConfig();
            config.stype = 'account';
            
            DetailController controller = new DetailController(config);
            List<DetailController.Layout> layouts = controller.parseLayouts(layoutInfo);

            System.assert(layouts != null && !layouts.isEmpty(), 'Layouts must not be null or empty.');
        }
    }

    static testmethod void testGetFieldMetadata() {
        List<String> fields = new String[] { 'Account.Id', 'Account.NumberOfEmployees', 'Contact.Name',
            'Opportunity.CloseDate' };
        Map<String,SObjectController.FieldMetadata> fieldMetadata = SObjectController.getFieldMetadata(fields);
        System.assert(fieldMetadata != null && fieldMetadata.size() == 4,
            'Expect metadata list of size 4 got ' + (fieldMetadata != null ? fieldMetadata.size() : 0));
        System.debug(Json.serialize(fieldMetadata));
        for (String field : fields) {
            SObjectController.FieldMetadata metadata = fieldMetadata.get(field);
            System.assert(metadata != null, 'Expect metadata for ' + field);
            System.assert(metadata.name != null, 'Expect name metadata for ' + field);
            System.assert(metadata.label != null, 'Expect label metadata for ' + field);
            System.assert(metadata.type != null, 'Expect type metadata for ' + field);
        }
    }

    static testmethod void testGetUser() {
        Map<String,Object> user = AppController.getUser();
        System.assert(user != null && user.size() > 3,
            'Expect user map of size >3 got ' + (user != null ? user.size() : 0));
        System.debug(Json.serialize(user));
        System.assert(user.get('name') != null, 'Expect name value for user');
        System.assert(user.get('locale') != null, 'Expect locale value for user');
        System.assert(user.get('orgId') != null, 'Expect orgId value for user');
        System.assert(user.get('orgName') != null, 'Expect orgName value for user');
    }
}
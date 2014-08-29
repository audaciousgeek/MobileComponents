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
* Exposes 1 method: 1) Get all layout infos
layouts: [{
    id:
    recordTypeId:
    recordTypeName:
    defaultRecordTypeMapping:
    name: <not available>
    sFieldNames:['field1', 'field2']
    detailSections: [{
        heading:
        columns:
        items: [{
            label:
            dataType:field|template|emptyspace
            valueTemplate:"${field1}, ${field2}"
        }, ... ]
    }, ... ]
}, ... ]

Once layout info is fetched, future calls are just query calls directly from SObjectController
**/

public with sharing class DetailController extends SObjectController {

    private final static String DETAIL_COMPONENT_JS = 'DetailComponentJS';
    
    public virtual class DetailConfig extends SObjectConfig {
        public Boolean debug { get; set; }
        public String serverCtlrName = getFullyQualifiedClassName(DetailController.class);
    }

    public DetailController() {
        super(new DetailConfig());
    }

    public DetailController(DetailConfig config) {
        super(config);
    }

    public DetailConfig getConfig() {
        return (DetailConfig)config;
    }
    
    public String getDetailComponentJS() {
        return getConfig().debug ? DETAIL_COMPONENT_JS : (DETAIL_COMPONENT_JS + 'Min');
    }
    
    public class LayoutResponse extends RemoteResponse {
        List<Layout> layouts;
        public LayoutResponse(List<Layout> layouts) {
            super(true, null, DateTime.now());
            this.layouts = layouts;
        }
    }

    public class Layout {
    	Id id;
    	Id recordTypeId;
    	String recordTypeName;
    	Boolean defaultRecordTypeMapping;
    	List<LayoutSection> detailSections;
    	Set<String> sFieldNames;
    	
    	public Layout() {
    		this.detailSections = new List<LayoutSection>();
    		this.sFieldNames = new Set<String>();
    	}
    }

    private class LayoutSection {
        public List<LayoutItem> items {get; private set;}
        public Integer columns {get; private set;}
        public String heading {get; private set;}

        private LayoutSection(String heading, Integer cols) {
            this.heading = heading;
            this.columns = cols;
            this.items = new List<LayoutItem>();
        }
    }

    public class LayoutItem {
        public String label {get; private set;}
        public String dataType {get; private set;}
        public String valueTemplate = '';
        
        public LayoutItem(String label) {
            this.label = label;
        }

        private void setType(String dataType) {
            if (this.dataType == null) this.dataType = dataType.toLowerCase();
            else this.dataType = 'template';
        }
        private void addComponent(SObjectType objectType, Layout layout, SFDCPartnerSoap.DescribeLayoutComponent comp) {
        	if (comp.type_x.equalsIgnoreCase('Field')) {
        		layout.sFieldNames.add(comp.value);
        		Schema.DescribeFieldResult fieldDesc = SchemaManager.getFieldDescribe(objectType, comp.value);
        		if (fieldDesc.getType() == Schema.DisplayType.Reference) {
        			String nameField = SchemaManager.getNameFieldForReferenceField(fieldDesc);
        			this.valueTemplate += '{{if '+ fieldDesc.getRelationshipName() +'}}${' + nameField + '}{{/if}}';
        			layout.sFieldNames.add(nameField);
        		} else {
        			this.valueTemplate += '{{if typeof('+ comp.value +') != "undefined"}}' +
        			                      '{{html $item.value("' + fieldDesc.getType() + '",' + comp.value + ')}}' + 
        			                      '{{/if}}';
        		}
        	} else if (comp.type_x.equalsIgnoreCase('Separator')) this.valueTemplate += comp.value;

            
            this.setType(comp.type_x);
        }
    }
    
    // incoming list-based remote request
    public class LayoutRequest extends RemoteRequest {
        protected DetailConfig config;
        public LayoutRequest(DetailConfig config, Map<String, String> values) {
            super(values);
            this.config = config;
        }

        public DetailConfig getConfig() {
            return config;
        }
    }

    @RemoteAction
    public static LayoutResponse invoke(LayoutRequest remoteRequest) {
    	DetailController controller = new DetailController(remoteRequest.getConfig());

        return new LayoutResponse(controller.fetchLayouts());
    }
    
    @RemoteAction
    public static SObjectResponse querySObject(DetailConfig config, Id sobjectId, List<String> sFieldNames) {
    	DetailController controller = new DetailController(config);
    	
    	Set<String> fieldsToQuery = new Set<String>();
    	sFieldNames.add('id');
    	for (String fieldName : sFieldNames) fieldsToQuery.add(fieldName.toLowerCase());
    	
        return new SObjectResponse(controller.getDescribe().getSObjectType(), 
            controller.querySObject(fieldsToQuery, new Id[] {sobjectId}), DateTime.now());
    }
    
    private List<Layout> fetchLayouts() {

        SFDCPartnerSoap.DescribeLayoutResult layoutInfos = SFDCApiClient.describeLayout(this.getName(), null);
        return parseLayouts(layoutInfos);
    }
    
    public List<Layout> parseLayouts(SFDCPartnerSoap.DescribeLayoutResult layoutInfos) {

        List<Layout> layouts = new List<Layout>();
        Map<Id, SFDCPartnerSoap.RecordTypeMapping> layoutToRecordTypeMap = new Map<Id, SFDCPartnerSoap.RecordTypeMapping>();

        for (SFDCPartnerSoap.RecordTypeMapping recordTypeMap : layoutInfos.recordTypeMappings) {
            layoutToRecordTypeMap.put(recordTypeMap.layoutId, recordTypeMap);
        }

        layoutInfos.recordTypeMappings = null; // minify layout (to save on heap space): REVIEW - Do we need this?

        for (SFDCPartnerSoap.DescribeLayout layoutDesc : layoutInfos.layouts) {

            Layout layout = new Layout();
            layouts.add(layout);

            // minify layout (to save on heap space): REVIEW - Do we need this?
            layoutDesc.editLayoutSections = null;
            layoutDesc.buttonLayoutSection = null;
            layoutDesc.relatedLists = null;

            SFDCPartnerSoap.RecordTypeMapping recordTypeInfo = layoutToRecordTypeMap.get(layoutDesc.id);

            layout.id = layoutDesc.id;
            layout.recordTypeId = recordTypeInfo.recordTypeId;
            layout.recordTypeName = recordTypeInfo.name;
            layout.defaultRecordTypeMapping = recordTypeInfo.defaultRecordTypeMapping;
            
            for (SFDCPartnerSoap.DescribeLayoutSection sectionDesc : layoutDesc.detailLayoutSections) { 
                if (sectionDesc != null && sectionDesc.layoutRows != null) {
                    LayoutSection section = new LayoutSection(sectionDesc.heading, sectionDesc.columns);
                    layout.detailSections.add(section);
                    
                    for (SFDCPartnerSoap.DescribeLayoutRow row : sectionDesc.layoutRows) {
                        if (row != null && row.layoutItems != null) {
                            for (SFDCPartnerSoap.DescribeLayoutItem itemDesc : row.layoutItems) {
                                if (itemDesc != null && itemDesc.layoutComponents != null) {
                                    LayoutItem item = new LayoutItem(itemDesc.label);
                                    section.items.add(item);
                                    
                                    for (SFDCPartnerSoap.DescribeLayoutComponent comp : itemDesc.layoutComponents) {
                                        if (comp != null) item.addComponent(this.getDescribe().getSObjectType(), layout, comp);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        return layouts;
    }

}

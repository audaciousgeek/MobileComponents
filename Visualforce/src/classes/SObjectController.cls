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
 * Generic CRUD operations for standard and custom entities.
 */
public with sharing abstract class SObjectController extends BaseConfigController {

    public static final String LAST_MOD_DATE = 'LastModifiedDate';
    public static final Set<String> EXTRA_QUERY_FIELDS = new Set<String> { LAST_MOD_DATE };
    
    public virtual class SObjectConfig extends BaseConfig {
        public String sid { get; set; }
        public String stype { get; set; }
        public String whereStmt { get; set; }
        public String sortByField { get; set; }
        public Integer queryLimit { get; set; }
        public List<String> fields { get; set; } // metadata lookup
        
        protected void addField(String field) {
            System.debug('adding field:' + field);
            if (fields == null) fields = new List<String>();
            if (field.indexOf('.') > -1) {
                fields.add(field);
                System.debug('adding field, as-is:' + field);
            } else {
                if (stype != null) {
                    fields.add(stype + '.' + field);
                    System.debug('adding field, stype:' + stype + '.' + field);
                } else if (sid != null) {
                    Schema.SObjectType type = SchemaManager.getObjectForId(sid);
                    if (type != null) {
                        fields.add(type.getDescribe().getName() + '.' + field);
                        System.debug('adding field, sid:' + type.getDescribe().getName() + '.' + field);
                    }
                }
            }
        }
    }

    public class FieldMetadata {
        public String name { get; set; }
        public String label { get; set; }
        public String type { get; set; }
        public Object defaultValue { get; set; }
        public Boolean nillable { get; set; }
        public Boolean editable { get; set; }
        public Boolean hidden { get; set; }
        public String format { get; set; }

        FieldMetadata(Schema.DescribeFieldResult descField) {
            this(descField.getName(), descField.getLabel(), descField.getType().name(), descField.getDefaultValue(),
               descField.isNillable(), descField.isUpdateable(), false /* TODO */, null /* TODO */);
        }
        FieldMetadata(String name, String label, String type, Object defaultValue, Boolean nillable, Boolean editable,
                Boolean hidden, String format) {
            this.name = name;
            this.label = label;
            this.type = type;
            this.defaultValue = defaultValue;
            this.nillable = nillable;
            this.editable = editable;
            this.hidden = hidden;
            this.format = format;
        }
    }

    // properties
    private Schema.DescribeSObjectResult SOBJECT_DESCRIBE { get; set; }
    public String getName() {
        return (getDescribe() != null) ? SOBJECT_DESCRIBE.name : '';
    }

    public boolean isFeedEnabled() {
        return (getDescribe() != null) ? SOBJECT_DESCRIBE.isFeedEnabled() : false;
    }

    // constructor
    public SObjectController(SObjectConfig config) {
        super(config);
    }

    // methods
    public Schema.DescribeSObjectResult getDescribe() {
        if (SOBJECT_DESCRIBE == null) {
            initializeSObject();
        }

        return SOBJECT_DESCRIBE;
    }

    private void initializeSObject() {
        if (config == null || !(config instanceof SObjectConfig) || ((SObjectConfig)config).stype == null)
           throw new AppUtil.AppException('Expected sobject type value');

        SObjectConfig sConfig = (SObjectConfig)config;
        if (SOBJECT_DESCRIBE == null || !SOBJECT_DESCRIBE.name.equalsIgnoreCase(sConfig.stype))
            this.SOBJECT_DESCRIBE = SchemaManager.getDescribe(sConfig.stype);
    }

    @RemoteAction
    public static Map<String,FieldMetadata> getFieldMetadata(List<String> fullyQualifiedFields) {
        Map<String,FieldMetadata> fieldMetadata = new Map<String,FieldMetadata>();
        for (String fullyQualifiedField : fullyQualifiedFields) {
            String[] parts = fullyQualifiedField.split('\\.');
            if (parts.size() != 2) {
                System.debug('Expected fully qualified name (SObject.FieldName): ' + fullyQualifiedField);
                continue;
            }
            Schema.DescribeFieldResult field = SchemaManager.getFieldDescribe(parts[0], parts[1]);
            if (field != null && SchemaManager.isFieldAccessible(field, fullyQualifiedField))
               fieldMetadata.put(fullyQualifiedField, new FieldMetadata(field));
        }
        return fieldMetadata;
    }
    
    protected boolean isFieldAccessible(String fieldPath) {
        if (fieldPath != null &&
           SchemaManager.isFieldAccessible(this.getDescribe().getSobjectType(), fieldPath))
           return true;
        return false;
    }
    
    public List<SObject> querySObject(Set<String> fieldsToQuery, List<Id> ids) {
        
        Map<String, SObjectField> fieldMap = this.getDescribe().fields.getMap();
        
        String soql = 'SELECT ';
        
        List<String> fieldsList = new List<String>();
        for (String field : fieldsToQuery) {
            if(isFieldAccessible(field)) fieldsList.add(field);
        }
        soql += AppUtil.createCSVFromList(fieldsList);

        soql += (' FROM ' + this.getName());
        
        if (ids != null && !ids.isEmpty()) {
        	String idsFilter = AppUtil.createCSVFromList(ids, true);
        	soql += ' WHERE id IN(' + idsFilter + ')';
        }
        
        System.debug(soql);
        
        return Database.query(soql);
    }
}
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

public with sharing class SFDCApiClient {
    
    private static final String API_VERSION = '24.0';
    
    private static String getAPIUrl() {
    	String apiUrl;
    
    	System.URL sfdcUrl = System.URL.getSalesforceBaseUrl();
        String host = sfdcUrl.getHost();
        if (host.startsWith('c.')) host = (host.split('\\.')[1] + '.salesforce.com');
        apiUrl = sfdcUrl.getProtocol() + '://' + host;
        if (sfdcUrl.getPort() != null) apiUrl += (':' + sfdcUrl.getPort());
    
        return apiUrl;
    }
    
    public static SFDCPartnerSoap.DescribeLayoutResult describeLayout(String sObjectType, Id[] recordTypeIds) {
        SFDCPartnerSoap.Soap soapClient = new SFDCPartnerSoap.Soap();
        soapClient.setInstanceUrl(getAPIUrl());
        soapClient.setSessionId(UserInfo.getSessionId());
        
        return soapClient.describeLayout(sObjectType, recordTypeIds);
    }
}
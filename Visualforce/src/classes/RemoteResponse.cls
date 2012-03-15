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
 * Provides the basic structure for all Remote responses via Remote Action.
 */
public virtual class RemoteResponse {

    private Boolean success;
    private Datetime fetchDate;
    private List<Error> errors;
    
    public enum ErrorLevel { ERROR, WARNING }
    
    public class Error {

	    ErrorLevel level;
	    String code;
	    String message;
	
	    public Error(String code, String message) {
	        this.level = ErrorLevel.ERROR;
	        this.code = code;
	        this.message = message;
	    }
	
	    public Error(ErrorLevel level, String code, String message) {
	        this.level = level;
	        this.code = code;
	        this.message = message;
	    }
	}

    public RemoteResponse(Boolean success, List<Error> errors, Datetime fetchDate) {
        this.success = success;
        this.errors = errors;
        this.fetchDate = fetchDate;
    }

    public Boolean isSuccess() {
        return success;
    }

    public Datetime getFetchDate() {
        return fetchDate;
    }

    public List<Error> getErrors() {
        return errors;
    }
}
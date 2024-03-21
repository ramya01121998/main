public class PartSyncService {
    
    @AuraEnabled
    public static void syncParts() {
        // Getting User profile
        string profileID = userinfo.getProfileId();
        list<profile> profileName = [select name from profile where id =: profileID];
        
        // Checking if profile is System Administrator
        if (profileName[0].name != 'System Administrator') {
            throw new AuraHandledException('You do not have access.');
        }
        
        //Creating request for calling API
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(system.label.Cq_End_point);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('x-api-key', system.label.Cq_Api_key_token);
        
        // Call API and get response
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        
        if (response.getStatusCode() == 200) {
            List<SQX_Part__c> partsToInsert = new List<SQX_Part__c>();
            
            // Get Accounts value for High Volume and Low Volume
            List<Account> highVolumeAccounts = [SELECT Id FROM Account WHERE Name = 'High Volume' LIMIT 1];
            List<Account> lowVolumeAccounts = [SELECT Id FROM Account WHERE Name = 'Low Volume' LIMIT 1];
            if(response.getBody() != ''){
                // Parsing JSON String response using Wrapper class
                List<JSON2Apex> wrapperList = JSON2Apex.parse(response.getBody());
               
                // Looping through the wrapperList and creating values to insert in custom object
                for (JSON2Apex part : wrapperList) {
                    SQX_Part__c newPart = new SQX_Part__c();
                    newPart.Part_Name__c = part.PartName;
                    newPart.Part_Number__c = part.x_id;
                    newPart.Active__c = true;
                    Integer totalQuantityShipped = Integer.valueOf(part.TotalQuantityShipped);
                    newPart.Related_Account__c = totalQuantityShipped < 99 ? highVolumeAccounts[0].Id : lowVolumeAccounts[0].Id;
                    partsToInsert.add(newPart);
                } 
                try {
                    if (!partsToInsert.isEmpty()) {
                        insert partsToInsert;
                    }
                }
                catch (Exception e) {
                    throw new AuraHandledException('Something went wrong: Already Synced the Parts');    
                }
            }
        }
    }
}
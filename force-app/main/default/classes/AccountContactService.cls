public with sharing class AccountContactService {
   
    public static void UpdateActiveContacts(set<Id> accountids){
     
    List<AggregateResult> results = [ SELECT AccountId, Count(Id) totcount FROM contact 
                          WHERE Active__c = true AND AccountId IN :accountids GROUP BY AccountId];

Map<Id,Account> accountsToUpdate = new Map<Id,Account>();
for(AggregateResult aggres : results){
String accountid = String.valueOf(aggres.get('AccountId'));
Integer countnumber = Integer.valueOf(aggres.get('totcount'));
Account Acc = new Account(Id= accountid, Active_Contacts__c= countnumber);                 
accountsToUpdate.put(accountid, Acc);                    
}
for (Id accid: accountids){
   if(!accountsToUpdate.containsKey(accid)){ 
    accountsToUpdate.put(accid, new Account(Id= accid, Active_Contacts__c= 0));
   }

}

update accountsToUpdate.values();

    }
}
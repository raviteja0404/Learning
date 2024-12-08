public with sharing class CTPeopleTracingController {
    
    public static List<People_Tracing__c> getTraces(String personId){

        List<People_Tracing__c> tracesList = [SELECT Id, Name, Contact_Date__c, Contact_Type__c, Person_1__c, Person_1__r.Health_Status__c, Person_1__r.Token__c , Person_2__c, Person_2__r.Health_Status__c, Person_2__r.Token__c  FROM People_Tracing__c where Person_1__c =: personId OR Person_2__c =: personId order by Contact_Date__c DESC];

        return tracesList;

    }

    public static List<People_Tracing__c> checkDuplicates(List<People_Tracing__c> newPeopleTraces){

        // store unique person ids from the new location trace list
        Set<Id> personIds = new Set<Id>();

        for(People_Tracing__c trace : newPeopleTraces) {
           
            personIds.add(trace.Person_1__c);
            personIds.add(trace.Person_2__c);
        }

        // query existing people tracing records 

        List<People_Tracing__c> existingPeopleTracingRecords = [select Name, Contact_Date__c, Contact_Type__c, Person_1__c, Person_1__r.Health_Status__c, Person_1__r.Token__c , Person_2__c, Person_2__r.Health_Status__c, Person_2__r.Token__c from People_Tracing__c where Person_1__c IN :personIds OR Person_2__c IN :personIds];


        map<Id, set<Id>> mapofExistingRecords = new map<Id, set<Id>>();

        List<People_Tracing__c> duplicateRecords = new List<People_Tracing__c>();
   
        if(existingPeopleTracingRecords != null && existingPeopleTracingRecords.size() >0) {
            
            for(People_Tracing__c trace : existingPeopleTracingRecords) {

                if(! mapofExistingRecords.containsKey(trace.Person_1__c)) {

                    mapofExistingRecords.put(trace.Person_1__c, new set<Id>());
                }

                mapofExistingRecords.get(trace.Person_1__c).add(trace.Person_2__c);


                if(! mapofExistingRecords.containsKey(trace.Person_2__c)) {

                    mapofExistingRecords.put(trace.Person_2__c, new set<Id>());
                }

                mapofExistingRecords.get(trace.Person_2__c).add(trace.Person_1__c);

            }

            for(People_Tracing__c trace : newPeopleTraces){

                if(
                (mapofExistingRecords.containsKey(trace.Person_1__c) && mapofExistingRecords.get(trace.Person_1__c).contains(trace.Person_2__c)) ||  
                (mapofExistingRecords.containsKey(trace.Person_2__c) && mapofExistingRecords.get(trace.Person_2__c).contains(trace.Person_1__c))
                
                ) {

                    duplicateRecords.add(trace);
                }
              

            }

        }
        return duplicateRecords;

    }
}
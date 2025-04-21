public with sharing class TriggerEventHelper {
    private class TriggerEventHelperException extends exception {}
    @testVisible private String errorMessage;

    List<OpportunityEvent__e> oppEvents;

    public TriggerEventHelper() {
        oppEvents = new List<OpportunityEvent__e>();
    }
    
    // Method containing switch statements to add the events for each object to the corresponding list
    public void addEvent(Id objectId, String objectName, String actionString){
        switch on objectName {
            when 'Opportunity' {
                oppEvents.add(new OpportunityEvent__e(oppId__c= objectId, actionString__c = actionString));
            }
        }   
    }

    // Method to publish the events from populated event lists
    public void publishEvents(){
        try{
            // publish opportunity triggered events
            if(!oppEvents.isEmpty()){
                List<Database.SaveResult> srList = EventBus.publish(oppEvents);
                for(Database.SaveResult sr : srList) {
                    if(!sr.isSuccess()) {
                        for(Database.Error err : sr.getErrors()) {
                            errorMessage += err.getStatusCode() + ': ' + err.getMessage() + ', ';
                        }
                    }
                }
            }

            if (!String.isEmpty(errorMessage)){
                throw new TriggerEventHelperException(errorMessage);
            }
        } catch (Exception ex){
            SystemExceptionLogger.fireSystemExceptionLogEvent (ex, 'TriggerEventHelper', 'publishEvents', 
                SystemExceptionLogger.EXCEPTION_LEVEL_CRITICAL, ex.getMessage(), null, null, false);
        }
    }
}

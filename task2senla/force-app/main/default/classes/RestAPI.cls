@RestResource(urlMapping='/Leads')
global class LeadRestApi {
    public static final String CANNOT_CREATE_TASK ="Cannot create Task!";
    public static final String CANNOT_FIND_LEAD ="Cannot find the Lead!";
    @HttpPost
    global static Lead getLeadByIdOrEmail(){
    
        Lead getLead = LeadRESTHelper();

        try {
            if(getLead!=null){
                return getLead;
            }

        }catch(NullPointerException e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return getLead;
    }

    @HttpPut
    global static void createTaskForLead(){
                       
        Lead targetLead = LeadRESTHelper();
        
        List<String> validSubjects = new List<String>();
        validSubjects.add('Call');
        validSubjects.add('Email');
        validSubjects.add('Other');
        validSubjects.add('Send Letter');
        validSubjects.add('Send Quote');
        
        Map<String, Object> subjectParameter = getRequestBody();

        String subj = subjectParameter.get('subject').tostring();
		
        try {
            if (targetLead!=null) {
                Task newTask;
                if (validSubjects.contains(subj)) {
                    newTask = new Task(Subject = subj,
                                    Status = 'Not Started',
                                    WhoID = targetLead.Id, 
                                    OwnerId = targetLead.OwnerId);
                }
                else {
                    newTask = new Task(Status = 'Not Started',
                                    WhoID = targetLead.Id, 
                                    OwnerId = targetLead.OwnerId);
                }
                insert newTask;
            }
            else {
                System.debug(LoggingLevel.ERROR,CANNOT_CREATE_TASK);
            }
        } catch (DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }

    public static Lead LeadRESTHelper() {

        Lead returnLead;
        try{  
            Map<String, Object> parMap = getRequestBody();
            String leadId = '%' + parMap.get('id').toString() + '%';
            String leadEmail = '%' + parMap.get('email').toString() + '%';

            if(leadId != null && leadId.length() == 20){
                returnLead = [SELECT Id, Name, OwnerId,	Address, MobilePhone, Status
                        FROM Lead
                        WHERE Id = :leadId
                        LIMIT 1];
                return returnLead;
            }
            else if(leadEmail != null && leadEmail.contains('@')){
                returnLead = [SELECT Id, Name, OwnerId,	Address, MobilePhone, Status
                        FROM Lead
                        WHERE Email = :leadEmail
                        LIMIT 1];
                return returnLead;
            }
            else {
                System.debug(LoggingLevel.ERROR,CANNOT_FIND_LEAD);       
                return null;
            }
        }catch(NullPointerException e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return returnLead;
    }
    public static  Map<String, Object> getRequestBody(){
        RestRequest req = RestContext.request;

        Map<String, Object> subjectParameter = 
        (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
        return subjectParameter;

    }
}
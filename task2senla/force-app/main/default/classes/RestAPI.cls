@RestResource(urlMapping='/Leads')
//tut
global class LeadRestApi {
    public static final String CANNOT_CREATE_TASK ='Cannot create Task!';
    public static final String CANNOT_FIND_LEAD ='Cannot find the Lead!';
    @HttpPost
    global static Lead getLeadByIdOrEmail(){
    
        Lead getLead = LeadReqest();

        try {
            if(getLead!=null){
                return getLead;
            }

        }catch(NullPointerException e){
            System.debug(LoggingLevel.ERROR,'The following exception has occurred: ' + e.getMessage());
        }
        return getLead;
    }

    @HttpPut
    global static ID createTaskForLead(){
                       
        Lead targetLead = LeadReqest();
        
        List<String> validSubjects = new List<String>{'Call','Email','Other','Send','Letter','Send','Quote'};
     
        Map<String, Object> subjectParameter = getRequestBody();
        
        String subj = subjectParameter.get('subject').tostring();
		
        try {
            if (targetLead!=null) {
                Task newTask;
                if (validSubjects.contains(subj)) {
                    newTask = new Task(Subject = subj,
                                    Status = 'Not Started',
                                    WhoID = targetLead.Id, 
                                    OwnerId = targetLead.OwnerId,
                                    Description = targetLead.Description);
                }
                insert newTask;
            }
            else {
                System.debug(LoggingLevel.ERROR,CANNOT_CREATE_TASK);
            }
        } catch (DmlException e) {
            System.debug(LoggingLevel.ERROR,'The following exception has occurred: ' + e.getMessage());
        }
        return targetLead.id;

    }

    public static Lead LeadReqest() {

        Lead returnLead;
        try{  
            Map<String, Object> parMap = getRequestBody();
            String leadId = parMap.get('id')!= null?
                            '%' + parMap.get('id').toString() + '%':
                            null;
            String leadEmail =  parMap.get('id')!= null?
                                '%' + parMap.get('email').toString() + '%':
                                null;
			System.debug(leadId);
            System.debug(leadEmail);
            if(leadId != null && leadId.length() == 20){
               // String qryString = 'SELECT Id FROM Lead WHERE ' +
              //                     '(id = \'%' + leadId + '%\')';
				//returnLead = Database.query(qryString);
               // System.debug('query result is ' + returnLead);
               // 
                returnLead = [SELECT Id, Name, OwnerId,	Address, MobilePhone, Status, Description
                       FROM Lead
                       WHERE Id = :leadId
                       LIMIT 1];
            }
            else if(leadEmail != null && leadEmail.contains('@')){
                System.debug('inEmail');
                returnLead = [SELECT Id, Name, OwnerId,	Address, MobilePhone, Status, Description
                        FROM Lead
                        WHERE Email = :leadEmail
                        LIMIT 1];
                System.debug('outEmail');
             
            }
            else {
                System.debug(LoggingLevel.ERROR,CANNOT_FIND_LEAD);
				System.debug('null');       
                return null;
            }
        }catch(NullPointerException e){
            System.debug(LoggingLevel.ERROR,'The following exception has occurred: ' + e.getMessage());
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
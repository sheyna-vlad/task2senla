@RestResource(urlMapping='/Leads')
global class LeadRestApi {
    @HttpPost
    global static Id getLeadByIdOrEmail(){
    
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        Lead getLead = LeadRESTHelper(req, res);
        return getLead.Id;        
    }

    @HttpPut
    global static Id createTaskForLead(){

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;                         

        Lead targetLead = LeadRESTHelper(req,res);
        
        List<String> validSubjects = new List<String>();
        validSubjects.add('Call');
        Map<String, Object> subjectParameter = 
        (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());

        String subj = subjectParameter.get('task body').tostring();
		Task newTask;
        
        if (targetLead!=null) {
            if (validSubjects.contains(subj)) {
                newTask = new Task(Subject = 'Other' ,
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
            System.debug(LoggingLevel.FINEST,newTask);
            return newTask.Id;
        }
        else {
            System.debug(LoggingLevel.ERROR,'Cannot create Task!');
            return null;
        }
    }

    public  static Lead LeadRESTHelper(RestRequest req, RestResponse res) {
        Lead returnLead;
        try{
            String findLead = req.requestBody.tostring();
            
            Map<String, Object> parMap = (Map<String, Object>) JSON.deserializeUntyped(findLead);
            String leadId = parMap.get('id').toString();
            String leadEmail = parMap.get('email').toString();
            if(leadId != null && leadId.length() == 18){
                returnLead = [SELECT Id, Name, OwnerId
                        FROM Lead
                        WHERE Id = :leadId
                        LIMIT 1];
            }
            else if(leadEmail != null && leadEmail.contains('@')){
                returnLead = [SELECT Id, Name, OwnerId
                        FROM Lead
                        WHERE Email = :leadEmail
                        LIMIT 1];
            }
            else {
                System.debug(LoggingLevel.ERROR,'Cannot find the Lead!');
                //res.statusCode = 400;
                return null;
                //returnLead =  null;
            }
            
            System.debug(LoggingLevel.INFO,returnLead);
            //res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(returnLead));
            return returnLead;
        }catch(NullPointerException e){
            e.getStackTraceString();
            System.debug(LoggingLevel.INFO,'Null pointer exception!!!');
            return null;
        }
    }
}
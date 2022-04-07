global class InformContactOwners implements Database.Batchable<sObject>, Schedulable {


     Map<Id,List<Contact>> ownersAndContacts;
     Set<Id> owners;
     
     global database.querylocator start(Database.BatchableContext BC){
         return Database.getQueryLocator(
             'SELECT ID, LastName, OwnerId '+
             ' FROM Contact WHERE Possible_Outdated__c=True'
         );
     }
  
     global void execute(Database.BatchableContext BC, List<Contact> scope){
         
         ownersAndContacts = new Map<Id,List<Contact>>();
         owners = new Set<Id>();
         for(Integer i = 0;i<scope.size();i++){
             owners.add(scope.get(i).OwnerId);            
         }
         for(Id owner : owners){
             List<Contact> contacts = new List<Contact>();
             for(Contact con : scope){
                 if(con.OwnerId==owner){
                     contacts.add(con);
                 }
             }
             ownersAndContacts.put(owner, contacts);
         }        
     }
     
     global void execute(System.SchedulableContext ctx){
         Database.executebatch(this);

                 
     }
     
     global void finish(Database.BatchableContext BC)
     {
         List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
 
         for (Id owner : owners) {
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             List<String> sendTo = new List<String>{owner};
             mail.setToAddresses(sendTo);
             mail.setSenderDisplayName('Apex Batch Processing Module');
             mail.setSubject('The list of possible outdated Contacts that needs review!');
             String emailBody = 'Contacts that need review: ';
             for (Contact con : ownersAndContacts.get(owner)) { 
                     emailBody += '<html><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+con.id+'">'+con.LastName+'</a></html>';
             }
             mail.setHtmlBody(emailBody);
             mailsToSend.add(mail);
             System.debug('Email Sent');
         }
         
         Messaging.sendEmail(mailsToSend);
 
     }
     
 }
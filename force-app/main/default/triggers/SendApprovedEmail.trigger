trigger SendApprovedEmail on User (after update) {
   
    for(User u : Trigger.new){
        if(Trigger.isUpdate && u.IsActive == true){            
            SendApprovedEmailController.SendApprovedEmail(u.id);
        }
    
    }
    
}
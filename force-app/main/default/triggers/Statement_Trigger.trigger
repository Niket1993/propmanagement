trigger Statement_Trigger on Statement__c (after insert,after update) 
{
if(trigger.isAfter && trigger.isInsert || trigger.isUpdate)
{
RollUp_Methods.rollupStatementsToRentalAgreement(trigger.new);    
}
}
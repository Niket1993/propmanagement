public class RollUp_Methods 
{
public static void rollupStatementsToRentalAgreement(List<Statement__c> newList)
{
set<id> rentalAgreementSet = new set<id>();
for(Statement__c S:newList)
{
rentalAgreementSet.add(S.Rental_Agreement__c);    
} 
//This list will store the rental Agreement records which needs to be updates    
List<Rental_Agreement__c> rentalUpdates = new List<Rental_Agreement__c>();
//Aggregate query to sum total amount from statement
for(AggregateResult ar: [select sum(Total_Amount__c)totalInvoice,Rental_Agreement__c from Statement__c where Rental_Agreement__c IN:rentalAgreementSet group by Rental_Agreement__c ])    
{
Rental_Agreement__c r = new Rental_Agreement__c(id=string.valueOf(ar.get('Rental_Agreement__c')));
r.Total_Invoiced__c = double.valueOf(ar.get('totalInvoice'));
rentalUpdates.add(r);    
}
if(!rentalUpdates.isEmpty()) 
{
update rentalUpdates;    
}    
}
public static void rollupPaymentsToRentalAgreement(Map<id,Payment__c> newMap)
{
set<id> rentalAgreementSet = new set<id>();
for(Payment__c P: [select id,Statement__r.Rental_Agreement__c from Payment__c where id IN:newMap.keySet()])
{
rentalAgreementSet.add(P.Statement__r.Rental_Agreement__c);    
}    
List<Rental_Agreement__c> rentalUpdates = new List<Rental_Agreement__c>();
for(AggregateResult ar: [select sum(Amount__c)totalPaid, Statement__r.Rental_Agreement__c ra from Payment__c where Statement__r.Rental_Agreement__c IN:rentalAgreementSet group by Statement__r.Rental_Agreement__c])
{
Rental_Agreement__c r = new Rental_Agreement__c(id=string.valueOf(ar.get('ra'))); 
r.Total_Payments__c = double.valueOf(ar.get('totalPaid'));
rentalUpdates.add(r);   
}     
}    
}
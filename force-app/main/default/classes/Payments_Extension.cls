public class Payments_Extension
{
//payment__c record variable to hold payment information
public Payment__c thisPayment {get;set;}
public Statement__c thisStatement {get;set;}
public Map<Id,string> recordTypeMap {get;set;}
public boolean success{get;set;} 
public Payments_Extension(ApexPages.StandardController scon)
{
if(scon.getRecord() instanceOf Statement__c) thisStatement  =
 [select id,name,Rental_Agreement__r.renter__c,balance__c from Statement__c  where  id=:scon.getId()];    
success = false;
recordTypeMap = new Map<Id,string>();
//query for all the record types in payment object
//and we will store it in the Map
for(RecordType r: [select id,name from RecordType where sobjectType='Payment__c'])
{
recordTypeMap.put(r.id, r.name);    
}    
//instantiate the Payment
thisPayment = new Payment__c();
if(scon.getRecord() instanceOf Statement__c)
{
thisPayment.Statement__c = scon.getId();
thisPayment.Amount__c = thisStatement.balance__c;
}
//if guest user,preset type of Credit Card 
if(getIsGuest())
{
for(id i:recordTypeMap.keySet())
{
if(recordTypeMap.get(i)=='Credit Card')
{
thisPayment.RecordTypeId=i;    
}    
}    
}
else if(scon.getRecord() instanceOf Statement__c)
{
contact renter  =
 [select id,firstName,lastName,mailingStreet,mailingCity,mailingState,mailingPostalCode from contact where id=:thisStatement.Rental_Agreement__r.renter__c];
thisPayment.Billing_Name__c = renter.firstName +' '+ renter.lastName ;
thisPayment.Billing_Street__c = renter.mailingStreet ;
thisPayment.Billing_City__c = renter.mailingCity ;
thisPayment.Billing_State__c = renter.mailingState ;
thisPayment.Billing_Postal_Code__c = renter.mailingPostalCode ;    
}    
} 
// this method will process and save our Payment
// or report any errors in the attempt
public PageReference savePayment()
{
success = false;
string PaymentType = recordTypeMap.get(thisPayment.RecordTypeId);
//validation
if(validateFields(PaymentType))
{
// process Credit Card Payments
if(PaymentType=='Credit Card')
{
// create a request wrapper for authorize.net
authNetReq_Wrapper req = new authNetReq_Wrapper();
    
// Set the Wrapper values
req.amt = string.valueOf(thisPayment.amount__c);
req.firstname =
(thisPayment.Billing_Name__c.contains(''))?thisPayment.Billing_Name__c.subStringbefore(' '):thisPayment.Billing_Name__c;
req.lastname =
(thisPayment.Billing_Name__c.contains(''))?thisPayment.Billing_Name__c.subStringafter
(' '):thisPayment.Billing_Name__c;
req.billstreet = thisPayment.Billing_Street__c;
req.billcity = thisPayment.Billing_City__c;
req.billstate = thisPayment.Billing_State__c;
req.billzip = thisPayment.Billing_Postal_Code__c;

// Set Credit Card information on the Request wrapper
req.ccnum = thisPayment.Credit_Card_Number__c;
req.ccexp = monthmap.get(thisPayment.Credit_Card_Expiration_Month__c) + thisPayment.Credit_Card_Expiration_Year__c;
req.ccsec = thisPayment.Credit_Card_Security_Card__c;

// Give this req a name
req.ordername = 'Payment of '+ [select id,name from Statement__c where id=:thisPayment.Statement__c].name;
    
// Process our authorize.net Request

authNetResp_Wrapper res = API_authorizeDotNet.authdotnetcharge(req);
    
thisPayment.Authorize_Net_Transaction_Id__c = res.transactionId;
thisPayment.Authorize_Net_Authorization_Code__c = res.authorizationCode;
thisPayment.Authorize_Net_Response__c = res.responseCode + '|' + res.responseReasonText;
// If the trasaction failed
if(res.responseCode !='1' || res.responseReasonText != 'This Transaction has been Approved')
{
thisPayment.Status__c = 'Failed';
ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Payment Failed'));
ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'res.responseReasonText'));
return Null;    
}    
} 
// Successful transaction
thisPayment.Status__c = 'Paid';
thisPayment.Payment_Date__c = system.now();
upsert thisPayment;
success = true;
ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM, 'Payment Successful'));
try
{
//if there is an email provided by the renter
if(thisPayment != null && thisStatement.Rental_Agreement__r.renter__r.email!=null)
{
// construct my message
Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
msg.setToAddresses(new List<String> {thisStatement.Rental_Agreement__r.renter__r.email});
msg.setSubject('Payment Confirmation');
msg.setHtmlBody('Your Payment of '+ thisPayment.Amount__c + 'has been Succesfully processed. <br/><br/> Thank You!! ');
msg.setPlainTextBody('Your Payment of '+ thisPayment.Amount__c + 'has been Succesfully processed. \n \n Thank You!! ');
//send the email
Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {msg});
}    
} 
catch(Exception e)
{
}    
} 
else
{
ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Please fill out all the details'));
}
return null;    
}    
public boolean validateFields(string PaymentType)
{
boolean valid = true;
//check common fields
if(thisPayment.Statement__c == null) valid=false;
if(thisPayment.Amount__c == null) valid=false;
if(string.isBlank(thisPayment.Billing_Name__c)) valid=false;  
if(string.isBlank(thisPayment.Billing_Street__c)) valid=false;    
if(string.isBlank(thisPayment.Billing_City__c)) valid=false;    
if(string.isBlank(thisPayment.Billing_State__c)) valid=false;    
if(string.isBlank(thisPayment.Billing_Postal_Code__c)) valid=false; 
// check specific fields related to the payment type
// check fields when the payment type is cheque
if(PaymentType=='Cheque')
{
if(string.isBlank(thisPayment.Cheque_Account_Number__c)) valid=false; 
if(string.isBlank(thisPayment.Cheque_Routing_Number__c)) valid=false; 
}    
else if(PaymentType=='Credit Card')
{
if(string.isBlank(thisPayment.Credit_Card_Number__c)) valid=false; 
if(string.isBlank(thisPayment.Credit_Card_Expiration_Month__c)) valid=false; 
if(string.isBlank(thisPayment.Credit_Card_Expiration_Year__c)) valid=false; 
if(string.isBlank(thisPayment.Credit_Card_Security_Card__c)) valid=false; 
}
return valid;    
}
//getter method for guest user determination
public boolean getIsGuest()
{
return [select id,userType from profile where id=:userInfo.getProfileId()].userType=='Guest';    
}    
public static Map<String,String> monthmap = new Map<String,String>{
    'January' => '01',
    'February'=>'02',
    'March'=>'03',
    'April'=>'04',
    'May'=>'05',
    'June'=>'06',
    'July'=>'07',
    'August'=>'08',
    'September'=>'09',
    'October'=>'10',
    'November'=>'11',
    'December'=>'12'
};
public list<SelectOption> getPaymentRecordTypes()
{
list<SelectOption> temp = new list<SelectOption>();
temp.add(new SelectOption(' ','Select Payment Method'));
for(id i:recordTypeMap.keySet())
{
temp.add(new SelectOption(i, recordTypeMap.get(i)));    
} 
return temp;    
}    
public list<SelectOption> getExpirationYears()
{
list<SelectOption> temp = new list<SelectOption>();
for(integer i=0;i<5;i++)
{
string y = ' '+system.today().addYears(i).year();
temp.add(new SelectOption(y,y));    
}
return temp;    
}
}
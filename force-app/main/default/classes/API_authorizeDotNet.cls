public class API_authorizeDotNet 
{
// variables to hold our login credentials
public static string APILOGIN;
public static string APITRANSKEY;
public static void getAuthNetCreds()
{
Authorize_Net_Setting__c apiloginSetting  = 
Authorize_Net_Setting__c.getInstance('API Login');
Authorize_Net_Setting__c apitranskeySetting = Authorize_Net_Setting__c.getInstance('TransKey');
    
system.debug('apiloginSetting '+ apiloginSetting);    
system.debug('apitranskeySetting '+ apitranskeySetting);    

APILOGIN = apiloginSetting.Value__c;
APITRANSKEY = apitranskeySetting.Value__c;
system.debug('APILOGIN '+APILOGIN);    
system.debug('APITRANSKEY '+APITRANSKEY);    
}
public static authNetResp_Wrapper authdotnetcharge(authNetReq_Wrapper input)
{
 getAuthNetCreds();  
// construct our request
HttpRequest req = new HttpRequest();
req.setEndpoint('https://test.authorize.net/gateway/transact.dll'); //test
req.setMethod('POST');
// build message
Map<string,string> messagestring = new Map<string,string>();
messagestring.put('x_login',APILOGIN);
messagestring.put('x_tran_key',APITRANSKEY);
messagestring.put('x_version','4.8');
messagestring.put('x_delim_data','True');
messagestring.put('x_delim_char',';');
messagestring.put('x_relay_response','False');
//the type of the transaction
messagestring.put('x_type','AUTH_CAPTURE');
messagestring.put('x_method','CC');    
//transaction specific information 
messagestring.put('x_card_num', input.ccnum);
messagestring.put('x_exp_date', input.ccexp);
messagestring.put('x_card_code', input.ccsec);
// transaction amount
messagestring.put('x_amount', input.amt);
//description of transaction 
messagestring.put('x_description','Your Transaction '+ input.ordername);
//billing information
messagestring.put('x_first_name', input.firstname);
messagestring.put('x_last_name', input.lastname);
messagestring.put('x_address', input.billstreet);
messagestring.put('x_city', input.billcity);
messagestring.put('x_state', input.billstate);
messagestring.put('x_zip', input.billzip);  
//encode the message components
string encodedMsg='';
for(string s : messagestring.keySet())
{
string v = messagestring.get(s);
// fix null values
if(string.isBlank(v))  v = '';
encodedMsg = s+'='+ EnCodingUtil.urlEncode(v,'UTF-8') + '&';   

}    
//add message termination
encodedMsg = 'endofdata';
system.debug('Encoded Message '+ encodedMsg);
req.setBody(encodedMsg);
//send and collect the response
Http http = new Http();
string resp = http.send(req).getBody();
//response from payment gateway
system.debug('Response from Authorize.Net '+resp);
//split response by our delimiter
list<string> responses = resp.split(';');
authNetResp_Wrapper parsedResponse = parseIntoResponseWrapper(responses);
return parsedResponse;    
}
public static authNetResp_Wrapper parseIntoResponseWrapper(list<string> input)
{
authNetResp_Wrapper temp = new authNetResp_Wrapper();
temp.responseCode = input[0];
temp.responseSubCode = input[1]; 
temp.responseReasonCode = input[2];
temp.responseReasonText = input[3]; 
temp.authorizationCode = input[4]; 
temp.AVSResponse = input[5];
temp.transactionId = input[6]; 
temp.invoiceNumber = input[7]; 
temp.description = input[8];
temp.amount = input[9]; 
temp.method = input[10]; 
temp.transactionType = input[11];
temp.customerId = input[12]; 
temp.firstName = input[13]; 
temp.lastName = input[14];
temp.company = input[15];
temp.address = input[16]; 
temp.city = input[17]; 
temp.state = input[18]; 
temp.zipCode = input[19];
temp.country = input[20];
temp.phone = input[21]; 
temp.fax = input[22]; 
temp.emailAddress = input[23];
temp.shipToFirstName = input[24]; 
temp.shipToLastName = input[25];
temp.shipToCompany = input[26];     
temp.shipToAddress = input[27];
temp.shipToCity = input[28]; 
temp.shipToState = input[29]; 
temp.shipToZIPCode = input[30]; 
temp.shipToCountry = input[31]; 
temp.tax = input[32]; 
temp.duty = input[33]; 
temp.freight = input[34];
temp.taxExempt = input[35];
temp.purchaseOrderNumber = input[36]; 
temp.MD5Hash = input[37]; 
temp.cardCodeResponse = input[38];
temp.cardholderAuthenticationVerificationResponse = input[39]; 
temp.accountNumber = input[40]; 
temp.cardType = input[41];
temp.splitTenderId = input[42]; 
temp.requestedAmount = input[43]; 
temp.balanceOnCard = input[44];
return temp;    
}
}
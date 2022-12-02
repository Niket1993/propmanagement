public class authNetResp_Wrapper
{
public string responseCode {get;set;} 
public string responseSubCode {get;set;} 
public string responseReasonCode {get;set;} 
public string responseReasonText {get;set;} 
public string authorizationCode {get;set;} 
public string AVSResponse {get;set;} 
public string transactionId {get;set;} 
public string invoiceNumber {get;set;} 
public string description {get;set;} 
public string amount {get;set;} 
public string method {get;set;} 
public string transactionType {get;set;} 
public string customerId {get;set;} 
public string firstName {get;set;} 
public string lastName {get;set;} 
public string company {get;set;} 
public string address {get;set;} 
public string city {get;set;} 
public string state {get;set;} 
public string zipCode {get;set;}
public string country {get;set;} 
public string phone {get;set;} 
public string fax {get;set;} 
public string emailAddress {get;set;} 
public string shipToFirstName {get;set;} 
public string shipToLastName {get;set;}
public string shipToCompany {get;set;}     
public string shipToAddress {get;set;} 
public string shipToCity {get;set;} 
public string shipToState {get;set;} 
public string shipToZIPCode {get;set;} 
public string shipToCountry {get;set;} 
public string tax {get;set;} 
public string duty {get;set;} 
public string freight {get;set;} 
public string taxExempt {get;set;} 
public string purchaseOrderNumber {get;set;} 
public string MD5Hash {get;set;} 
public string cardCodeResponse {get;set;} 
public string cardholderAuthenticationVerificationResponse {get;set;} 
public string accountNumber {get;set;} 
public string cardType {get;set;} 
public string splitTenderId {get;set;} 
public string requestedAmount {get;set;} 
public string balanceOnCard {get;set;}
public authNetResp_Wrapper()
{
 }    
}
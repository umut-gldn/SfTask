public with sharing class AccountPaymentController {
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccounts() {
        try {
            return [
                SELECT Id, Name 
                FROM Account 
                ORDER BY Name ASC
                LIMIT 200
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving accounts: '+e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<Payment__c> getPaymentsByAccount(Id accountId) {
        if (accountId == null) {
            throw new AuraHandledException('Account ID cannot be null');
        }
        
        try {
            return [
                SELECT Id, Name, Payment_Type__c, Amount__c, Due_Date__c, Notes__c, Account__c
                FROM Payment__c
                WHERE Account__c = :accountId
                ORDER BY Due_Date__c ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving payments: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Payment__c createPayment(Payment__c payment) {
        if (payment == null) {
            throw new AuraHandledException('Payment record cannot be null');
        }
     
        if (payment.Account__c == null) {
            throw new AuraHandledException('Account is required');
        }
        if (String.isBlank(payment.Payment_Type__c)) {
            throw new AuraHandledException('Payment Type is required');
        }
        if (payment.Amount__c == null) {
            throw new AuraHandledException('Amount is required');
        }
        if (payment.Due_Date__c == null) {
            throw new AuraHandledException('Due Date is required');
        }
        
        try {
            insert payment;
 
            return [
                SELECT Id, Name, Payment_Type__c, Amount__c, Due_Date__c, Notes__c, Account__c
                FROM Payment__c
                WHERE Id = :payment.Id
                LIMIT 1
            ];
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating payment: ' + e.getDmlMessage(0));
        } catch (Exception e) {
            throw new AuraHandledException('Error creating payment: ' + e.getMessage());
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getPaymentTypePicklistValues() {
        try {
            List<String> picklistValues = new List<String>();
            Schema.DescribeFieldResult fieldResult = Payment__c.Payment_Type__c.getDescribe();
            List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
            
            for (Schema.PicklistEntry entry : entries) {
                if (entry.isActive()) {
                    picklistValues.add(entry.getValue());
                }
            }
            
            return picklistValues;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving picklist values: ' + e.getMessage());
        }
    }
}
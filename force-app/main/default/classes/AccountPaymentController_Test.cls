
@isTest
private class AccountPaymentController_Test {
    
    @testSetup
    static void setupTestData() {
       
        List<Account> accounts = new List<Account>();
        for (Integer i = 1; i <= 5; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;
        
        List<Payment__c> payments = new List<Payment__c>();
        for (Account acc : accounts) {
            for (Integer j = 1; j <= 3; j++) {
                payments.add(new Payment__c(
                    Account__c = acc.Id,
                    Payment_Type__c = 'Service',
                    Amount__c = 1000 + (j * 100),
                    Due_Date__c = Date.today().addDays(j * 10),
                    Notes__c = 'Test payment ' + j + ' for ' + acc.Name
                ));
            }
        }
        insert payments;
    }
    
   
    @isTest
    static void testGetAccounts() {
        Test.startTest();
        List<Account> accounts = AccountPaymentController.getAccounts();
        Test.stopTest();
      
        System.assertNotEquals(null, accounts, 'Accounts list should not be null');
        System.assertEquals(5, accounts.size(), 'Should return 5 accounts');
        System.assertEquals('Test Account 1', accounts[0].Name, 'First account name should match');
    }
    
 
    @isTest
    static void testGetPaymentsByAccount_Success() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        
        Test.startTest();
        List<Payment__c> payments = AccountPaymentController.getPaymentsByAccount(testAccount.Id);
        Test.stopTest();
     
        System.assertNotEquals(null, payments, 'Payments list should not be null');
        System.assertEquals(3, payments.size(), 'Should return 3 payments for the account');
        System.assertEquals(testAccount.Id, payments[0].Account__c, 'Payment should belong to test account');
        System.assertNotEquals(null, payments[0].Payment_Type__c, 'Payment Type should not be null');
        System.assertNotEquals(null, payments[0].Amount__c, 'Amount should not be null');
    }
    
    @isTest
static void testGetPaymentsByAccount_NullAccountId() {
    Boolean exceptionThrown = false;
    Boolean isCorrectExceptionType = false; 
    
    Test.startTest();
    try {
        List<Payment__c> payments = AccountPaymentController.getPaymentsByAccount(null);
    } catch (Exception e) {
        exceptionThrown = true;
        
        if (e instanceof AuraHandledException) {
            isCorrectExceptionType = true;
        }
        
        
        System.debug('Yakalanan hata mesajı: ' + e.getMessage());
    }
    Test.stopTest();
    
 
    System.assertEquals(true, exceptionThrown, 'Exception should be thrown for null account ID');
   
    System.assertEquals(true, isCorrectExceptionType, 'Exception type should be AuraHandledException');
}
    
   
    @isTest
    static void testGetPaymentsByAccount_NoPayments() {
        Account newAccount = new Account(Name = 'Account Without Payments');
        insert newAccount;
        
        Test.startTest();
        List<Payment__c> payments = AccountPaymentController.getPaymentsByAccount(newAccount.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, payments, 'Payments list should not be null');
        System.assertEquals(0, payments.size(), 'Should return 0 payments for account without payments');
    }
    
   
    @isTest
    static void testCreatePayment_Success() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        
        Payment__c newPayment = new Payment__c(
            Account__c = testAccount.Id,
            Payment_Type__c = 'Product',
            Amount__c = 5000,
            Due_Date__c = Date.today().addDays(30),
            Notes__c = 'New test payment'
        );
        
        Test.startTest();
        Payment__c createdPayment = AccountPaymentController.createPayment(newPayment);
        Test.stopTest();
     
        System.assertNotEquals(null, createdPayment, 'Created payment should not be null');
        System.assertNotEquals(null, createdPayment.Id, 'Created payment should have an ID');
        System.assertEquals(testAccount.Id, createdPayment.Account__c, 'Payment should belong to test account');
        System.assertEquals('Product', createdPayment.Payment_Type__c, 'Payment Type should match');
        System.assertEquals(5000, createdPayment.Amount__c, 'Amount should match');
        System.assertEquals(Date.today().addDays(30), createdPayment.Due_Date__c, 'Due Date should match');
        System.assertEquals('New test payment', createdPayment.Notes__c, 'Notes should match');
        

        List<Payment__c> allPayments = [SELECT Id FROM Payment__c WHERE Account__c = :testAccount.Id];
        System.assertEquals(4, allPayments.size(), 'Should have 4 payments total (3 from setup + 1 new)');
    }
    
  
    @isTest
static void testCreatePayment_NullPayment() {
    Boolean exceptionThrown = false;
    Boolean isCorrectExceptionType = false;
    
    Test.startTest();
    try {
        Payment__c createdPayment = AccountPaymentController.createPayment(null);
    } catch (Exception e) {
        exceptionThrown = true;
        if (e instanceof AuraHandledException) {
            isCorrectExceptionType = true;
        }
        System.debug('Yakalanan hata mesajı: ' + e.getMessage());
    }
    Test.stopTest();
    

    System.assertEquals(true, exceptionThrown, 'Exception should be thrown for null payment');
    System.assertEquals(true, isCorrectExceptionType, 'Exception type should be AuraHandledException');
}
    
    @isTest
static void testCreatePayment_MissingRequiredFields() {
    Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
    
    // Test 1: Missing Account
    Payment__c payment1 = new Payment__c(
        Payment_Type__c = 'Service',
        Amount__c = 1000,
        Due_Date__c = Date.today().addDays(10)
    );
    
    Boolean exception1 = false;
    Boolean isCorrectExceptionType1 = false;
    Test.startTest();
    try {
        AccountPaymentController.createPayment(payment1);
    } catch (Exception e) {
        exception1 = true;
        if (e instanceof AuraHandledException) {
            isCorrectExceptionType1 = true;
        }
        System.debug('Test 1 Hata Mesajı: ' + e.getMessage());
    }
    System.assertEquals(true, exception1, 'Exception should be thrown for missing Account');
    System.assertEquals(true, isCorrectExceptionType1, 'Exception type should be AuraHandledException for missing Account');
    
 
    Payment__c payment2 = new Payment__c(
        Account__c = testAccount.Id,
        Amount__c = 1000,
        Due_Date__c = Date.today().addDays(10)
    );
    
    Boolean exception2 = false;
    Boolean isCorrectExceptionType2 = false;
    try {
        AccountPaymentController.createPayment(payment2);
    } catch (Exception e) {
        exception2 = true;
        if (e instanceof AuraHandledException) {
            isCorrectExceptionType2 = true;
        }
        System.debug('Test 2 Hata Mesajı: ' + e.getMessage());
    }
    System.assertEquals(true, exception2, 'Exception should be thrown for missing Payment Type');
    System.assertEquals(true, isCorrectExceptionType2, 'Exception type should be AuraHandledException for missing Payment Type');
    
  
    Payment__c payment3 = new Payment__c(
        Account__c = testAccount.Id,
        Payment_Type__c = 'Service',
        Due_Date__c = Date.today().addDays(10)
    );
    
    Boolean exception3 = false;
    Boolean isCorrectExceptionType3 = false;
    try {
        AccountPaymentController.createPayment(payment3);
    } catch (Exception e) {
        exception3 = true;
        if (e instanceof AuraHandledException) {
            isCorrectExceptionType3 = true;
        }
        System.debug('Test 3 Hata Mesajı: ' + e.getMessage());
    }
    System.assertEquals(true, exception3, 'Exception should be thrown for missing Amount');
    System.assertEquals(true, isCorrectExceptionType3, 'Exception type should be AuraHandledException for missing Amount');
    
    
    Payment__c payment4 = new Payment__c(
        Account__c = testAccount.Id,
        Payment_Type__c = 'Service',
        Amount__c = 1000
    );
    
    Boolean exception4 = false;
    Boolean isCorrectExceptionType4 = false;
    try {
        AccountPaymentController.createPayment(payment4);
    } catch (Exception e) {
        exception4 = true;
        if (e instanceof AuraHandledException) {
            isCorrectExceptionType4 = true;
        }
        System.debug('Test 4 Hata Mesajı: ' + e.getMessage());
    }
    Test.stopTest();
    
    System.assertEquals(true, exception4, 'Exception should be thrown for missing Due Date');
    System.assertEquals(true, isCorrectExceptionType4, 'Exception type should be AuraHandledException for missing Due Date');
}
  
    @isTest
    static void testGetPaymentTypePicklistValues() {
        Test.startTest();
        List<String> picklistValues = AccountPaymentController.getPaymentTypePicklistValues();
        Test.stopTest();
        
      
        System.assertNotEquals(null, picklistValues, 'Picklist values should not be null');
        System.assert(picklistValues.size() > 0, 'Should return at least one picklist value');
        System.assert(picklistValues.contains('Service'), 'Should contain Service option');
        System.assert(picklistValues.contains('Product'), 'Should contain Product option');
        System.assert(picklistValues.contains('Other'), 'Should contain Other option');
    }
  
    @isTest
    static void testBulkOperations() {
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account 1' LIMIT 1];
        
        List<Payment__c> bulkPayments = new List<Payment__c>();
        for (Integer i = 1; i <= 200; i++) {
            bulkPayments.add(new Payment__c(
                Account__c = testAccount.Id,
                Payment_Type__c = 'Service',
                Amount__c = 100 * i,
                Due_Date__c = Date.today().addDays(i)
            ));
        }
        
        Test.startTest();
        insert bulkPayments;
        List<Payment__c> retrievedPayments = AccountPaymentController.getPaymentsByAccount(testAccount.Id);
        Test.stopTest();
        
        System.assertEquals(203, retrievedPayments.size(), 'Should return all payments (3 from setup + 200 bulk)');
    }
}
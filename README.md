Account Payments Project Report
(All screenshots referenced in this document are located in the /images folder of this repository.)

1. Object Schema (Schema Builder)
Below is the schema diagram showing the Master-Detail relationship between the Account (Standard) and Payment__c (Custom) objects.

2. Relationship Choice: Master-Detail vs. Lookup
A Master-Detail Relationship was chosen to connect Account (the Master) and Payment__c (the Detail).

Reasoning:

We chose Master-Detail because a Payment record logically cannot exist without an Account. This relationship enforces that strict business rule.

Simple Example: Think of an Account as a physical folder and Payments as the documents inside it.

With Master-Detail, if you delete the folder (the Account), all the documents inside it are automatically deleted too (Cascade Delete).

You also cannot create a document (a Payment) that just floats in the air; it must be placed inside a specific folder (the Account) from the moment it's created (Required Relationship).

A Lookup relationship is looser, like a sticky note that just refers to the folder, but isn't owned by it. This was not suitable for essential financial data like payments.

3. Test Coverage
After running the AccountPaymentController_Test test class, the code coverage for the AccountPaymentController Apex class is:

100%

The test class covers all positive scenarios (fetching records, creating records) and negative scenarios (triggering the Due_Date validation rule).

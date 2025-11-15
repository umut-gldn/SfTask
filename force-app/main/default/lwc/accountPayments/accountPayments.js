import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, track, wire } from 'lwc';


import createPayment from '@salesforce/apex/AccountPaymentController.createPayment';
import getAccounts from '@salesforce/apex/AccountPaymentController.getAccounts';
import getPaymentsByAccount from '@salesforce/apex/AccountPaymentController.getPaymentsByAccount';
import getPaymentTypePicklistValues from '@salesforce/apex/AccountPaymentController.getPaymentTypePicklistValues';


const ACCOUNT_COLUMNS = [
    { label: 'Account Name', fieldName: 'Name', type: 'text' }
];

const PAYMENT_COLUMNS = [
    { label: 'Payment Name', fieldName: 'Name', type: 'text' },
    { label: 'Payment Type', fieldName: 'Payment_Type__c', type: 'text' }, 
    { label: 'Amount', fieldName: 'Amount__c', type: 'currency' },
    { label: 'Due Date', fieldName: 'Due_Date__c', type: 'date' } 
];

export default class AccountPayments extends LightningElement {
    
    accountColumns = ACCOUNT_COLUMNS;
    paymentColumns = PAYMENT_COLUMNS;

    accounts;
    accountError;

    @track selectedAccountId = null;
    @track selectedAccountName = '';

    payments;
    paymentError;
    isLoadingPayments = false;
    wiredPaymentsResult; 

   
    @track newPayment = {
        Payment_Type__c: '',
        Amount__c: null,
        Due_Date__c: '',
        Notes__c: ''
    };
    isCreatingPayment = false;

    
    @track paymentTypeOptions = [];
    @wire(getPaymentTypePicklistValues)
    wiredPicklist({ data, error }) {
        if (data) {
            this.paymentTypeOptions = data.map(value => {
                return { label: value, value: value };
            });
        } else if (error) {
            this.showToast('Error loading picklist', error.body.message, 'error');
        }
    }

    @wire(getAccounts)
    wiredAccounts(result) {
        if (result.data) {
            this.accounts = result.data;
            this.accountError = undefined;
        } else if (result.error) {
            this.accounts = undefined;
            this.accountError = result.error.body.message;
            this.showToast('Error Loading Accounts', this.accountError, 'error');
        }
    }

    @wire(getPaymentsByAccount, { accountId: '$selectedAccountId' }) 
    wiredPayments(result) {
        this.wiredPaymentsResult = result; 
        this.isLoadingPayments = true;

        if (result.data) {
            this.payments = result.data;
            this.paymentError = undefined;
            this.isLoadingPayments = false;
        } else if (result.error) {
            this.payments = undefined;
            this.paymentError = result.error.body.message;
            this.showToast('Error Loading Payments', this.paymentError, 'error');
            this.isLoadingPayments = false;
        }
    }


    handleAccountSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            this.selectedAccountId = selectedRows[0].Id;
            this.selectedAccountName = selectedRows[0].Name;
        } else {
            this.selectedAccountId = null; 
            this.selectedAccountName = '';
        }
    }

   
    handleFormChange(event) {
        const { name, value } = event.target;
        
        this.newPayment = { ...this.newPayment, [name]: value };
    }

   
    async handleCreatePayment() {
        if (!this.validateForm()) {
            this.showToast('Error', 'Please fill all required fields.', 'error');
            return;
        }
        this.isCreatingPayment = true;

     
        const paymentRecord = {
            'sobjectType': 'Payment__c',
            Account__c: this.selectedAccountId, 
            Payment_Type__c: this.newPayment.Payment_Type__c,
            Amount__c: this.newPayment.Amount__c,
            Due_Date__c: this.newPayment.Due_Date__c,
            Notes__c: this.newPayment.Notes__c
        };

        try {
          
            await createPayment({ payment: paymentRecord });

            this.showToast('Success', 'Payment created successfully!', 'success');
            await this.refreshPaymentList();
            this.resetForm();

        } catch (error) {
            this.showToast('Error Creating Payment', error.body.message, 'error');
        } finally {
            this.isCreatingPayment = false;
        }
    }


    validateForm() {
     
        return (
            this.newPayment.Payment_Type__c &&
            this.newPayment.Amount__c &&
            this.newPayment.Due_Date__c
        );
    }

    resetForm() {
        
        this.newPayment = {
            Payment_Type__c: '',
            Amount__c: null,
            Due_Date__c: '',
            Notes__c: ''
        };
        this.template.querySelectorAll('lightning-combobox, lightning-input, lightning-textarea')
            .forEach(element => {
                element.value = null;
            });
    }

    async refreshPaymentList() {
        return refreshApex(this.wiredPaymentsResult);
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }
}
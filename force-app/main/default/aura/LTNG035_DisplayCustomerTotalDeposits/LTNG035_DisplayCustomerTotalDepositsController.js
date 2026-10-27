({
    doInit : function(component, event, helper) {
       var segment = component.find('segment').get('v.value');
       console.log('segment -->',segment);
        if(segment !='Staff'){
            console.log('Non staff -->');
            component.set('v.showDeposit',true);
        }else{
            console.log('staff -->');
            component.set('v.showDeposit',false);
        }
        
        var action = component.get("c.getButtonAccess");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showButton", response.getReturnValue());
            } else {
                console.error("Failed to fetch button access:", state);
            }
        });
        $A.enqueueAction(action);
    },
    
    showPopup : function(component, event, helper) {
        console.log('showPopup function c');
        helper.CustomerDepositDetailsViaApi(component, event, helper);
    },
    
    openProductsOffers: function (component, event, helper) {
        // Always set to true to show the modal
        component.set('v.showLWCComponent', true);

        // Use a small timeout to ensure the LWC is rendered
        setTimeout(function () {
            // Call the LWC's openModal method directly
            var lwcComponent = component.find("lwcComponent");
            if (lwcComponent) {
                lwcComponent.openModal();
            }
        }, 100);
    },
})
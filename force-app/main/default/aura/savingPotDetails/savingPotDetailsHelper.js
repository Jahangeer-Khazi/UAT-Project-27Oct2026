/* 		Organization : ABC Bank
 * 		Created By: ABC Support
 *		Created Date: 07-10-2019
 * 		Change History: 
 *                   #CH01 04/09/2023 by Imane TSIOUCHA add Saving Pots process for alburaq
 * 					#CH02 10-12-2025 - Maksud Ali- Added Application event to pass the data to savingPotTransactions.cmp 
 */
({
    loadData : function(component, customerId, potId) {
        console.log('Saving Pot detail: loadData(customerId=' + customerId + ', potId=' + potId + ')');
        
        
        var helper = this;
        //CH01 -Start added by imane : pass Bahrain_alburaq in case of alburaq Product
        var regionName = component.get('v.account.Region_Flag__c');
        if(component.get('v.isAlburaqProduct') == true){
            regionName += '_alburaq';
        }
        //CH01 -End
        component.find('apexService').request(component.get('c.loadPotDetails'), {
            customerId: customerId,
            potId: potId,
            regionName: regionName
        },
                                              function(response) { 
                                                  var result = response.getReturnValue();
                                                  
                                                  var data = {};
                                                  if (true === result.isSuccess && !$A.util.isEmpty(result.responseData)) {
                                                      data = result.responseData;
                                                  }
                                                  
                                                  //CH02 - Start
                                                  if(Object.keys(data).length != 0){
                                                      const earnInterest = data.earnInterest != undefined && data.earnInterest ? 'true' : 'false';
                                                      const goalAmount = data.goalAmount ? data.goalAmount.toString() : '0';
                                                      const monthlyDepositAmount = data.monthlyDepositAmount ? data.monthlyDepositAmount.toString() : '0';
                                                      
                                                      var appEvent = $A.get("e.c:savingPotEvent");
                                                      appEvent.setParams({ earnInterest: earnInterest,goalAmount:goalAmount,monthlyDepositAmount:monthlyDepositAmount });
                                                      appEvent.fire();
                                                  }
                                                  //CH02 - End
                                                  
                                                  component.set('v.data', helper.formatData(data));
                                              });
    },
    formatData: function(obj){
        
        var ic = obj && obj.account && obj.account.interestConditions;
        var result = obj;
        var annualRate = this.getAnnualRate(ic);
        
        result.annualInterestRate = annualRate;
        result.annualProfitRate  = annualRate;
        return result;
    },
    
    getAnnualRate: function(interestConditions) {
        if ($A.util.isEmpty(interestConditions) || typeof interestConditions === 'string') {
            return '';
        }
        
        var len = interestConditions.length;
        if (typeof len !== 'number' || len <= 0) {
            return '';
        }
        
        for (var i = 0; i < len; i++) {
            var condition = interestConditions[i];
            if (condition && (condition.active === true || condition.active === 'true')) {
                return this.formatRate(condition.rate);
            }
        }
        
        var first = interestConditions[0];
        if (first && first.rate !== undefined && first.rate !== null && first.rate !== '') {
            return this.formatRate(first.rate);
        }
        
        return '';
    },
    
    formatRate: function(rate) {
        if (rate === undefined || rate === null || rate === '') {
            return '';
        }
        
        var num = Number(rate);
        if (isNaN(num)) {
            return '';
        }
        
        var percent = num < 1 ? num * 100 : num;
        
        return percent.toFixed(2) + '%';
    }
})
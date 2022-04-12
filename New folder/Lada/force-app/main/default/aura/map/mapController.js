({
  doInit: function (component, event, helper) {
    try {
      helper.callToServer(
        component,
        "c.findAccountsForMap",
        function (response) {
          /* eslint-disable */
          var markers = new Array();
          for (var i = 0; i < response.length; i++) {
            var accountInfo = response[i];
            var completeAddress = [];
            // if(accountInfo.BillingCity){
            //     completeAddress.push(accountInfo.BillingCity);
            //  }if(accountInfo.BillingState){
            //    completeAddress.push(accountInfo.BillingState);
            // }if(accountInfo.BillingPostalCode){
            //     completeAddress.push(accountInfo.BillingPostalCode);
            //   }if(accountInfo.BillingCountry){
            //       completeAddress.push(accountInfo.BillingCountry);
            //   }
            if (accountInfo.Latitude) {
              completeAddress.push(accountInfo.Latitude__c);
            }
            if (accountInfo.Longitude) {
              completeAddress.push(accountInfo.Longitude__c);
            }

            markers.push({
              location: {
                //          'City': accountInfo.BillingCity,
                //          'Country': accountInfo.BillingCountry,
                //          'PostalCode': accountInfo.BillingPostalCode,
                //          'State': accountInfo.BillingState,
                //          'Street': accountInfo.Street,
                Latitude: accountInfo.Latitude__c,
                Longitude: accountInfo.Longitude__c
              },
              icon: "standard:account",
              title: accountInfo.Name,
              description: completeAddress.join()
            });
          }

          component.set("v.markersTitle", "All Account Locations");
          component.set("v.mapMarkers", markers);
          component.set("v.center", {
            location: {
              Latitude: "55.75",
              Longitude: "37.6167"
            }
          });
        }
      );
    } catch (e) {
      System.debug(
        LoggingLevel.ERROR,
        "The following exception has occurred: " + e.getMessage()
      );
    }
  }
});

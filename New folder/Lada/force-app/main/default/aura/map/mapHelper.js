/* eslint-disable no-undef */
({
  callToServer: function (component, method, callback) {
    var action = component.get(method);
    try {
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          callback.call(this, response.getReturnValue());
        } else if (state === "ERROR") {
          var e = response.getError();
          System.debug(
            LoggingLevel.ERROR,
            "The following exception has occurred: " + e.getMessage()
          );
        }
      });
    } catch (e) {
      System.debug(
        LoggingLevel.ERROR,
        "The following exception has occurred: " + e.getMessage()
      );
    }
    $A.enqueueAction(action);
  }
});

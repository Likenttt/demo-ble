//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class ABSView extends WatchUi.SimpleDataField {
  public var message as String;

  //! Set the label of the data field here
  //! @param deviceManager The device manager
  public function initialize() {
    SimpleDataField.initialize();
    label = "Message";
  }

  //! Play the sample every two seconds
  //! @param info The updated Activity.Info object
  //! @return Value to display in the data field
  public function compute(
    info as Info
  ) as Numeric or Duration or String or Null {
    // See Activity.Info in the documentation for available information.
    return message;
  }
}

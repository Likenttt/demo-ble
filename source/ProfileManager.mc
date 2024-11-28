//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;
import Toybox.System;

class ProfileManager {
  public const BROADCAST_SERVICE = BluetoothLowEnergy.stringToUuid(
    "0000190A-0000-1000-8000-00805F9B34FB"
  );

  public const DATA_SENDING_SERVICE = BluetoothLowEnergy.stringToUuid(
    "6E400001-B5A3-F393-E0A9-E50E24DCCA00"
  );

  public const DATA_SENDING_CHARACTERISTIC = BluetoothLowEnergy.stringToUuid(
    "6E400002-B5A3-F393-E0A9-E50E24DCCA00"
  );

  public const DATA_RECEIVING_CHARACTERISTIC = BluetoothLowEnergy.stringToUuid(
    "6E400003-B5A3-F393-E0A9-E50E24DCCA00"
  );

  private const _dataSendingProfileDef = {
    :uuid => DATA_SENDING_SERVICE,
    :characteristics => [
      {
        :uuid => DATA_SENDING_CHARACTERISTIC,
        :descriptors => [BluetoothLowEnergy.cccdUuid()],
      },
      {
        :uuid => DATA_RECEIVING_CHARACTERISTIC,
        :descriptors => [BluetoothLowEnergy.cccdUuid()],
      },
    ],
  };

  //! Register the bluetooth profile
  public function registerProfiles() as Void {
    BluetoothLowEnergy.registerProfile(_dataSendingProfileDef);
  }
}

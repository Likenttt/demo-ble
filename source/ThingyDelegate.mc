//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;
import Toybox.Lang;

class ThingyDelegate extends BluetoothLowEnergy.BleDelegate {
  private var _profileManager as ProfileManager;

  private var _view as ABSView;

  //! Constructor
  //! @param profileManager The profile manager
  public function initialize(
    view as ABSView,
    profileManager as ProfileManager
  ) {
    BleDelegate.initialize();
    _view = view;
    _profileManager = profileManager;
  }

  //! Handle new Scan Results being received
  //! @param scanResults An iterator of new scan result objects
  public function onScanResults(scanResults as Iterator) as Void {
    var maxRssiResult = null;
    var maxRssi = -99999;

    for (
      var result = scanResults.next();
      result != null;
      result = scanResults.next()
    ) {
      // Log.Debug.logMessage("AbsolutSweatDelegate", "Processing scan result");

      if (result instanceof ScanResult && result.getRssi() > -80) {
        var uuids = result.getServiceUuids();
        // var name = result.getDeviceName();
        // var rawData = result.getRawData();
        // var appearance = result.getAppearance();
        var rssi = result.getRssi();

        var hasAbsolutSweatBroadcast = false;
        for (var uuid = uuids.next(); uuid != null; uuid = uuids.next()) {
          var uuidString = uuid.toString();
          // Log.Debug.logMessage("AbsolutSweatDelegate", "uuids:" + uuidString);
          if ("0000190A-0000-1000-8000-00805F9B34FB".equals(uuidString)) {
            hasAbsolutSweatBroadcast = true;
            _view.message = "Found ABS";
          }
        }

        if (hasAbsolutSweatBroadcast) {
          // Check for the maximum RSSI
          if (rssi > maxRssi) {
            maxRssi = rssi;
            maxRssiResult = result;
          }
        }
      }
    }

    // If no previous device was connected, connect to the device with the highest RSSI
    if (maxRssiResult != null) {
      processPairing(maxRssiResult);
    }

    // Log.Debug.logMessage("AbsolutSweatDelegate", "Exiting onScanResults");
  }

  //! Start BLE scanning
  public function start() as Void {
    BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_SCANNING);
    _view.message = "scanning";
  }

  private function processPairing(scanResult as ScanResult) as Void {
    if (scanResult.getRssi() > -50) {
      // BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_OFF);
      BluetoothLowEnergy.pairDevice(scanResult);
      _view.message = "pairing";
    }
  }
  //! Handle pairing and connecting to a device
  //! @param device The device state that was changed
  //! @param state The state of the connection
  public function onConnectedStateChanged(device, state) {
    if (state == BluetoothLowEnergy.CONNECTION_STATE_CONNECTED) {
      BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_OFF);
      _view.message = "connected";
    } else {
      _view.message = "disconnected";
      BluetoothLowEnergy.unpairDevice(device);
      BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_SCANNING);
    }
    WatchUi.requestUpdate();
  }

  //! Handle the completion of a write operation on a characteristic
  //! @param characteristic The characteristic that was written
  //! @param status The BluetoothLowEnergy status indicating the result of the operation
  public function onCharacteristicWrite(
    char as Characteristic,
    status as Status
  ) as Void {
    System.println("Proc Write: (" + char.getUuid() + ") - " + status);

    // if (char.equals(_config)) {
    //   _configComplete = true;
    //   _sampleInProgress = false;
    // } else if (char.equals(_speakerData)) {
    //   _sampleInProgress = false;
    // }
  }

  //! Broadcast a new scan result
  //! @param scanResult The new scan result
  private function broadcastScanResult(scanResult as ScanResult) as Void {
    if (scanResult.getRssi() > -50) {
      BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_OFF);
      BluetoothLowEnergy.pairDevice(scanResult);
    }
  }

  //! Get whether the iterator contains a specific uuid
  //! @param iter Iterator of uuid objects
  //! @param obj Uuid to search for
  //! @return true if object found, false otherwise
  private function contains(iter as Iterator, obj as Uuid) as Boolean {
    for (var uuid = iter.next(); uuid != null; uuid = iter.next()) {
      if (uuid.equals(obj)) {
        return true;
      }
    }

    return false;
  }
}

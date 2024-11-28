//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;
import Toybox.Lang;

class ThingyDelegate extends BluetoothLowEnergy.BleDelegate {
  private var _profileManager as ProfileManager;

  private var _onScanResult as WeakReference?;
  private var _onConnection as WeakReference?;
  private var _onCharWrite as WeakReference?;

  //! Constructor
  //! @param profileManager The profile manager
  public function initialize(profileManager as ProfileManager) {
    BleDelegate.initialize();
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

  private function processPairing(scanResult as ScanResult) as Void {
    var onScanResult = _onScanResult;
    if (onScanResult != null) {
      if (onScanResult.stillAlive()) {
        (onScanResult.get() as DeviceManager).procScanResult(scanResult);
      }
    }
  }
  //! Handle pairing and connecting to a device
  //! @param device The device state that was changed
  //! @param state The state of the connection
  public function onConnectedStateChanged(
    device as Device,
    state as ConnectionState
  ) as Void {
    var onConnection = _onConnection;
    if (onConnection != null) {
      if (onConnection.stillAlive()) {
        (onConnection.get() as DeviceManager).procConnection(device);
      }
    }
  }

  //! Handle the completion of a write operation on a characteristic
  //! @param characteristic The characteristic that was written
  //! @param status The BluetoothLowEnergy status indicating the result of the operation
  public function onCharacteristicWrite(
    characteristic as Characteristic,
    status as Status
  ) as Void {
    var onCharWrite = _onCharWrite;
    if (onCharWrite != null) {
      if (onCharWrite.stillAlive()) {
        (onCharWrite.get() as DeviceManager).procCharWrite(
          characteristic,
          status
        );
      }
    }
  }

  //! Store a new manager to manage scan results
  //! @param manager The manager of the scan results
  public function notifyScanResult(manager as DeviceManager) as Void {
    _onScanResult = manager.weak();
  }

  //! Store a new manager to manage device connections
  //! @param manager The manager for devices
  public function notifyConnection(manager as DeviceManager) as Void {
    _onConnection = manager.weak();
  }

  //! Store a new manager to handle characteristic writes
  //! @param manager The manager for characteristics
  public function notifyCharWrite(manager as DeviceManager) as Void {
    _onCharWrite = manager.weak();
  }

  //! Broadcast a new scan result
  //! @param scanResult The new scan result
  private function broadcastScanResult(scanResult as ScanResult) as Void {
    var onScanResult = _onScanResult;
    if (onScanResult != null) {
      if (onScanResult.stillAlive()) {
        (onScanResult.get() as DeviceManager).procScanResult(scanResult);
      }
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

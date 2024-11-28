//
// Copyright 2019-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

import Toybox.BluetoothLowEnergy;
import Toybox.Lang;
import Toybox.System;

class DeviceManager {
  private var _profileManager as ProfileManager;
  private var _device as Device?;
  private var _soundService as Service?;
  private var _config as Characteristic?;
  private var _speakerData as Characteristic?;
  private var _configComplete as Boolean = false;
  private var _sampleInProgress as Boolean = false;
  private var _connected as Boolean = false;
  //! Constructor
  //! @param bleDelegate The BLE delegate
  //! @param profileManager The profile manager
  public function initialize(
    bleDelegate as ThingyDelegate,
    profileManager as ProfileManager
  ) {
    _device = null;

    bleDelegate.notifyScanResult(self);
    bleDelegate.notifyConnection(self);
    bleDelegate.notifyCharWrite(self);

    _profileManager = profileManager;
  }

  //! Start BLE scanning
  public function start() as Void {
    BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_SCANNING);
  }

  public function connected() as Boolean {
    return _device != null;
  }

  //! Process scan result
  //! @param scanResult The scan result
  public function procScanResult(scanResult as ScanResult) as Void {
    // Pair the first Thingy we see with good RSSI
    if (scanResult.getRssi() > -50) {
      BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_OFF);
      _device = BluetoothLowEnergy.pairDevice(scanResult);
    }
  }

  //! Process a new device connection
  //! @param device The device that was connected
  public function procConnection(device as Device) as Void {
    if (_device != null && device.isConnected()) {
      _device = device;
      _connected = true;
      // startSoundControl();
    } else {
      _device = null;
      _connected = false;
      BluetoothLowEnergy.setScanState(BluetoothLowEnergy.SCAN_STATE_SCANNING);
    }
  }

  //! Handle the completion of a write operation on a characteristic
  //! @param char The characteristic that was written
  //! @param status The result of the operation
  public function procCharWrite(
    char as Characteristic,
    status as Status
  ) as Void {
    System.println("Proc Write: (" + char.getUuid() + ") - " + status);

    if (char.equals(_config)) {
      _configComplete = true;
      _sampleInProgress = false;
    } else if (char.equals(_speakerData)) {
      _sampleInProgress = false;
    }
  }

  //! Play the sample sound
  //! @param sampleId Identifier of the sample
  public function playSample(sampleId as Number) as Void {
    if (null == _device || !_configComplete || _sampleInProgress) {
      return;
    }

    _sampleInProgress = true;
    if (_speakerData != null) {
      _speakerData.requestWrite([sampleId]b, {});
    }
  }

  //! Start the sound control on the device
  private function startSoundControl() as Void {
    System.println("Start Sound");
    // if (_device != null) {
    //   _soundService = _device.getService(_profileManager.THINGY_SOUND_SERVICE);
    //   var soundService = _soundService;
    //   if (soundService != null) {
    //     _config = soundService.getCharacteristic(
    //       _profileManager.SOUND_CONFIG_CHARACTERISTIC
    //     );
    //     _speakerData = soundService.getCharacteristic(
    //       _profileManager.SPEAKER_DATA_CHARACTERISTIC
    //     );
    //   }
    // }
    // Put the speaker into Sample Mode
    _configComplete = false;
    if (_config != null) {
      _config.requestWrite([0x03, 0x01]b, {
        :writeType => BluetoothLowEnergy.WRITE_TYPE_WITH_RESPONSE,
      });
    }
  }
}

#!/usr/bin/env node
/**
 * NirPay Bluetooth Low Energy (BLE) Mock
 * =====================================
 * Mock receiver untuk test transfer NirPay via BLE.
 * 
 * Usage:
 *   sudo node bt_mock_ble.js
 */

const bleno = require('@abandonware/bleno');

// UUIDs for NirPay Mock
// (Can be adjusted to match what the client expects)
const SERVICE_UUID = '12345678901234567890123456789012';
const CHAR_WRITE_UUID = '12345678901234567890123456789013';

function log(msg, icon = '•') {
  const ts = new Date().toLocaleTimeString('id-ID', { hour12: false });
  console.log(`[${ts}] ${icon} ${msg}`);
}

class TransferCharacteristic extends bleno.Characteristic {
  constructor() {
    super({
      uuid: CHAR_WRITE_UUID,
      properties: ['write', 'writeWithoutResponse'],
      value: null
    });
  }

  onWriteRequest(data, offset, withoutResponse, callback) {
    try {
      const payload = JSON.parse(data.toString('utf-8'));
      const txId = payload.transactionId || '?';
      const amt = payload.amount || 0;

      console.log('');
      log('═══════════════════════════════════════', '📥');
      log('    TRANSFER DITERIMA (via BLE)!', '📥');
      log('═══════════════════════════════════════', '📥');
      log(`  TX ID  : ${txId}`, '📋');
      log(`  Amount : Rp ${amt.toLocaleString('id-ID')}`, '💰');
      log(`  Time   : ${payload.createdAt || '-'}`, '📋');
      log('═══════════════════════════════════════', '📥');
      console.log('');

      if (callback) callback(this.RESULT_SUCCESS);
    } catch (e) {
      log(`Error parsing BLE write data: ${e.message}`, '❌');
      console.log('Raw data received:', data.toString('utf-8'));
      if (callback) callback(this.RESULT_UNLIKELY_ERROR);
    }
  }
}

// ─── BLE Initialization ───

bleno.on('stateChange', function(state) {
  log(`BLE State changed to: ${state}`, '📻');
  if (state === 'poweredOn') {
    log('Mulai advertising service...', '📡');
    bleno.startAdvertising('NirPayMock', [SERVICE_UUID]);
  } else {
    bleno.stopAdvertising();
  }
});

bleno.on('advertisingStart', function(error) {
  if (!error) {
    log('Advertising berhasil! Service siap.', '✅');
    bleno.setServices([
      new bleno.PrimaryService({
        uuid: SERVICE_UUID,
        characteristics: [
          new TransferCharacteristic()
        ]
      })
    ]);
    
    console.log('');
    console.log('═══════════════════════════════════════════════════');
    console.log('  📥 NirPay BLE Mock — MODE TERIMA');
    console.log('═══════════════════════════════════════════════════');
    console.log(`  🌐 Service UUID : ${SERVICE_UUID}`);
    console.log(`  🛑 Stop         : Ctrl+C`);
    console.log('═══════════════════════════════════════════════════');
    console.log('');
  } else {
    log(`Advertising error: ${error}`, '❌');
  }
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('');
  log('Shutting down BLE Mock...', '🛑');
  bleno.stopAdvertising(() => {
    process.exit(0);
  });
  setTimeout(() => process.exit(0), 1000);
});

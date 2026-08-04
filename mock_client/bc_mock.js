#!/usr/bin/env node
/**
 * NirPay Bluetooth Mock
 * =======================
 * Mock sender & receiver untuk test transfer NirPay.
 *
 * Usage:
 *   node bc_mock.js terima
 *   node bc_mock.js kirim --amount 50000
 *   node bc_mock.js scan
 */

const http = require('http');
const os = require('os');

// ─── Args ───
const args = process.argv.slice(2);
const mode = (args[0] || '').toLowerCase();

let port = 8765;
let amount = 50000;
let ip = 'localhost';
let bleAddress = null;

for (let i = 1; i < args.length; i++) {
  if (args[i] === '--port' && args[i + 1]) port = parseInt(args[++i]);
  if (args[i] === '--amount' && args[i + 1]) amount = parseInt(args[++i]);
  if (args[i] === '--ip' && args[i + 1]) ip = args[++i];
  if (args[i] === '--address' && args[i + 1]) bleAddress = args[++i];
}

function log(msg, icon = '•') {
  const ts = new Date().toLocaleTimeString('id-ID', { hour12: false });
  console.log(`[${ts}] ${icon} ${msg}`);
}

function generateTxId() {
  return 'tx-' + Date.now() + '-' + Math.random().toString(36).substr(2, 9);
}

// ─── Mode: Terima (HTTP Server) ───

function runReceiver() {
  const server = http.createServer((req, res) => {
    if (req.method === 'POST' && req.url === '/transfer') {
      let body = '';
      req.on('data', (chunk) => body += chunk);
      req.on('end', () => {
        try {
          const payload = JSON.parse(body);
          const txId = payload.transactionId || '?';
          const amt = payload.amount || 0;

          console.log('');
          log('═══════════════════════════════════════', '📥');
          log('       TRANSFER DITERIMA!', '📥');
          log('═══════════════════════════════════════', '📥');
          log(`  TX ID  : ${txId}`, '📋');
          log(`  Amount : Rp ${amt.toLocaleString('id-ID')}`, '💰');
          log(`  Time   : ${payload.createdAt || '-'}`, '📋');
          log('═══════════════════════════════════════', '📥');
          console.log('');

          const ack = JSON.stringify({
            status: 'ACK',
            transactionId: txId,
            receivedAt: new Date().toISOString(),
          });

          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(ack);
          log('ACK dikirim', '✅');
        } catch (e) {
          log(`Error: ${e.message}`, '❌');
          res.writeHead(400);
          res.end();
        }
      });
    } else if (req.method === 'GET' && req.url === '/health') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ status: 'ok', service: 'NirPay-Receiver' }));
    } else {
      res.writeHead(404);
      res.end();
    }
  });

  server.listen(port, '0.0.0.0', () => {
    console.log('');
    console.log('═══════════════════════════════════════════════════');
    console.log('  📥 NirPay Mock — MODE TERIMA (HTTP)');
    console.log('═══════════════════════════════════════════════════');
    console.log(`  🌐 Listening : 0.0.0.0:${port}`);
    console.log(`  📤 Dari CLI  : node bc_mock.js kirim --amount 50000`);
    console.log(`  🛑 Stop      : Ctrl+C`);
    console.log('═══════════════════════════════════════════════════');
    console.log('');
  });

  process.on('SIGINT', () => {
    console.log('');
    log('Shutting down...', '🛑');
    server.close(() => process.exit(0));
    setTimeout(() => process.exit(0), 1000);
  });
}

// ─── Mode: Scan (BLE) ───

async function runScan() {
  let noble;
  try {
    noble = require('@abandonware/noble');
  } catch (e) {
    log('Install noble: npm install @abandonware/noble', '❌');
    process.exit(1);
  }

  console.log('');
  console.log('═══════════════════════════════════════════════════');
  console.log('  🔍 NirPay Mock — MODE SCAN (BLE)');
  console.log('═══════════════════════════════════════════════════');
  console.log('  Scanning untuk NirPay BLE devices...');
  console.log('═══════════════════════════════════════════════════');
  console.log('');

  const SERVICE_UUID = '12345678123412341234123456789abc';

  noble.on('stateChange', (state) => {
    log(`Bluetooth state: ${state}`, '🔵');
    if (state === 'poweredOn') {
      log('Mulai scan (semua device)...', '🔍');
      // Scan semua device, jangan filter service UUID
      noble.startScanning([], true);
    } else {
      log('Bluetooth tidak aktif! Jalankan dengan sudo.', '❌');
      process.exit(1);
    }
  });

  noble.on('discover', (peripheral) => {
    const name = peripheral.advertisement.localName || peripheral.address || 'Unknown';
    const uuid = peripheral.uuid;
    const rssi = peripheral.rssi;
    const services = peripheral.advertisement.serviceUuids || [];

    const isNirPay = name.toLowerCase().includes('nirpay') ||
      services.some(s => s.toLowerCase().includes(SERVICE_UUID.substring(0, 8).toLowerCase()));

    if (isNirPay) {
      console.log('');
      log(`🎯 NIRPAY: ${name}`, '✅');
      log(`   Address  : ${peripheral.address}`, '📋');
      log(`   UUID     : ${uuid}`, '📋');
      log(`   RSSI     : ${rssi} dBm`, '📋');
      log(`   Services : ${services.join(', ') || 'none'}`, '📋');
    } else {
      // Tampilkan juga device lain (debug)
      log(`${name} (${peripheral.address}) RSSI=${rssi} [${services.join(',')}]`, '📱');
    }
  });

  setTimeout(() => {
    noble.stopScanning();
    log('Scan selesai', '🔵');
    process.exit(0);
  }, 15000);
}

// ─── Mode: Kirim (HTTP) ───

function checkHealth(host, checkPort) {
  return new Promise((resolve) => {
    const req = http.get({
      hostname: host,
      port: checkPort,
      path: '/health',
      timeout: 1500,
    }, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          if (json.status === 'ok') {
            resolve({ host, port: checkPort, name: json.service || 'Unknown' });
          } else {
            resolve(null);
          }
        } catch { resolve(null); }
      });
    });
    req.on('error', () => resolve(null));
    req.on('timeout', () => { req.destroy(); resolve(null); });
  });
}

async function scanReceivers() {
  const interfaces = os.networkInterfaces();
  let localSubnet = '192.168.1';
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        localSubnet = iface.address.split('.').slice(0, 3).join('.');
        break;
      }
    }
  }

  log(`Scanning ${localSubnet}.x:${port} untuk NirPay receiver...`, '🔍');

  const checks = [];
  for (let i = 1; i <= 254; i++) {
    checks.push(checkHealth(`${localSubnet}.${i}`, port));
  }
  checks.push(checkHealth('localhost', port));
  checks.push(checkHealth('127.0.0.1', port));

  const results = await Promise.all(checks);
  const found = results.filter(Boolean);

  const unique = [];
  const seen = new Set();
  for (const r of found) {
    const key = `${r.host}:${r.port}`;
    if (!seen.has(key)) {
      seen.add(key);
      unique.push(r);
    }
  }

  return unique;
}

function sendTransfer(targetHost, targetPort, txId) {
  return new Promise((resolve) => {
    const payload = JSON.stringify({
      transactionId: txId,
      amount,
      currency: 'IDR',
      status: 'DATA_SENT',
      createdAt: new Date().toISOString(),
      senderWallet: 'mock-sender',
    });

    log(`Mengirim Rp ${amount.toLocaleString('id-ID')} ke ${targetHost}:${targetPort}...`, '📤');

    const req = http.request({
      hostname: targetHost,
      port: targetPort,
      path: '/transfer',
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      timeout: 10000,
    }, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const result = JSON.parse(data);
          log(`Response: ${JSON.stringify(result)}`, '📦');

          if (result.status === 'ACK') {
            console.log('');
            log('═══════════════════════════════════════', '✅');
            log('      TRANSFER BERHASIL!', '✅');
            log(`  Amount : Rp ${amount.toLocaleString('id-ID')}`, '💰');
            log(`  TX ID  : ${txId}`, '📋');
            log('═══════════════════════════════════════', '✅');
            resolve(true);
          } else {
            resolve(false);
          }
        } catch (e) {
          log(`Parse error: ${e.message}`, '❌');
          resolve(false);
        }
      });
    });

    req.on('error', (e) => {
      const msg = e.code === 'ECONNREFUSED'
        ? `Ditolak! Receiver tidak jalan di ${targetHost}:${targetPort}`
        : `Error: ${e.code || e.message}`;
      log(msg, '❌');
      resolve(false);
    });

    req.on('timeout', () => {
      log('Timeout!', '❌');
      req.destroy();
      resolve(false);
    });

    req.write(payload);
    req.end();
  });
}

function askQuestion(question) {
  return new Promise((resolve) => {
    const rl = require('readline').createInterface({
      input: process.stdin,
      output: process.stdout,
    });
    rl.question(question, (answer) => {
      rl.close();
      resolve(answer.trim());
    });
  });
}

async function runSender() {
  const txId = generateTxId();

  console.log('');
  console.log('═══════════════════════════════════════════════════');
  console.log('  📤 NirPay Mock — MODE KIRIM');
  console.log('═══════════════════════════════════════════════════');
  console.log(`  💰 Amount : Rp ${amount.toLocaleString('id-ID')}`);
  console.log('═══════════════════════════════════════════════════');
  console.log('');

  const receivers = await scanReceivers();

  if (receivers.length === 0) {
    log('Tidak ditemukan NirPay receiver!', '❌');
    log(`Jalankan dulu: node bc_mock.js terima`, '💡');
    process.exit(1);
  }

  log(`Ditemukan ${receivers.length} receiver:`, '✅');
  console.log('');
  receivers.forEach((r, i) => {
    console.log(`    [${i + 1}] ${r.host}:${r.port} (${r.name})`);
  });
  console.log('');

  let target;
  if (receivers.length === 1) {
    target = receivers[0];
    log(`Otomatis pilih: ${target.host}:${target.port}`, '📡');
  } else {
    const choice = await askQuestion(`Pilih receiver [1-${receivers.length}]: `);
    const idx = parseInt(choice) - 1;
    if (idx < 0 || idx >= receivers.length) {
      log('Pilihan tidak valid!', '❌');
      process.exit(1);
    }
    target = receivers[idx];
  }

  console.log(`  📡 Target : ${target.host}:${target.port}`);
  console.log(`  📋 TX ID  : ${txId}`);
  console.log('');

  const success = await sendTransfer(target.host, target.port, txId);
  process.exit(success ? 0 : 1);
}

// ─── Main ───

// ─── Mode: Kirim BLE ───

async function runSenderBle() {
  let noble;
  try {
    noble = require('@abandonware/noble');
  } catch (e) {
    log('Install noble: npm install @abandonware/noble', '❌');
    process.exit(1);
  }

  const SERVICE_UUID = '12345678123412341234123456789abc';
  const RX_CHAR_UUID = '12345678123412341234123456789ab2';
  const ACK_CHAR_UUID = '12345678123412341234123456789ab3';

  const txId = generateTxId();

  console.log('');
  console.log('═══════════════════════════════════════════════════');
  console.log('  📤 NirPay Mock — MODE KIRIM (BLE)');
  console.log('═══════════════════════════════════════════════════');
  console.log(`  💰 Amount : Rp ${amount.toLocaleString('id-ID')}`);
  console.log(`  📋 TX ID  : ${txId}`);
  console.log('═══════════════════════════════════════════════════');
  console.log('');

  noble.on('stateChange', (state) => {
    log(`Bluetooth state: ${state}`, '🔵');
    if (state === 'poweredOn') {
      log('Scanning semua BLE devices...', '🔍');
      // Scan semua, jangan filter
      noble.startScanning([], true);
    } else {
      log('Bluetooth tidak aktif! Jalankan dengan sudo.', '❌');
      process.exit(1);
    }
  });

  noble.on('discover', async (peripheral) => {
    const name = peripheral.advertisement.localName || peripheral.address || 'Unknown';
    const uuid = peripheral.uuid;
    const rssi = peripheral.rssi;
    const services = peripheral.advertisement.serviceUuids || [];

    // Match by address if specified
    if (bleAddress) {
      const match = peripheral.address.toLowerCase() === bleAddress.toLowerCase() ||
        uuid.toLowerCase() === bleAddress.toLowerCase();
      if (!match) return;
      log(`Found target: ${name} (${peripheral.address})`, '📱');
    } else {
      // Auto-detect NirPay
      const isNirPay = name.toLowerCase().includes('nirpay') ||
        services.some(s => s.toLowerCase().includes(SERVICE_UUID.substring(0, 8).toLowerCase()));
      if (!isNirPay) return;
      log(`Found NirPay: ${name} (${peripheral.address}) RSSI=${rssi}`, '📱');
    }

    log(`🎯 NirPay receiver ditemukan: ${name}`, '✅');
    noble.stopScanning();

    try {
      // 1. Connect
      log('Connecting...', '🔗');
      await peripheral.connectAsync();
      log('Connected!', '✅');

      // 2. Discover services
      log('Discovering services...', '📡');
      const discoveredServices = await peripheral.discoverServicesAsync([SERVICE_UUID]);

      if (discoveredServices.length === 0) {
        log('NirPay service not found!', '❌');
        await peripheral.disconnectAsync();
        process.exit(1);
      }

      const service = discoveredServices[0];
      log(`Service: ${service.uuid}`, '✅');

      // 3. Discover characteristics
      const chars = await service.discoverCharacteristicsAsync([RX_CHAR_UUID, ACK_CHAR_UUID]);

      let rxChar = null;
      let ackChar = null;

      for (const char of chars) {
        log(`Char: ${char.uuid} (${char.properties.join(', ')})`, '📋');
        if (char.uuid === RX_CHAR_UUID) rxChar = char;
        if (char.uuid === ACK_CHAR_UUID) ackChar = char;
      }

      if (!rxChar) {
        log('RX characteristic not found!', '❌');
        await peripheral.disconnectAsync();
        process.exit(1);
      }

      // 4. Send payload
      const payload = JSON.stringify({
        transactionId: txId,
        amount,
        currency: 'IDR',
        status: 'DATA_SENT',
        createdAt: new Date().toISOString(),
        senderWallet: 'mock-sender',
      });

      log(`Sending: ${payload}`, '📤');
      await rxChar.writeAsync(Buffer.from(payload), false);
      log('Data sent!', '✅');

      // 5. Wait for ACK
      if (ackChar) {
        log('Waiting for ACK...', '⏳');
        await ackChar.subscribeAsync();

        const ackOk = await new Promise((resolve) => {
          const timeout = setTimeout(() => resolve(false), 10000);

          ackChar.on('data', (data) => {
            try {
              const ack = JSON.parse(data.toString());
              log(`ACK: ${JSON.stringify(ack)}`, '📨');
              clearTimeout(timeout);
              resolve(true);
            } catch (e) {
              log(`ACK parse error: ${e.message}`, '⚠️');
            }
          });
        });

        await ackChar.unsubscribeAsync();

        if (ackOk) {
          console.log('');
          log('═══════════════════════════════════════', '🎉');
          log('      TRANSFER BERHASIL!', '🎉');
          log(`  Amount : Rp ${amount.toLocaleString('id-ID')}`, '💰');
          log(`  TX ID  : ${txId}`, '📋');
          log('═══════════════════════════════════════', '🎉');
        } else {
          log('ACK timeout!', '⚠️');
        }
      }

      // 6. Disconnect
      await peripheral.disconnectAsync();
      log('Disconnected', '🔌');

    } catch (e) {
      log(`Error: ${e.message}`, '❌');
      try { await peripheral.disconnectAsync(); } catch (_) {}
    }

    process.exit(0);
  });

  // Timeout
  setTimeout(() => {
    log('Scan timeout! Tidak ditemukan NirPay receiver.', '❌');
    log('Pastikan HP dalam mode "Terima Uang → Bluetooth"', '💡');
    noble.stopScanning();
    process.exit(1);
  }, 30000);
}

// ─── Main ───

if (!mode || !['terima', 'kirim', 'kirim-ble', 'scan', 'receive', 'send', 'send-ble', 'r', 'k', 's', 'kb'].includes(mode)) {
  console.log('');
  console.log('Usage:');
  console.log('  node bc_mock.js terima [--port 8765]                    # Receiver (HTTP)');
  console.log('  node bc_mock.js scan                                      # Scan BLE devices');
  console.log('  node bc_mock.js kirim [--amount 50000] [--ip x]          # Kirim (HTTP)');
  console.log('  node bc_mock.js kirim-ble [--amount 50000] [--address X] # Kirim (BLE)');
  console.log('');
  console.log('BLE address bisa didapat dari: sudo hcitool lescan');
  console.log('');
  process.exit(1);
}

if (['terima', 'receive', 'r'].includes(mode)) {
  runReceiver();
} else if (['scan', 's'].includes(mode)) {
  runScan();
} else if (['kirim-ble', 'send-ble', 'kb'].includes(mode)) {
  runSenderBle();
} else {
  runSender();
}

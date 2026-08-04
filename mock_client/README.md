# NirPay Bluetooth Mock

Mock sender & receiver untuk test transfer NirPay.

## Usage

```bash
cd mock_client

# Mode Terima (Receiver)
node bc_mock.js terima

# Mode Kirim (Sender)
node bc_mock.js kirim --amount 50000
node bc_mock.js kirim --amount 100000 --ip 192.168.1.100
```

## Test Flow

```
Terminal 1 (Receiver)              Terminal 2 (Sender)
─────────────────────              ─────────────────────
$ node bc_mock.js terima           $ node bc_mock.js kirim --amount 50000

📥 MODE TERIMA                     📤 MODE KIRIM
🌐 Listening : 0.0.0.0:8765       💰 Amount  : Rp 50,000
🛑 Stop      : Ctrl+C             📡 Target  : localhost:8765

📥 TRANSFER DITERIMA!              ✅ TRANSFER BERHASIL!
📋 TX ID  : tx-...                💰 Amount : Rp 50,000
💰 Amount : Rp 50,000
✅ ACK dikirim
```

## Ctrl+C

Kedua mode langsung berhenti dengan `Ctrl+C`, tidak stuck.

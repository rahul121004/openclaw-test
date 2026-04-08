const WebSocket = require('/home/linuxbrew/.linuxbrew/lib/node_modules/openclaw/node_modules/ws');
const fs = require('fs');
const path = require('path');

// Read config to get auth token
const configPath = path.join(process.env.HOME || '/home/deav', '.openclaw', 'openclaw.json');
let authToken = '';
try {
  const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
  authToken = config.gateway?.auth?.token || '';
} catch (e) {
  console.error('Could not read config:', e.message);
  process.exit(1);
}

if (!authToken) {
  console.error('No auth token found in config');
  process.exit(1);
}

const ws = new WebSocket('ws://127.0.0.1:18789/rpc');

ws.on('open', () => {
  console.log('Connected to gateway');
  
  // Authenticate first
  const authMsg = {
    jsonrpc: '2.0',
    id: 0,
    method: 'auth',
    params: { token: authToken }
  };
  ws.send(JSON.stringify(authMsg));
});

let authenticated = false;

ws.on('message', (data) => {
  const msg = JSON.parse(data.toString());
  console.log('Gateway response:', JSON.stringify(msg, null, 2));
  
  // Handle auth challenge
  if (msg.type === 'event' && msg.event === 'connect.challenge') {
    const { nonce, ts } = msg.payload;
    console.log('Received challenge, signing...');
    // Sign the challenge with the token
    const crypto = require('crypto');
    const signature = crypto.createHmac('sha1', authToken).update(nonce + ts).digest('hex');
    console.log('Signature:', signature);
    
    const authResponse = {
      jsonrpc: '2.0',
      id: 0,
      method: 'auth.response',
      params: {
        nonce,
        ts,
        signature
      }
    };
    ws.send(JSON.stringify(authResponse));
    return;
  }
  
  // Check auth result
  if (msg.id === 0 && msg.result) {
    if (msg.result.authenticated) {
      authenticated = true;
      console.log('Authenticated successfully');
      
      // Now initiate the call
      const callMsg = {
        jsonrpc: '2.0',
        id: 1,
        method: 'voicecall.initiate',
        params: {
          to: '+919667116449',
          message: 'Hello, this is a test call from OpenClaw voice-call plugin. This is a mock call for testing purposes.',
          mode: 'conversation'
        }
      };
      ws.send(JSON.stringify(callMsg));
    }
  }
  
  // Handle call result
  if (msg.id === 1) {
    if (msg.result) {
      console.log('\n✅ Call initiated successfully!');
      console.log('Call ID:', msg.result.callId);
    } else if (msg.error) {
      console.log('\n❌ Call failed:', msg.error);
    }
    ws.close();
  }
});

ws.on('error', (err) => {
  console.error('WebSocket error:', err.message);
  process.exit(1);
});

ws.on('close', (code, reason) => {
  console.log('Disconnected:', code, reason?.toString());
  if (!authenticated) {
    console.log('Never authenticated - auth may have failed');
  }
  process.exit(0);
});

// Timeout after 10 seconds
setTimeout(() => {
  console.log('Timeout - closing');
  ws.close();
  process.exit(0);
}, 10000);

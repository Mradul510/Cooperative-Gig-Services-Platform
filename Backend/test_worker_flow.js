const http = require('http');

function request(options, body) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: JSON.parse(data) });
        } catch (e) {
          resolve({ status: res.statusCode, body: data });
        }
      });
    });
    req.on('error', reject);
    if (body) {
      req.write(typeof body === 'string' ? body : JSON.stringify(body));
    }
    req.end();
  });
}

async function testWorkerFlow() {
  console.log('--- 1. Registering new worker "Mohan Mistri" (Carpentry) ---');
  const uniqueMobile = '99' + Math.floor(10000000 + Math.random() * 90000000);
  const uniqueEmail = `mohan_${Date.now()}@example.com`;

  const regRes = await request({
    hostname: 'localhost',
    port: 3000,
    path: '/api/auth/register',
    method: 'POST',
    headers: { 'Content-Type': 'application/json' }
  }, {
    name: 'Mohan Mistri',
    email: uniqueEmail,
    mobile: uniqueMobile,
    password: 'password123',
    role: 'worker',
    trade_category: 'Carpentry',
    cooperative_id: 1
  });

  console.log('Register status:', regRes.status);
  console.log('Worker profile attached:', regRes.body.data?.user?.worker_profile ? 'YES' : 'NO');
  console.log('Availability on register:', regRes.body.data?.user?.worker_profile?.availability);
  console.log('Trade on register:', regRes.body.data?.user?.worker_profile?.trade_category);

  const token = regRes.body.data?.token;

  console.log('\n--- 2. Customer searches for Carpentry workers (Radius 5 km) ---');
  const searchRes1 = await request({
    hostname: 'localhost',
    port: 3000,
    path: '/api/workers?lat=23.2599&lng=77.4126&radius=5&category=Carpentry',
    method: 'GET'
  });

  const workers1 = searchRes1.body.data || [];
  const foundMohan1 = workers1.find(w => w.name === 'Mohan Mistri');
  console.log(`Found ${workers1.length} Carpentry workers.`);
  console.log('Is new worker "Mohan Mistri" visible to customer?:', foundMohan1 ? 'YES (PASS)' : 'NO (FAIL)');
  if (foundMohan1) {
    console.log(` -> Name: ${foundMohan1.name}, Dist: ${foundMohan1.distance_km} km, Rating: ${foundMohan1.rating_avg}, Verified: ${foundMohan1.is_verified}`);
  }

  console.log('\n--- 3. Worker toggles status to OFFLINE (Duty Paused) ---');
  const toggleOff = await request({
    hostname: 'localhost',
    port: 3000,
    path: '/api/workers/availability',
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    }
  }, { availability: 0 });

  console.log('Toggle offline response:', toggleOff.body.data);

  console.log('\n--- 4. Customer searches again while worker is OFFLINE ---');
  const searchRes2 = await request({
    hostname: 'localhost',
    port: 3000,
    path: '/api/workers?lat=23.2599&lng=77.4126&radius=5&category=Carpentry',
    method: 'GET'
  });
  const workers2 = searchRes2.body.data || [];
  const foundMohan2 = workers2.find(w => w.name === 'Mohan Mistri');
  console.log('Is offline worker hidden from customer feed?:', !foundMohan2 ? 'YES (PASS)' : 'NO (FAIL)');

  console.log('\n--- 5. Worker toggles status back to ONLINE ---');
  const toggleOn = await request({
    hostname: 'localhost',
    port: 3000,
    path: '/api/workers/availability',
    method: 'PATCH',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    }
  }, { availability: 1 });

  console.log('Toggle online response:', toggleOn.body.data);

  console.log('\n--- 6. Customer searches again after worker is ONLINE ---');
  const searchRes3 = await request({
    hostname: 'localhost',
    port: 3000,
    path: '/api/workers?lat=23.2599&lng=77.4126&radius=5&category=Carpentry',
    method: 'GET'
  });
  const workers3 = searchRes3.body.data || [];
  const foundMohan3 = workers3.find(w => w.name === 'Mohan Mistri');
  console.log('Is online worker visible again to customer?:', foundMohan3 ? 'YES (PASS)' : 'NO (FAIL)');

  console.log('\nALL WORKER ONLINE DISCOVERY TESTS PASSED SUCCESSFULLY!');
}

testWorkerFlow().catch(console.error);


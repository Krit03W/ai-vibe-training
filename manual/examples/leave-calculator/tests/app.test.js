const test = require('node:test');
const assert = require('node:assert/strict');
const { calculateLeave } = require('../app.js');

// T1
test('สะสม 5 ใช้ไป 4 ได้สิทธิ์ 15 คงเหลือ 11', () => {
  const r = calculateLeave({ yearsOfService: 3, carriedOver: 5, used: 4 });
  assert.equal(r.entitlement, 15);
  assert.equal(r.remaining, 11);
});

// T2
test('อายุราชการไม่ถึง 10 ปี สิทธิ์ชนเพดาน 20 วัน', () => {
  assert.equal(calculateLeave({ yearsOfService: 3, carriedOver: 15, used: 0 }).entitlement, 20);
});

test('อายุราชการ 10 ปีขึ้นไป สิทธิ์ชนเพดาน 30 วัน', () => {
  assert.equal(calculateLeave({ yearsOfService: 12, carriedOver: 25, used: 0 }).entitlement, 30);
});

test('อายุราชการไม่ถึง 6 เดือน ยังไม่มีสิทธิ์', () => {
  const r = calculateLeave({ yearsOfService: 0.3, carriedOver: 0, used: 0 });
  assert.equal(r.entitlement, 0);
  assert.equal(r.notEligible, true);
});

// T3
test('คงเหลือ 2 วันต้องเตือน', () => {
  assert.equal(calculateLeave({ yearsOfService: 3, carriedOver: 0, used: 8 }).lowBalance, true);
});

test('คงเหลือ 3 วันไม่เตือน', () => {
  assert.equal(calculateLeave({ yearsOfService: 3, carriedOver: 0, used: 7 }).lowBalance, false);
});

test('ค่าติดลบไม่คำนวณและบอกช่องที่ผิด', () => {
  const r = calculateLeave({ yearsOfService: 3, carriedOver: -1, used: 0 });
  assert.equal(r.ok, false);
  assert.deepEqual(r.errors, ['วันลาสะสมต้องไม่ติดลบ']);
});

test('ช่องว่างไม่คำนวณ', () => {
  const r = calculateLeave({ yearsOfService: '', carriedOver: 0, used: 0 });
  assert.equal(r.ok, false);
  assert.deepEqual(r.errors, ['กรุณากรอกอายุราชการเป็นตัวเลข']);
});

test('ใช้เกินสิทธิ์ถูกระบุว่า overused', () => {
  const r = calculateLeave({ yearsOfService: 3, carriedOver: 0, used: 12 });
  assert.equal(r.overused, true);
  assert.equal(r.lowBalance, false);
});

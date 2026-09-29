// ตรรกะคำนวณวันลาพักผ่อน แยกจากหน้าเว็บเพื่อให้ทดสอบด้วย node --test ได้
(function (root) {
  const DAYS_PER_YEAR = 10;
  const MIN_YEARS_FOR_LEAVE = 0.5;

  function accumulationCap(yearsOfService) {
    return yearsOfService >= 10 ? 30 : 20;
  }

  function checkNumber(value, label, errors) {
    if (value === '' || value === null || value === undefined || !Number.isFinite(Number(value))) {
      errors.push(`กรุณากรอก${label}เป็นตัวเลข`);
    } else if (Number(value) < 0) {
      errors.push(`${label}ต้องไม่ติดลบ`);
    }
  }

  function calculateLeave({ yearsOfService, carriedOver, used }) {
    const errors = [];
    checkNumber(yearsOfService, 'อายุราชการ', errors);
    checkNumber(carriedOver, 'วันลาสะสม', errors);
    checkNumber(used, 'วันลาที่ใช้ไปแล้ว', errors);
    if (errors.length) return { ok: false, errors };

    const years = Number(yearsOfService);
    if (years < MIN_YEARS_FOR_LEAVE) {
      return { ok: true, entitlement: 0, remaining: 0, notEligible: true, overused: false, lowBalance: false };
    }

    const entitlement = Math.min(DAYS_PER_YEAR + Number(carriedOver), accumulationCap(years));
    const remaining = entitlement - Number(used);
    return {
      ok: true,
      entitlement,
      remaining,
      notEligible: false,
      overused: remaining < 0,
      lowBalance: remaining >= 0 && remaining < 3,
    };
  }

  const api = { DAYS_PER_YEAR, accumulationCap, calculateLeave };
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  else root.LeaveCalc = api;
})(this);

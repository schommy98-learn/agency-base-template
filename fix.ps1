Set-Location "C:\Users\schom\Development\Projects\AgencyBaseTemplate"

Write-Host "=== ADDING TEST SCRIPTS ==="
npm pkg set scripts.test="jest --runInBand"
npm pkg set scripts.test:watch="jest --watch"

Write-Host "`n=== WRITING JEST CONFIG ==="
@'
module.exports = {
  preset: 'jest-expo',
};
'@ | Set-Content -Path "jest.config.js" -Encoding utf8

Write-Host "`n=== ADDING NEUTRAL TEMPLATE SMOKE TEST ==="
New-Item -ItemType Directory -Path "__tests__" -Force | Out-Null

@'
describe('agency base template test environment', () => {
  it('runs Jest successfully', () => {
    expect(1 + 1).toBe(2);
  });
});
'@ | Set-Content -Path "__tests__/template-smoke-test.js" -Encoding utf8

Write-Host "`n=== TESTS ==="
npm test

Write-Host "`n=== TYPESCRIPT ==="
npx tsc --noEmit

Write-Host "`n=== EXPO DEPENDENCIES ==="
npx expo install --check

Write-Host "`n=== EXPO DOCTOR ==="
npx expo-doctor@latest

Write-Host "`n=== PRODUCTION DEPENDENCY AUDIT ==="
npm audit --omit=dev

Write-Host "`n=== UNREVIEWED INSTALL SCRIPTS ==="
npm approve-scripts --allow-scripts-pending
Write-Host "=== NODE VERSION ==="
node --version

Write-Host "`n=== INSTALLED CORE VERSIONS ==="
npm list expo react react-native jest jest-expo @testing-library/react-native react-test-renderer --depth=0

Write-Host "`n=== EXPO DEPENDENCY CHECK ==="
npx expo install --check

Write-Host "`n=== EXPO DOCTOR ==="
npx expo-doctor@latest

Write-Host "`n=== TYPESCRIPT ==="
npx tsc --noEmit

Write-Host "`n=== TESTS ==="
npm test -- --runInBand
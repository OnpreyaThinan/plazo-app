$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$androidDir = Join-Path $repoRoot 'android'
$googleServicesPath = Join-Path $androidDir 'app\google-services.json'
$gradlePropertiesPath = Join-Path $androidDir 'gradle.properties'

if (!(Test-Path $googleServicesPath)) {
  Write-Error "google-services.json not found at $googleServicesPath"
}

if (!(Test-Path $gradlePropertiesPath)) {
  Write-Error "gradle.properties not found at $gradlePropertiesPath"
}

$appIdLine = Get-Content $gradlePropertiesPath | Where-Object { $_ -match '^APP_ID=' } | Select-Object -First 1
if (-not $appIdLine) {
  Write-Error 'APP_ID was not found in android/gradle.properties'
}

$expectedPackageName = ($appIdLine -replace '^APP_ID=', '').Trim()

$javaHomeCandidates = @(
  'C:\Program Files\Android\Android Studio\jbr',
  $env:JAVA_HOME
) | Where-Object { $_ -and (Test-Path $_) }

if ($javaHomeCandidates.Count -gt 0) {
  $env:JAVA_HOME = $javaHomeCandidates[0]
  $env:Path = "$env:JAVA_HOME\bin;$env:Path"
}

Push-Location $androidDir
try {
  $signingReport = & .\gradlew signingReport --console=plain --quiet
} finally {
  Pop-Location
}

$releaseSha1Line = $signingReport | Select-String -Pattern '^SHA1:\s*' | Select-Object -First 2 | Select-Object -Last 1
if (-not $releaseSha1Line) {
  Write-Error 'Could not detect release SHA1 from signingReport output.'
}

$releaseSha1 = ($releaseSha1Line.ToString() -replace '^SHA1:\s*', '').Trim().ToLower().Replace(':', '')

$googleServices = Get-Content $googleServicesPath -Raw | ConvertFrom-Json
$matchingClients = @(
  $googleServices.client |
    Where-Object {
      $_.client_info -and
      $_.client_info.android_client_info -and
      $_.client_info.android_client_info.package_name -eq $expectedPackageName
    }
)

if ($matchingClients.Count -eq 0) {
  Write-Output "Expected package from APP_ID: $expectedPackageName"
  Write-Output 'WARNING: No matching Android client found in google-services.json'
  exit 2
}

$oauthClients = @(
  $matchingClients |
    ForEach-Object { $_.oauth_client }
)
$androidCertificateHashes = @(
  $oauthClients |
    Where-Object { $_.android_info -and $_.android_info.certificate_hash } |
    ForEach-Object { $_.android_info.certificate_hash.ToLower() }
)

Write-Output "Expected package from APP_ID: $expectedPackageName"
Write-Output "Release SHA1 (upload keystore): $releaseSha1"
Write-Output "google-services Android certificate_hash values:"
$androidCertificateHashes | ForEach-Object { Write-Output "- $_" }

if ($androidCertificateHashes -contains $releaseSha1) {
  Write-Output ''
  Write-Output 'OK: Release SHA1 exists in google-services.json'
  exit 0
}

Write-Output ''
Write-Output 'WARNING: Release SHA1 NOT found in google-services.json'
Write-Output 'Action: Add release + Play App Signing SHA fingerprints in Firebase Console, then download a fresh google-services.json'
exit 2

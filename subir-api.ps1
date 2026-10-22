$ErrorActionPreference = "Stop"

# Uma Jwt__SigningKey fornecida explicitamente tem precedência sobre a chave local persistida.
if (-not $env:Jwt__SigningKey) {
    $keyFile = Join-Path $PSScriptRoot ".jwt-signing-key"
    if (-not (Test-Path $keyFile) -or (Get-Item $keyFile).Length -eq 0) {
        $buffer = New-Object byte[] 32
        $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
        $rng.GetBytes($buffer)
        $rng.Dispose()
        [IO.File]::WriteAllText($keyFile, [Convert]::ToBase64String($buffer))
    }
    $env:Jwt__SigningKey = (Get-Content $keyFile -Raw).Trim()
}

$env:ASPNETCORE_URLS = "http://localhost:5050"
if (-not $env:ConnectionStrings__Conduit) {
    $env:ConnectionStrings__Conduit = "Data Source=$(Join-Path $PSScriptRoot 'conduit-local.db')"
}

dotnet run --project (Join-Path $PSScriptRoot "src/Conduit/Conduit.csproj")

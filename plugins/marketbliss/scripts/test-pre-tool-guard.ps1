[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$guard = Join-Path $PSScriptRoot 'pre-tool-guard.ps1'
$workspace = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path

function Invoke-Guard([string]$Json) {
    $output = $Json | & powershell.exe -NoProfile -File $guard
    return ([string]::Join("`n", @($output)) -match '"permissionDecision":"deny"')
}
function Assert-Guard([string]$Name, [string]$Json, [bool]$ExpectedDeny) {
    $actual = Invoke-Guard $Json
    if ($actual -ne $ExpectedDeny) { throw "${Name}: denied=$actual, expected=$ExpectedDeny" }
    Write-Host "PASS: $Name"
}

$campaign = Join-Path $workspace 'output\campaigns\guard-fixture'
$briefPath = Join-Path $campaign 'brief.md'
$briefJson = '{"tool_name":"Write","tool_input":{"file_path":"' + $briefPath.Replace('\', '\\') + '"}}'
try {
    Assert-Guard 'unsealed brief remains editable' $briefJson $false
    New-Item -ItemType Directory -Force -Path (Join-Path $campaign 'decisions') | Out-Null
    New-Item -ItemType File -Force -Path (Join-Path $campaign 'decisions\brief-sealed.md') | Out-Null
    Assert-Guard 'sealed brief is blocked' $briefJson $true
    Assert-Guard 'relative sealed brief is blocked' '{"cwd":"C:\\AiAppDeployments\\MarketBliss","tool_name":"Write","tool_input":{"file_path":"output\\campaigns\\guard-fixture\\brief.md"}}' $true
    Assert-Guard 'ordinary write is allowed' '{"tool_name":"Write","tool_input":{"file_path":"C:\\tmp\\notes.md"}}' $false
    Assert-Guard 'remove-item is blocked' '{"tool_name":"PowerShell","tool_input":{"command":"Remove-Item -Recurse -Force C:\\temp\\demo"}}' $true
    Assert-Guard 'rm-rf is blocked' '{"tool_name":"Bash","tool_input":{"command":"rm -rf /tmp/demo"}}' $true
    Assert-Guard 'rm separated flags is blocked' '{"tool_name":"Bash","tool_input":{"command":"rm -r -f /tmp/demo"}}' $true
    Assert-Guard 'windows rmdir is blocked' '{"tool_name":"PowerShell","tool_input":{"command":"rmdir /s /q C:\\temp\\demo"}}' $true
    Assert-Guard 'powershell alias is blocked' '{"tool_name":"PowerShell","tool_input":{"command":"ri -Recurse -Force C:\\temp\\demo"}}' $true
    Assert-Guard 'hard reset is blocked' '{"tool_name":"Bash","tool_input":{"command":"git reset --hard HEAD"}}' $true
    Assert-Guard 'git clean is blocked' '{"tool_name":"Bash","tool_input":{"command":"git clean -fdx"}}' $true
    Assert-Guard 'evolution without evidence is blocked' '{"tool_name":"mcp__eights__eights_evolution_propose","tool_input":{"resource":"prompt"}}' $true
    Assert-Guard 'evolution with DecisionRecord is allowed' '{"tool_name":"mcp__eights__eights_evolution_propose","tool_input":{"context_ref":"decisionrecord://mb-1"}}' $false
} finally {
    if (Test-Path -LiteralPath $campaign) { Remove-Item -LiteralPath $campaign -Recurse -Force }
}

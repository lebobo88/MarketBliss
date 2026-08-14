[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$inputJson = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($inputJson)) { exit 0 }

try { $event = $inputJson | ConvertFrom-Json } catch { exit 0 }
$tool = [string]$event.tool_name
$toolInput = $event.tool_input
$reason = $null

function Deny([string]$Message) {
    @{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; permissionDecision = 'deny'; permissionDecisionReason = $Message } } |
        ConvertTo-Json -Compress
    exit 0
}

if ($tool -in @('Edit', 'Write')) {
    $path = [string]$toolInput.file_path
    $cwd = if ($event.PSObject.Properties.Name -contains 'cwd') { [string]$event.cwd } else { '' }
    if ([string]::IsNullOrWhiteSpace($cwd)) { $cwd = (Get-Location).Path }
    $normalizedPath = if ([IO.Path]::IsPathRooted($path)) { [IO.Path]::GetFullPath($path) } else { [IO.Path]::GetFullPath((Join-Path $cwd $path)) }
    if ($normalizedPath -match '(^|[\\/])output[\\/]campaigns[\\/][^\\/]+[\\/]brief\.md$') {
        $campaignDir = Split-Path -Parent $normalizedPath
        $seal = Join-Path $campaignDir 'decisions/brief-sealed.md'
        if (Test-Path -LiteralPath $seal) {
            Deny 'Approved campaign briefs are sealed. Create a successor brief and DecisionRecord instead of editing brief.md.'
        }
    }
}

if ($tool -in @('Bash', 'PowerShell')) {
    $command = [string]$toolInput.command
    if ($command -match '(?i)(\brm\s+(?:-[a-z]*r[a-z]*f|-r\s+-f|-f\s+-r)\b|\b(remove-item|ri|rd)\b.*-(recurse|force|r|fo)\b|\b(rmdir|del)\b.*\/(s|q|f)\b|\bgit\s+(reset\s+--hard|checkout\s+--\s+\.|restore\s+\.|clean\s+-[a-z]*f[a-z]*d[a-z]*)\b|\bgit\s+push\s+.*--force\b)') {
        Deny 'Blocked destructive operation. Use a recoverable, explicitly approved workflow.'
    }
}

if ($tool -eq 'mcp__eights__eights_evolution_propose') {
    $serialized = $toolInput | ConvertTo-Json -Depth 10 -Compress
    if ($serialized -notmatch '(?i)decisionrecord|decision_record|hitl') {
        Deny 'Evolution proposals require a DecisionRecord or HITL context reference.'
    }
}

exit 0

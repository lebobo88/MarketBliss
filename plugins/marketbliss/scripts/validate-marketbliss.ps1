[CmdletBinding()]
param(
    [string]$RepositoryRoot,
    [string]$EcosystemRoot,
    [switch]$RequireEcosystem,
    [switch]$Strict
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RepositoryRoot)) {
    $RepositoryRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path
}

if (-not $EcosystemRoot) {
    $EcosystemRoot = Split-Path -Parent $RepositoryRoot
}

$errors = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

function Add-Error([string]$Message) { $script:errors.Add($Message) }
function Add-Warning([string]$Message) { $script:warnings.Add($Message) }
function Require-Path([string]$Path, [string]$Label) {
    if (-not (Test-Path -LiteralPath $Path)) { Add-Error "$Label is missing: $Path"; return $false }
    return $true
}
function Get-Frontmatter([string]$Path) {
    $content = Get-Content -LiteralPath $Path -Raw
    if ($content -notmatch '(?s)^---\s*\r?\n(.*?)\r?\n---') {
        Add-Error "Missing YAML frontmatter: $Path"
        return ''
    }
    return $Matches[1]
}
function Get-ListedSkills([string]$Frontmatter) {
    $lines = $Frontmatter -split "`r?`n"
    $result = [System.Collections.Generic.List[string]]::new()
    $collecting = $false
    foreach ($line in $lines) {
        if ($line -match '^skills:\s*$') { $collecting = $true; continue }
        if ($collecting -and $line -match '^\s+-\s+([a-z0-9-]+)\s*$') { $result.Add($Matches[1]); continue }
        if ($collecting -and $line -match '^\S') { break }
    }
    return $result
}

$pluginRoot = Join-Path $RepositoryRoot 'plugins/marketbliss'
$manifestPath = Join-Path $pluginRoot '.claude-plugin/plugin.json'
$contractPath = Join-Path $pluginRoot 'contracts/ecosystem-dependencies.json'
$hookPath = Join-Path $pluginRoot 'hooks/hooks.json'

Require-Path $manifestPath 'Plugin manifest' | Out-Null
Require-Path $contractPath 'Ecosystem dependency contract' | Out-Null
Require-Path $hookPath 'Plugin hook configuration' | Out-Null

try {
    $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
    if ($manifest.name -ne 'marketbliss') { Add-Error "Plugin manifest name must be 'marketbliss', found '$($manifest.name)'" }
    $hooks = Get-Content -LiteralPath $hookPath -Raw | ConvertFrom-Json
    if ($null -eq $hooks.hooks) { Add-Error 'Plugin hook configuration must contain a hooks object.' }
    $contract = Get-Content -LiteralPath $contractPath -Raw | ConvertFrom-Json
} catch {
    Add-Error "Invalid JSON configuration: $($_.Exception.Message)"
    $contract = $null
}

$agentNames = @{}
Get-ChildItem -LiteralPath (Join-Path $pluginRoot 'agents') -Filter '*.md' -File | ForEach-Object {
    $agentNames[$_.BaseName] = $true
    $frontmatter = Get-Frontmatter $_.FullName
    if ($frontmatter -notmatch "(?m)^name:\s+$([regex]::Escape($_.BaseName))\s*$") {
        Add-Error "Agent name does not match its filename: $($_.FullName)"
    }
}

$skillNames = @{}
Get-ChildItem -LiteralPath (Join-Path $pluginRoot 'skills') -Directory | ForEach-Object {
    $skillPath = Join-Path $_.FullName 'SKILL.md'
    if (-not (Require-Path $skillPath "Skill '$($_.Name)'")) { return }
    $skillNames[$_.Name] = $true
    $frontmatter = Get-Frontmatter $skillPath
    if ($frontmatter -notmatch "(?m)^name:\s+$([regex]::Escape($_.Name))\s*$") {
        Add-Error "Skill name does not match its directory: $skillPath"
    }
}

$rubricNames = @{}
Get-ChildItem -LiteralPath (Join-Path $pluginRoot 'rubrics') -Filter '*@*.md' -File -ErrorAction SilentlyContinue | ForEach-Object {
    $rubricNames[$_.BaseName] = $true
}

$external = @{}
if ($null -ne $contract) {
    foreach ($component in @($contract.external_components)) {
        $external[$component.name] = $component
        $providerPath = Join-Path $EcosystemRoot $component.verification.relative_path
        if (-not (Test-Path -LiteralPath $providerPath)) {
            $message = "External $($component.kind) '$($component.name)' cannot be verified at $providerPath"
            if ($RequireEcosystem) { Add-Error $message } else { Add-Warning $message }
            continue
        }
        $providerContent = Get-Content -LiteralPath $providerPath -Raw
        if ($providerContent -notmatch [regex]::Escape($component.verification.required_pattern)) {
            Add-Error "External $($component.kind) '$($component.name)' is present but does not match its declared provider signature."
        }
    }
}

Get-ChildItem -LiteralPath (Join-Path $pluginRoot 'agents') -Filter '*.md' -File | ForEach-Object {
    $agentFile = $_.BaseName
    Get-ListedSkills (Get-Frontmatter $_.FullName) | ForEach-Object {
        if (-not $skillNames.ContainsKey($_) -and -not $external.ContainsKey($_)) {
            Add-Error "Agent '$agentFile' references an undeclared skill '$_'."
        }
    }
}
Get-ChildItem -LiteralPath (Join-Path $pluginRoot 'commands') -Filter '*.md' -File | ForEach-Object {
    $commandFile = $_.BaseName
    Get-ListedSkills (Get-Frontmatter $_.FullName) | ForEach-Object {
        if (-not $skillNames.ContainsKey($_) -and -not $external.ContainsKey($_)) {
            Add-Error "Command '$commandFile' references an undeclared skill '$_'."
        }
    }
}
$unverifiedRubrics = @{}
Get-ChildItem -LiteralPath (Join-Path $pluginRoot 'teams') -Filter '*.yaml' -File | ForEach-Object {
    $teamPath = $_.FullName
    $teamContent = Get-Content -LiteralPath $teamPath -Raw
    [regex]::Matches($teamContent, 'agent:\s*([a-z0-9-]+)') | ForEach-Object {
        $name = $_.Groups[1].Value
        if (-not $agentNames.ContainsKey($name) -and -not $external.ContainsKey($name)) {
            Add-Error "Team '$([IO.Path]::GetFileName($teamPath))' references an undeclared agent '$name'."
        }
    }
    [regex]::Matches($teamContent, 'rubric:\s*([a-z0-9-]+@[0-9]+)') | ForEach-Object {
        $rubric = $_.Groups[1].Value
        if (-not $rubricNames.ContainsKey($rubric)) {
            $unverifiedRubrics["$([IO.Path]::GetFileName($teamPath))::$rubric"] = $true
        }
    }
}
foreach ($entry in $unverifiedRubrics.Keys | Sort-Object) {
    $parts = $entry -split '::', 2
    Add-Warning "Team '$($parts[0])' declares rubric '$($parts[1])' without a provider contract."
}
if ($RequireEcosystem -and $rubricNames.Count -gt 0) {
    $hydraRegistry = Join-Path $EcosystemRoot 'Hydra/hydra_core/judge/registry.py'
    if (Test-Path -LiteralPath $hydraRegistry) {
        $registryText = Get-Content -LiteralPath $hydraRegistry -Raw
        foreach ($rubric in $rubricNames.Keys | Sort-Object) {
            if ($registryText -notmatch [regex]::Escape($rubric)) {
                Add-Warning "MarketBliss rubric '$rubric' is sourced locally but is not yet registered in Hydra's judge registry; see integrations/hydra-rubric-registry-patch.md."
            }
        }
    }
}

$supervisor = Join-Path $pluginRoot 'agents/marketing-supervisor.md'
if (Test-Path -LiteralPath $supervisor) {
    $supervisorContent = Get-Content -LiteralPath $supervisor -Raw
    if ($supervisorContent -match '(?i)4 MarketBliss squads|11 specialist agents') {
        Add-Warning 'Marketing supervisor roster language is stale: the contract declares five squads and fifteen total agents.'
    }
}

$strategySquad = Join-Path $RepositoryRoot 'squads/marketing-strategy/squad.yaml'
if (Test-Path -LiteralPath $strategySquad) {
    $strategyContent = Get-Content -LiteralPath $strategySquad -Raw
    if ($strategyContent -match 'brief-\{date\}\.md') {
        Add-Warning 'Marketing strategy squad output path differs from the sealed canonical brief path output/campaigns/<campaign-id>/brief.md.'
    }
}

foreach ($message in $warnings) { Write-Host "WARNING: $message" -ForegroundColor Yellow }
foreach ($message in $errors) { Write-Host "ERROR: $message" -ForegroundColor Red }
if ($Strict -and $warnings.Count -gt 0) { $errors.Add('Strict mode treats warnings as failures.') }
if ($errors.Count -gt 0) { Write-Host "MarketBliss validation failed with $($errors.Count) error(s)." -ForegroundColor Red; exit 1 }
Write-Host "MarketBliss validation passed with $($warnings.Count) warning(s)." -ForegroundColor Green
exit 0

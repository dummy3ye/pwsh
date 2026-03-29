function Manage-OhMyPoshThemes {
    param (
        [switch]$ApplyImmediately
    )

    # The local folder for saved themes
    $themesDir = "$env:USERPROFILE\pwsh\oh-my-posh\themes"
    if (-not (Test-Path $themesDir)) { New-Item -ItemType Directory -Path $themesDir | Out-Null }

    # GitHub base for raw theme downloads
    $repoOwner = "JanDeDobbeleer"
    $repoName  = "oh-my-posh"
    $branch    = "main"
    $baseRaw   = "https://raw.githubusercontent.com/$repoOwner/$repoName/$branch/themes"

    # Manually list some known themes
    $themes = @(
        "1_shell.omp.json"; "M365Princess.omp.json"; "agnoster.omp.json";
        "aliens.omp.json"; "atomic.omp.json"; "blueish.omp.json";
        "cinnamon.omp.json"; "clean-detailed.omp.json"; "cloud-context.omp.json";
        "powerline.omp.json"; "tokyonight_storm.omp.json"; "zash.omp.json";
        "jandedobbeleer.omp.json" # and many more…
    )

    # Prepare display list
    $display = $themes | ForEach-Object {
        $installed = if (Test-Path (Join-Path $themesDir $_)) { "[INSTALLED]" } else { "" }
        "$($_) $installed"
    }

    # Let user pick with fzf or fallback
    if (Get-Command fzf -ErrorAction SilentlyContinue) {
        $selectedLine = $display | fzf --prompt "Choose a theme > "
    } else {
        $display | ForEach-Object { Write-Host $_ }
        $input = Read-Host "Enter theme name"
        $selectedLine = $input
    }

    if (-not $selectedLine) { Write-Warning "No theme selected."; return }

    $selected = ($selectedLine -split "\s")[0]
    $localFile = Join-Path $themesDir $selected
    $downloadUrl = "$baseRaw/$selected"

    # Download if not present
    if (-not (Test-Path $localFile)) {
        try {
            Invoke-WebRequest -Uri $downloadUrl -OutFile $localFile -UseBasicParsing
            Write-Host "Downloaded $selected"
        } catch {
            Write-Warning "Failed to download theme: $downloadUrl"
            return
        }
    } else {
        Write-Host "$selected already installed"
    }

    # Apply immediately
    if ($ApplyImmediately -and (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Remove-Item function:prompt -ErrorAction SilentlyContinue
        oh-my-posh init pwsh --config $localFile | Invoke-Expression
        Write-Host "Applied $selected"
    }

    # Save to profile (default Yes)
    $ans = Read-Host "Save in profile? (y/n) [Y]"
    if ([string]::IsNullOrWhiteSpace($ans)) { $ans = "y" }
    if ($ans -match "^[Yy]") {
        $content = Get-Content $PROFILE -Raw
        $newLine = "oh-my-posh init pwsh --config `"$localFile`" | Invoke-Expression"
        if ($content -match "oh-my-posh init pwsh") {
            $content = $content -replace "oh-my-posh init pwsh.*", $newLine
        } else {
            $content += "`n$newLine"
        }
        Set-Content $PROFILE -Value $content -Force
        Write-Host "Saved to profile"
    }
}
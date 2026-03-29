function Theme {
    $themesDir = "$env:USERPROFILE\pwsh\oh-my-posh\themes"

    if (-not (Test-Path $themesDir)) {
        Write-Warning "Themes folder not found: $themesDir"
        return
    }

    $themes = Get-ChildItem $themesDir -Filter *.omp.json | Select-Object -ExpandProperty Name
    if (-not $themes) { Write-Warning "No themes found."; return }

    # Theme selection
    if (Get-Command fzf -ErrorAction SilentlyContinue) {
        $selectedTheme = $themes | fzf --prompt "Select Oh-My-Posh theme > "
    } else {
        Write-Host "Available themes:"
        $themes | ForEach-Object { Write-Host "$($_)" }
        $selectedTheme = Read-Host "Type theme filename to use"
    }

    if (-not $selectedTheme) { Write-Warning "No theme selected."; return }

    $themePath = Join-Path $themesDir $selectedTheme

    # Apply theme immediately
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        Remove-Item function:prompt -ErrorAction SilentlyContinue
        oh-my-posh init pwsh --config $themePath | Invoke-Expression
        Write-Host "Theme switched to '$selectedTheme'."
    } else {
        Write-Warning "Oh-My-Posh not found! Install with: winget install JanDeDobbeleer.OhMyPosh -e"
        return
    }

    # Ask if user wants to make permanent
    $answer = Read-Host "Make this theme permanent in your profile? (y/n) [Y]"
    if ([string]::IsNullOrWhiteSpace($answer)) { $answer = "y" }
    if ($answer -match "^[Yy]") {
        $profilePath = $PROFILE
        if (-not (Test-Path $profilePath)) { New-Item -ItemType File -Path $profilePath -Force }

        $profileContent = Get-Content $profilePath -Raw

        $newLine = "oh-my-posh init pwsh --config `"$themePath`" | Invoke-Expression"

        if ($profileContent -match "oh-my-posh init pwsh") {
            # Replace existing line
            $profileContent = $profileContent -replace "oh-my-posh init pwsh.*", $newLine
        } else {
            # Append new line
            $profileContent += "`n$newLine"
        }

        Set-Content $profilePath -Value $profileContent -Force
        Write-Host "Theme saved to $PROFILE. Next session will use '$selectedTheme'."
    }
}
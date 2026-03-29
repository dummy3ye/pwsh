function Manage-OhMyPoshThemes {
    param (
        [switch]$ApplyImmediately
    )

    # The local folder for downloads
    $themesDir = "$env:USERPROFILE\pwsh\oh-my-posh\themes"
    if (-not (Test-Path $themesDir)) { New-Item -ItemType Directory -Path $themesDir | Out-Null }

    # GitHub base
    $repoOwner = "JanDeDobbeleer"
    $repoName  = "oh-my-posh"
    $branch    = "main"
    $baseRaw   = "https://raw.githubusercontent.com/$repoOwner/$repoName/$branch/themes"

    # all themes available in JanDeDobbleer's github
    $themes = @(
    "1_shell.omp.json"; "M365Princess.omp.json"; "agnoster.minimal.omp.json";
    "agnoster.omp.json"; "agnosterplus.omp.json"; "aliens.omp.json";
    "amro.omp.json"; "atomic.omp.json"; "atomicBit.omp.json";
    "avit.omp.json"; "blue-owl.omp.json"; "blueish.omp.json";
    "bubbles.omp.json"; "bubblesextra.omp.json"; "bubblesline.omp.json";
    "capr4n.omp.json"; "catppuccin.omp.json"; "catppuccin_frappe.omp.json";
    "catppuccin_latte.omp.json"; "catppuccin_macchiato.omp.json"; "catppuccin_mocha.omp.json";
    "cert.omp.json"; "chips.omp.json"; "cinnamon.omp.json";
    "clean-detailed.omp.json"; "cloud-context.omp.json"; "cloud-native-azure.omp.json";
    "cobalt2.omp.json"; "craver.omp.json"; "darkblood.omp.json";
    "devious-diamonds.omp.json"; "di4am0nd.omp.json"; "dracula.omp.json";
    "easy-term.omp.json"; "emodipt-extend.omp.json"; "emodipt.omp.json";
    "fish.omp.json"; "free-ukraine.omp.json"; "froczh.omp.json";
    "glowsticks.omp.json"; "gmay.omp.json"; "grandpa-style.omp.json";
    "gruvbox.omp.json"; "half-life.omp.json"; "honukai.omp.json";
    "hotstick.minimal.omp.json"; "hul10.omp.json"; "hunk.omp.json";
    "huvix.omp.json"; "if_tea.omp.json"; "illusi0n.omp.json";
    "iterm2.omp.json"; "jandedobbeleer.omp.json"; "jblab_2021.omp.json";
    "jonnychipz.omp.json"; "json.omp.json"; "jtracey93.omp.json";
    "jv_sitecorian.omp.json"; "kali.omp.json"; "kushal.omp.json";
    "lambda.omp.json"; "lambdageneration.omp.json"; "larserikfinholt.omp.json";
    "lightgreen.omp.json"; "marcduiker.omp.json"; "markbull.omp.json";
    "material.omp.json"; "microverse-power.omp.json"; "mojada.omp.json";
    "montys.omp.json"; "mt.omp.json"; "multiverse-neon.omp.json";
    "negligible.omp.json"; "neko.omp.json"; "night-owl.omp.json";
    "nordtron.omp.json"; "nu4a.omp.json"; "onehalf.minimal.omp.json";
    "paradox.omp.json"; "pararussel.omp.json"; "patriksvensson.omp.json";
    "peru.omp.json"; "pixelrobots.omp.json"; "plague.omp.json";
    "poshmon.omp.json"; "powerlevel10k_classic.omp.json"; "powerlevel10k_lean.omp.json";
    "powerlevel10k_modern.omp.json"; "powerlevel10k_rainbow.omp.json"; "powerline.omp.json";
    "probua.minimal.omp.json"; "pure.omp.json"; "quick-term.omp.json";
    "remk.omp.json"; "robbyrussell.omp.json"; "rudolfs-dark.omp.json";
    "rudolfs-light.omp.json"; "sim-web.omp.json"; "slim.omp.json";
    "slimfat.omp.json"; "smoothie.omp.json"; "sonicboom_dark.omp.json";
    "sonicboom_light.omp.json"; "sorin.omp.json"; "space.omp.json";
    "spaceship.omp.json"; "star.omp.json"; "stelbent-compact.minimal.omp.json";
    "stelbent.minimal.omp.json"; "takuya.omp.json"; "the-unnamed.omp.json";
    "thecyberden.omp.json"; "tiwahu.omp.json"; "tokyo.omp.json";
    "tokyonight_storm.omp.json"; "tonybaloney.omp.json"; "uew.omp.json";
    "unicorn.omp.json"; "velvet.omp.json"; "wholespace.omp.json";
    "wopian.omp.json"; "xtoys.omp.json"; "ys.omp.json";
    "zash.omp.json"
    )

    # Prepare display list
    $display = $themes | ForEach-Object {
        $installed = if (Test-Path (Join-Path $themesDir $_)) { "[INSTALLED]" } else { "" }
        "$($_) $installed"
    }

    # fzf picker
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

    # downloading
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

    # Applying
    if ($ApplyImmediately -and (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Remove-Item function:prompt -ErrorAction SilentlyContinue
        oh-my-posh init pwsh --config $localFile | Invoke-Expression
        Write-Host "Applied $selected"
    }

    # Saving in $PROFILE
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
# Oh My Posh theme switcher
$themeSwitcher = "$env:USERPROFILE\pwsh\oh-my-posh\theme-switcher.ps1"
if (Test-Path $themeSwitcher) { . $themeSwitcher }
# Oh My Posh theme installer
$themeManager = "$env:USERPROFILE\pwsh\oh-my-posh\theme-manager.ps1"
if (Test-Path $themeManager) { . $themeManager }

# Oh My Posh init default theme
$defaultTheme = "$env:USERPROFILE\pwsh\oh-my-posh\themes\kushal.omp.json"
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "C:\Users\ASUS\pwsh\oh-my-posh\themes\kushal.omp.json" | Invoke-Expression
}

# Enable modern prediction (like IntelliSense)
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle InlineView
# InlineView or ListView (dropdown style)


# History behavior
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -MaximumHistoryCount 50

# Better editing mode (Windows default is kinda ....ok)
Set-PSReadLineOption -EditMode Windows
# or:
# Set-PSReadLineOption -EditMode Emacs
# Set-PSReadLineOption -EditMode Vi

Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
# Bell (disable annoying beep)
Set-PSReadLineOption -BellStyle None
#copy and paste things
Set-PSReadLineKeyHandler -Key Ctrl+v -Function Paste
Set-PSReadLineKeyHandler -Key Ctrl+c -Function Copy

function p {
    clear @args
}

function yz {
    <#
    .SYNOPSIS
        Launches Yazi
    .DESCRIPTION
        Opens Yazi in the current directory or a specified path.
    .EXAMPLE
        yz ..
    #>
    $yaziPath = Get-Command yazi -ErrorAction SilentlyContinue

    if ($yaziPath) {
        & yazi.exe @args
    }
    else {
        Write-Warning "Yazi is not installed in correct PATH. Try: 'winget install sxyazi.yazi'"
    }
}

function subl {
    <#
    .SYNOPSIS
        Opens files or directories in Sublime Text.
    .DESCRIPTION
        Checks for the executable in the default installation path 
        and launches it with passed arguments.
    .EXAMPLE
        subl .
    .EXAMPLE
        sublime index.html
    #>
    $sublimePath = "C:\Program Files\Sublime Text\subl.exe"
    
    if (Test-Path $sublimePath) {
        & $sublimePath @args
    }
    else {
        Write-Warning "Sublime Text not found at $sublimePath"
    }
}

function sublime {
    subl @args
}

if (Get-Command fzf -ErrorAction SilentlyContinue) {
    Set-PSReadLineKeyHandler -Chord Ctrl+r -ScriptBlock {
        $history = Get-History | Select-Object -ExpandProperty CommandLine | Sort-Object -Descending
        $selected = $history | fzf --tac
        if ($selected) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert($selected)
        }
    }
}
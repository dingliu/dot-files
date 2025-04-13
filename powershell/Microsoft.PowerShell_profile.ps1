# This is the PowerShell profile script that runs every time a new PowerShell session is started.
# It sets up the environment for PowerShell, including loading modules and configuring the prompt.

########################################################################
# Aliases
########################################################################
## ================ Git ================
# ====================================================================
# IMPORTANT:
# 1. These replace Zsh aliases with PowerShell functions because aliases
#    in PowerShell cannot directly include arguments.
# 2. PowerShell function names are CASE-INSENSITIVE. Aliases differing
#    only by case (e.g., gcb vs gcB) have been renamed to avoid conflicts.
# 3. Place this entire block into your PowerShell profile script ($PROFILE).
# 4. Restart PowerShell or run ". $PROFILE" to load these functions.
# ====================================================================
# --- Helper Functions ---

function Get-GitCurrentBranch {
    <#
    .SYNOPSIS
    Gets the current Git branch name. Equivalent to Oh My Zsh's git_current_branch.
    #>
    try {
        $branchName = git rev-parse --abbrev-ref HEAD 2>$null
        if ($LASTEXITCODE -eq 0 -and $branchName -ne 'HEAD') {
            return $branchName.Trim()
        } else {
            # Handle detached HEAD state or error
            Write-Warning "Could not determine current branch or in detached HEAD state."
            return $null
        }
    } catch {
        Write-Warning "Error running git command: $_"
        return $null
    }
}

function Get-GitMainBranch {
    <#
    .SYNOPSIS
    Attempts to determine the main branch name (main or master). Equivalent to Oh My Zsh's git_main_branch.
    #>
    try {
        # Best Method: Check remote's default branch (if origin exists)
        $remoteHeadRef = git symbolic-ref refs/remotes/origin/HEAD 2>$null
        if ($LASTEXITCODE -eq 0 -and $remoteHeadRef) {
            return ($remoteHeadRef -replace "refs/remotes/origin/", "").Trim()
        }

        # Fallback: Check common local branch names
        $localBranches = git branch --list 'main', 'master' --format '%(refname:short)'
        if ($localBranches -contains 'main') { return 'main' }
        if ($localBranches -contains 'master') { return 'master' }

        # Last resort fallback
        Write-Warning "Could not reliably determine main branch. Assuming 'main'. Adjust Get-GitMainBranch function if needed."
        return "main"
    } catch {
        Write-Warning "Error running git command: $_. Assuming 'main'."
        return "main"
    }
}

# --- Git Branch Functions (gb*) ---

# gb='git branch'
function gb { git branch @args }

# gba='git branch --all'
function gba { git branch --all @args }

# gbd='git branch --delete'
function gbd { git branch --delete @args }

# gbD='git branch --delete --force' -> Renamed due to case-insensitivity
function gbfd { git branch --delete --force @args } # Renamed from gbD

# gbm='git branch --move'
function gbm { git branch --move @args }

# gbnm='git branch --no-merged'
function gbnm { git branch --no-merged @args }

# gbr='git branch --remote'
function gbr { git branch --remote @args }


# --- Git Checkout Functions (gc*) ---

# gco='git checkout'
function gco { git checkout @args }

# gcor='git checkout --recurse-submodules'
function gcor { git checkout --recurse-submodules @args }

# gcb='git checkout -b'
function gcb { git checkout -b @args }

# gcB='git checkout -B' -> Renamed due to case-insensitivity
function gcbForce { git checkout -B @args } # Renamed from gcB

# gcm='git checkout $(git_main_branch)'
function gcm { git checkout (Get-GitMainBranch) @args }

# gcp='git cherry-pick'
function gcp { git cherry-pick @args }

# gcpa='git cherry-pick --abort'
function gcpa { git cherry-pick --abort @args }

# gcpc='git cherry-pick --continue'
function gcpc { git cherry-pick --continue @args }


# --- Git Clean Functions ---

# gclean='git clean --interactive -d'
function gclean { git clean --interactive -d @args }


# --- Git Clone Functions ---

# gcl='git clone --recurse-submodules'
function gcl { git clone --recurse-submodules @args }


# --- Git Commit Functions (gc*, gca*, gcs*) ---

# gc='git commit --verbose'
function gc { git commit --verbose @args }

# gca='git commit --verbose --all'
function gca { git commit --verbose --all @args }

# gca!='git commit --verbose --all --amend' -> Renamed
function gcaAmend { git commit --verbose --all --amend @args } # Renamed from gca!

# gcan!='git commit --verbose --all --no-edit --amend' -> Renamed
function gcaNoEditAmend { git commit --verbose --all --no-edit --amend @args } # Renamed from gcan!

# gcans!='git commit --verbose --all --signoff --no-edit --amend' -> Renamed
function gcaSignoffNoEditAmend { git commit --verbose --all --signoff --no-edit --amend @args } # Renamed from gcans!

# gcann!='git commit --verbose --all --date=now --no-edit --amend' -> Renamed
# Note: Git handles '--date=now' internally
function gcaDateNowNoEditAmend { git commit --verbose --all --date=now --no-edit --amend @args } # Renamed from gcann!

# gc!='git commit --verbose --amend' -> Renamed
function gcAmend { git commit --verbose --amend @args } # Renamed from gc!

# gcn='git commit --verbose --no-edit'
function gcn { git commit --verbose --no-edit @args }

# gcn!='git commit --verbose --no-edit --amend' -> Renamed
function gcNoEditAmend { git commit --verbose --no-edit --amend @args } # Renamed from gcn!

# gcam='git commit --all --message'
function gcam { git commit --all --message @args }

# gcas='git commit --all --signoff'
function gcas { git commit --all --signoff @args }

# gcasm='git commit --all --signoff --message'
function gcasm { git commit --all --signoff --message @args }

# gcs='git commit --gpg-sign'
function gcs { git commit --gpg-sign @args }

# gcss='git commit --gpg-sign --signoff' -> Renamed
function gcsSignoff { git commit --gpg-sign --signoff @args } # Renamed from gcss

# gcssm='git commit --gpg-sign --signoff --message' -> Renamed
function gcsSignoffMessage { git commit --gpg-sign --signoff --message @args } # Renamed from gcssm

# gcmsg='git commit --message'
function gcmsg { git commit --message @args }

# gcsm='git commit --signoff --message'
function gcsm { git commit --signoff --message @args }


# --- Git Config Functions ---

# gcf='git config --list'
function gcf { git config --list @args }


# --- Git Describe Functions ---

# gdct='git describe --tags $(git rev-list --tags --max-count=1)'
function gdct { git describe --tags (git rev-list --tags --max-count=1) @args }


# --- Git Diff Functions (gd*) ---

# gd='git diff'
function gd { git diff @args }

# gdca='git diff --cached'
function gdca { git diff --cached @args }

# gdcw='git diff --cached --word-diff'
function gdcw { git diff --cached --word-diff @args }

# gds='git diff --staged'
function gds { git diff --staged @args } # Equivalent to --cached

# gdw='git diff --word-diff'
function gdw { git diff --word-diff @args }

# gdup='git diff @{upstream}'
function gdup { git diff '@{upstream}' @args } # Quote the refspec


# --- Git Fetch Functions (gf*) ---

# gf='git fetch'
function gf { git fetch @args }

# gfa='git fetch --all --tags --prune --jobs=10'
function gfa { git fetch --all --tags --prune --jobs=10 @args }

# gfo='git fetch origin'
function gfo { git fetch origin @args }


# --- Git Help Functions ---

# ghh='git help'
function ghh { git help @args }


# --- Git Merge Functions (gm*) ---

# gm='git merge'
function gm { git merge @args }

# gma='git merge --abort'
function gma { git merge --abort @args }

# gmc='git merge --continue'
function gmc { git merge --continue @args }

# gms="git merge --squash"
function gms { git merge --squash @args }

# gmff="git merge --ff-only"
function gmff { git merge --ff-only @args }

# gmtl='git mergetool --no-prompt'
function gmtl { git mergetool --no-prompt @args }

# gmtlvim='git mergetool --no-prompt --tool=vimdiff'
function gmtlvim { git mergetool --no-prompt --tool=vimdiff @args }


# --- Git Pull Functions (gl, gp*) ---

# gl='git pull'
function gl { git pull @args }

# gpr='git pull --rebase'
function gpr { git pull --rebase @args }

# gprv='git pull --rebase -v'
function gprv { git pull --rebase -v @args }

# gpra='git pull --rebase --autostash'
function gpra { git pull --rebase --autostash @args }

# gprav='git pull --rebase --autostash -v'
function gprav { git pull --rebase --autostash -v @args }

# gprom='git pull --rebase origin $(git_main_branch)'
function gprom { git pull --rebase origin (Get-GitMainBranch) @args }

# gpromi='git pull --rebase=interactive origin $(git_main_branch)'
function gpromi { git pull --rebase=interactive origin (Get-GitMainBranch) @args }

# gprum='git pull --rebase upstream $(git_main_branch)'
function gprum { git pull --rebase upstream (Get-GitMainBranch) @args }

# gprumi='git pull --rebase=interactive upstream $(git_main_branch)'
function gprumi { git pull --rebase=interactive upstream (Get-GitMainBranch) @args }

# ggpull='git pull origin "$(git_current_branch)"'
function ggpull {
    $currentBranch = Get-GitCurrentBranch
    if ($currentBranch) { git pull origin $currentBranch @args }
}


# --- Git Push Functions (gp*) ---

# gp='git push'
function gp { git push @args }

# gpd='git push --dry-run'
function gpd { git push --dry-run @args }

# Note: The Zsh list has two gpf definitions. The last one takes precedence.
# gpf!='git push --force' # This one is effectively ignored/overwritten
# gpf='git push --force-with-lease --force-if-includes' -> This is the effective gpf
function gpf { git push --force-with-lease --force-if-includes @args }
# Optional: If you want the old --force behavior, define it with a different name:
# function gpfForce { git push --force @args }

# gpsup='git push --set-upstream origin $(git_current_branch)'
function gpsup {
    $currentBranch = Get-GitCurrentBranch
    if ($currentBranch) { git push --set-upstream origin $currentBranch @args }
}

# gpsupf='git push --set-upstream origin $(git_current_branch) --force-with-lease --force-if-includes' -> Renamed
function gpsupForce { # Renamed from gpsupf
    $currentBranch = Get-GitCurrentBranch
    if ($currentBranch) { git push --set-upstream origin $currentBranch --force-with-lease --force-if-includes @args }
}

# gpv='git push --verbose'
function gpv { git push --verbose @args }

# gpoat='git push origin --all && git push origin --tags'
function gpoat {
    # Uses PowerShell chaining (&& requires success of first command)
    git push origin --all && git push origin --tags
    # Note: @args doesn't typically apply to this fixed sequence
}

# gpod='git push origin --delete'
function gpod { git push origin --delete @args }

# ggpush='git push origin "$(git_current_branch)"'
function ggpush {
    $currentBranch = Get-GitCurrentBranch
    if ($currentBranch) { git push origin $currentBranch @args }
}


# --- Git Rebase Functions (grb*) ---

# grb='git rebase'
function grb { git rebase @args }

# grba='git rebase --abort'
function grba { git rebase --abort @args }

# grbc='git rebase --continue'
function grbc { git rebase --continue @args }

# grbi='git rebase --interactive'
function grbi { git rebase --interactive @args }

# grbo='git rebase --onto'
function grbo { git rebase --onto @args }

# grbs='git rebase --skip'
function grbs { git rebase --skip @args }

# grbm='git rebase $(git_main_branch)'
function grbm { git rebase (Get-GitMainBranch) @args }


# --- Git Remote Functions (gr*) ---

# gr='git remote'
function gr { git remote @args }

# grv='git remote --verbose'
function grv { git remote --verbose @args }

# gra='git remote add'
function gra { git remote add @args }

# grrm='git remote remove'
function grrm { git remote remove @args }

# grmv='git remote rename'
function grmv { git remote rename @args }

# grset='git remote set-url'
function grset { git remote set-url @args }

# grup='git remote update'
function grup { git remote update @args }


# --- Git Reset Functions (grh*, gru*) ---

# grh='git reset'
function grh { git reset @args }

# gru='git reset --'
# Note: The '--' is typically used to separate options from paths.
# This function ensures it's present, useful if you alias 'git reset' itself.
function gru { git reset -- @args }

# grhh='git reset --hard'
function grhh { git reset --hard @args }

# grhk='git reset --keep'
function grhk { git reset --keep @args }

# grhs='git reset --soft'
function grhs { git reset --soft @args }

# gpristine='git reset --hard && git clean --force -dfx'
function gpristine {
    git reset --hard && git clean --force -dfx
    # Note: @args doesn't typically apply to this fixed sequence
}


# --- Git Revert Functions (grev*) ---

# grev='git revert'
function grev { git revert @args }

# greva='git revert --abort'
function greva { git revert --abort @args }

# grevc='git revert --continue'
function grevc { git revert --continue @args }


# --- Git Remove Functions (grm*) ---

# grm='git rm'
function grm { git rm @args }

# grmc='git rm --cached'
function grmc { git rm --cached @args }


# --- Git Show Functions (gsh*, gsps*) ---

# gsh='git show'
function gsh { git show @args }

# gsps='git show --pretty=short --show-signature'
function gsps { git show --pretty=short --show-signature @args }


# --- Git Stash Functions (gst*) ---

# gstall='git stash --all'
function gstall { git stash --all @args }

# gstaa='git stash apply'
function gstaa { git stash apply @args }

# gstc='git stash clear'
function gstc { git stash clear @args }

# gstd='git stash drop'
function gstd { git stash drop @args }

# gstl='git stash list'
function gstl { git stash list @args }

# gstp='git stash pop'
function gstp { git stash pop @args }

# gsta='git stash push'
function gsta { git stash push @args }

# gsts='git stash show --patch'
function gsts { git stash show --patch @args }


# --- Git Status Functions (gst*, gss*, gsb*) ---

# gst='git status'
function gst { git status @args }

# gss='git status --short'
function gss { git status --short @args }

# gsb='git status --short --branch'
function gsb { git status --short --branch @args }


# --- Git Tag Functions (gt*) ---

# gta='git tag --annotate'
function gta { git tag --annotate @args }

# gts='git tag --sign'
function gts { git tag --sign @args }


# --- Git Worktree Functions (gwt*) ---

# gwt='git worktree'
function gwt { git worktree @args }

# gwta='git worktree add'
function gwta { git worktree add @args }

# gwtls='git worktree list'
function gwtls { git worktree list @args }

# gwtmv='git worktree move'
function gwtmv { git worktree move @args }

# gwtrm='git worktree remove'
function gwtrm { git worktree remove @args }

# ====================================================================
# End of PowerShell Git Functions
# ====================================================================


# Initialize oh-my-posh
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/negligible.omp.json" | Invoke-Expression

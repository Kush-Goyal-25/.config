# ────────────────────────────────────────────────
# Nushell Config - Clean & Organized (2026 style)
# ────────────────────────────────────────────────

# Show less banner noise
$env.config.show_banner = false

# Use vi keybindings everywhere
$env.config = {
    edit_mode: vi

    keybindings: [
        {
            name: run_ans
            modifier: control
            keycode: char_f
            mode: [emacs, vi_normal, vi_insert]
            event: { send: executehostcommand, cmd: "ans" }
        }
    ]
}

# ────────────────────────────────────────────────
# PATH additions
# ────────────────────────────────────────────────

# Add ~/.local/bin if not present
if not ($env.PATH | any { |it| $it == $"($env.HOME)/.local/bin" }) {
    $env.PATH = ($env.PATH | append $"($env.HOME)/.local/bin")
}

# Add ~/.cargo/bin (for rust tools like uv, cargo, etc.)
if not ($env.PATH | any { |it| $it == $"($env.HOME)/.cargo/bin" }) {
    $env.PATH = ($env.PATH | append $"($env.HOME)/.cargo/bin")
}

# ────────────────────────────────────────────────
# Editor & visual tools
# ────────────────────────────────────────────────

$env.EDITOR  = "nvim"
$env.VISUAL  = "nvim"
$env.BAT_THEME = "GitHub"

# ────────────────────────────────────────────────
# Custom commands
# ────────────────────────────────────────────────

# Run tmux-sessionizer if it exists
def ans [] {
    let path = $"($env.HOME)/.local/bin/tmux-sessionizer"
    if ($path | path exists) {
        ^$path
    } else {
        print $"Error: tmux-sessionizer not found at ($path)"
    }
}

# Compile + run C++ file (your cr alias)
def cr [file: string] {
    g++ -std=c++17 -Wall $file -o out
    if $env.LAST_EXIT_CODE == 0 {
        ./out
    } else {
        print "Compilation failed"
    }
}

def ratemirrors [] {
     rate-mirrors --protocol https arch | sudo tee /etc/pacman.d/mirrorlist
}

# ────────────────────────────────────────────────
# Aliases (grouped for clarity)
# ────────────────────────────────────────────────

# File listing
alias l  = ls --all
alias ll = ls -l
alias la = ls --all --long

# Navigation
alias ..   = cd ..
alias ...  = cd ../..
alias .... = cd ../../..

# Neovim & exit
alias v = nvim
alias e = exit
alias c = clear

# Tmux
alias a     = tmux a
alias new   = tmux new -s
alias tmux-reload = ^tmux source-file ~/.config/tmux/tmux.conf

# Git
alias gst   = git status
alias gco   = git checkout
alias gdiff = git diff
alias gadd  = git add
alias gp    = git push origin HEAD
alias gpu   = git pull origin
alias gb    = git branch
alias glog  = git log --graph --pretty="%C(yellow)%h%C(reset) %s %C(dim white)- %an, %ar%C(reset)"
alias gr    = git remote -v

# Pacman & Yay
alias pacs    = sudo pacman -S
alias pacss   = pacman -Ss
alias pacq    = pacman -Q | grep
alias pacu    = sudo pacman -Syu
alias yays    = yay -S
alias yayss   = yay -Ss
alias yayu    = yay -Syu
alias pacclean = sudo pacman -Rns (pacman -Qtdq)

# Systemd
alias jc = journalctl -xe

# fzf helpers
alias fe = fzf-edit
alias fh = fzf-history

# ────────────────────────────────────────────────
# Starship prompt (if you use it)
# ────────────────────────────────────────────────

source ~/.cache/starship/init.nu

source ~/.config/nushell/cses.nu
source ~/.config/nushell/cses.nu
# ────────────────────────────────────────────────
# Oh My Zsh
# ────────────────────────────────────────────────

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
bindkey -v
source $ZSH/oh-my-zsh.sh

# ────────────────────────────────────────────────
# PATH additions
# ────────────────────────────────────────────────

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.npm-global/bin:$HOME/go/bin:$PATH"

# ────────────────────────────────────────────────
# Environment variables
# ────────────────────────────────────────────────

export EDITOR="nvim"
export VISUAL="nvim"
export BAT_THEME="GitHub"

# Fix for GBM buffer errors with WebKitGTK apps (Excalidraw, etc.) on NVIDIA
export WEBKIT_DISABLE_DMABUF_RENDERER="1"
export WEBKIT_DISABLE_COMPOSITING_MODE="1"


# ────────────────────────────────────────────────
# History
# ────────────────────────────────────────────────

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# ────────────────────────────────────────────────
# Vi mode
# ────────────────────────────────────────────────

bindkey -v
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
# ────────────────────────────────────────────────
# Keybindings
# ────────────────────────────────────────────────

# Ctrl+F → run tmux-sessionizer
bindkey -s '^f' 'bash ~/.local/bin/tmux-sessionizer\n'


# ────────────────────────────────────────────────
# Custom functions
# ────────────────────────────────────────────────

# Run tmux-sessionizer
ans() {
    local path="$HOME/.local/bin/tmux-sessionizer"
    if [[ -x "$path" ]]; then
        bash "$path"
    else
        echo "Error: tmux-sessionizer not found at $path"
    fi
}

# Change cursor shape for vi modes
function zle-keymap-select {
    if [[ $KEYMAP == vicmd ]]; then
        echo -ne '\e[1 q'  # block cursor = normal mode
    else
        echo -ne '\e[1 q'  # beam cursor = insert mode
    fi
}
zle -N zle-keymap-select

# Open a file selected via fzf in nvim
df() {
    local selection
    selection=$(fd --type f --hidden --exclude .git \
        | fzf --height 80% --reverse --border \
              --preview "bat --color=always --line-range=:500 {}")
    if [[ -n "$selection" ]]; then
        nvim "$selection"
    fi
}

# Ask / search helper (wraps search.py)
ask() {
    if [[ -z "$1" ]]; then
        python3 ~/search.py
    else
        python3 ~/search.py "$@"
    fi
}

# Compile + run a C++ file
cr() {
    local file="$1"
    g++ -std=c++17 -Wall "$file" -o out
    if [[ $? -eq 0 ]]; then
        ./out
    else
        echo "Compilation failed"
    fi
}

# Update Arch mirrorlist using rate-mirrors
ratemirrors() {
    rate-mirrors --protocol https arch | sudo tee /etc/pacman.d/mirrorlist
}

# Remove orphan packages, clean cache, vacuum logs
clean-arch() {
    local orphans
    orphans=$(pacman -Qdtq)

    if [[ -z "$orphans" ]]; then
        echo "No orphans found. System is lean!"
    else
        local count
        count=$(echo "$orphans" | wc -l | tr -d ' ')
        echo "Removing $count packages..."
        sudo pacman -Rs $orphans
    fi

    echo "Cleaning package cache (keeping last 3)..."
    sudo paccache -r

    echo "Vacuuming system logs (keeping last 7 days)..."
    sudo journalctl --vacuum-time=7days
}
bindkey '^w' backward-kill-word
bindkey '^u' kill-whole-line
# ────────────────────────────────────────────────
# Aliases — navigation
# ────────────────────────────────────────────────

alias l='ls -A'
alias ll='ls -l'
alias la='ls -lA'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ────────────────────────────────────────────────
# Aliases — tools
# ────────────────────────────────────────────────

alias v='nvim'
alias e='exit'
alias c='clear'
alias imgcat='wezterm imgcat'
alias redon='redshift -O 3500'
alias redoff='redshift -x'

# ────────────────────────────────────────────────
# Aliases — tmux
# ────────────────────────────────────────────────

alias a='tmux a'
alias new='tmux new -s'
alias tmux-reload='tmux source-file ~/.config/tmux/tmux.conf'

# ────────────────────────────────────────────────
# Aliases — git
# ────────────────────────────────────────────────

alias gst='git status'
alias gco='git checkout'
alias gdiff='git diff'
alias gadd='git add'
alias gp='git push origin HEAD'
alias gpu='git pull origin'
alias gb='git branch'
alias glog='git log --graph --pretty="%C(yellow)%h%C(reset) %s %C(dim white)- %an, %ar%C(reset)"'
alias gr='git remote -v'

# ────────────────────────────────────────────────
# Aliases — pacman / yay
# ────────────────────────────────────────────────

alias pacs='sudo pacman -S'
alias pacss='pacman -Ss'
alias pacq='pacman -Q | grep'
alias pacu='sudo pacman -Syu'
alias yays='yay -S'
alias yayss='yay -Ss'
alias yayu='yay -Syu'
alias pacclean='sudo pacman -Rns $(pacman -Qtdq)'
#alias pi='pi --tools read,ls,find,grep,bash'

# ────────────────────────────────────────────────
# Aliases — system / misc
# ────────────────────────────────────────────────

alias jc='journalctl -xe'
alias fe='fzf-edit'
alias fh='fzf-history'

# ────────────────────────────────────────────────
# Plugins & External Sources
# ────────────────────────────────────────────────

# Starship prompt
eval "$(starship init zsh)"

# Source CSES helper functions
[[ -f ~/.config/zsh/cses.zsh ]] && source ~/.config/zsh/cses.zsh

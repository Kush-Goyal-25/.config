# Define a custom command to use fzf with command history
def fzf-history [] {
    let selected = (history | fzf | str trim)
    if ($selected | is-empty) {
        echo "No selection made"
    } else {
        eval $selected  # Execute the selected command
    }
}

# Define a custom command to use fzf for file editing
def fzf-edit [] {
    let selected = (ls | fzf | str trim)  # Pipe `ls` output into `fzf`
    if ($selected | is-empty) {
        echo "No selection made"
    } else {
        nvim $selected  # Open the selected file in Neovim
    }
}

# Add ~/.local/bin to PATH if not already present
if not ($env.PATH | any { |it| $it == $"($env.HOME)/.local/bin" }) {
    $env.PATH = ($env.PATH | append $"($env.HOME)/.local/bin")
}

# Define the ans function
def ans [] {
    let tmux_sessionizer_path = $"($env.HOME)/.local/bin/tmux-sessionizer"

    # Check if the tmux-sessionizer script exists
    if ($tmux_sessionizer_path | path exists) {
        # Run the tmux-sessionizer script
        ^$tmux_sessionizer_path
    } else {
        echo $"Error: tmux-sessionizer not found at ($tmux_sessionizer_path)"
    }
}

# Create an alias for the ans function
alias ff = ans

# Aliases for convenience
alias fe = fzf-edit
alias fh = fzf-history
alias fzf = fzf-select
alias new = tmux new -s

# Environment variables
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.PAGER = "bat"
$env.BAT_THEME = "GitHub"

# Aliases for file listing
alias l = ls --all
alias ll = ls -l
alias la = ls --all --long
alias c = clear
alias v = nvim
alias e = exit
alias .. = cd ..
alias ... = cd ../..
alias .... = cd ../../..
alias a = tmux a

# Git Aliases
alias gst = git status
alias gco = git checkout
alias gdiff = git diff
alias gadd = git add
alias gp = git push origin HEAD
alias gpu = git pull origin
alias gb = git branch
alias glog = git log --graph --pretty="%C(yellow)%h%C(reset) %s %C(dim white)- %an, %ar%C(reset)"
alias gr = git remote -v

# Pacman and Yay Aliases
alias pacs = sudo pacman -S
alias pacss = pacman -Ss
alias pacq = pacman -Q | grep
alias pacu = sudo pacman -Syu
alias yays = yay -S
alias yayss = yay -Ss
alias yayu = yay -Syu
alias pacclean = sudo pacman -Rns (pacman -Qtdq)

# Systemd shortcuts
alias jc = journalctl -xe

# Hardware Monitoring
alias diskuse = df -h | grep -v tmpfs
alias gpuuse = if (which nvidia-smi) { nvidia-smi } else { radeontop }  # Check for GPU tools
alias cpuuse = htop
alias memuse = free -h

# System info shortcut
def sysinfo [] {
    echo $"Host: (hostname)"
    echo $"Uptime: (uptime -p)"
    echo $"Shell: (echo $nu.version)"
    neofetch --stdout
}

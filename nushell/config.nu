
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"
$env.PAGER = "bat"
$env.BAT_THEME = "GitHub"

# Aliases
alias l = ls --all
alias ll = ls -l
alias la = ls --all --long
alias c = clear
alias v = nvim
alias e = exit
alias .. = cd ..
alias ... = cd ../..
alias .... = cd ../../..

# Git Aliases
alias gst = git status
alias gco = git checkout
alias gdiff = git diff
alias gadd = git add
alias gc = git commit -m
alias gca = git commit -a -m
alias gp = git push origin HEAD
alias gpu = git pull origin
alias gb = git branch
alias glog = git log --graph --pretty="%C(yellow)%h%C(reset) %s %C(dim white)- %an, %ar%C(reset)"
alias gr = git remote -v

alias pacs = sudo pacman -S
alias pacss = pacman -Ss
alias pacq = pacman -Q | grep
alias pacu = sudo pacman -Syu
alias yays = yay -S
alias yayss = yay -Ss
alias yayu = yay -Syu
alias pacclean = sudo pacman -Rns (pacman -Qtdq)  # Remove orphans
# alias pacsize = expac "%n %m" -l'\n' -Q $(pacman -Qq) | sort -rhk 2 | less


# Systemd shortcuts
alias sc = systemctl
alias scu = systemctl --user
alias jc = journalctl -xe
alias jfu = journalctl -fu

# ========================
# Hardware Monitoring
# ========================
# alias temps = watch -n 2 "sensors | grep Core"
alias diskuse = df -h | grep -v tmpfs | eza
alias gpuuse = nvidia-smi || radeontop
alias cpuuse = htop
alias memuse = free -h


# System info shortcut
def sysinfo [] {
    echo $"Host: (hostname)"
    # echo $"Kernel: (uname -r)"
    echo $"Uptime: (uptime -p)"
    echo $"Shell: (echo $nu.version)"
    neofetch --stdout
}

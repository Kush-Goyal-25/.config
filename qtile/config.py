# Copyright (c) 2010 Aldo Cortesi
# Copyright (c) 2010, 2014 dequis
# Copyright (c) 2012 Randall Ma
# Copyright (c) 2012-2014 Tycho Andersen
# Copyright (c) 2012 Craig Barnes
# Copyright (c) 2013 horsik
# Copyright (c) 2013 Tao Sauvage
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import os
import re
import subprocess

from libqtile import bar, extension, hook, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, KeyChord, Match, Screen
from libqtile.layout import matrix
from libqtile.lazy import lazy

# Make sure 'qtile-extras' is installed or this config will not work.
from qtile_extras import widget
from qtile_extras.widget.decorations import (
    BorderDecoration,
    PowerLineDecoration,
    RectDecoration,
)

# from qtile_extras.widget import StatusNotifier
import colors

mod = "mod4"  # Sets mod key to SUPER/WINDOWS
myTerm = "ghostty"  # My terminal of choice
myBrowser = "zen-browser"  # My browser of choice
myNeovim = "nvim"  # The space at the end is IMPORTANT!
myFiles = "nautilus"  # The space at the end is IMPORTANT!
myBrowser1 = "firefox"


@hook.subscribe.startup
def set_screen_resolution(event):
    subprocess.run(["xrandr", "--output", "Virtual-1", "--mode", "1920x1080"])


# Allows you to input a name when adding treetab section.
@lazy.layout.function
def add_treetab_section(layout):
    prompt = qtile.widgets_map["prompt"]
    prompt.start_input("Section name: ", layout.cmd_add_section)


# A function for hide/show all the windows in a group
@lazy.function
def minimize_all(qtile):
    for win in qtile.current_group.windows:
        if hasattr(win, "toggle_minimize"):
            win.toggle_minimize()


# A function for toggling between MAX and MONADTALL layouts
@lazy.function
def maximize_by_switching_layout(qtile):
    current_layout_name = qtile.current_group.layout.name
    if current_layout_name == "monadtall":
        qtile.current_group.layout = "max"
    elif current_layout_name == "max":
        qtile.current_group.layout = "monadtall"


# Switch groups/layouts even when Firefox or Zen is fullscreen
@lazy.function
def switch_layout_from_fullscreen(qtile, direction="next"):
    """
    Cycle Qtile layouts even when Firefox/Zen browser is in fullscreen.
    Exits fullscreen first, then switches.
    """
    win = qtile.current_window
    browser_classes = {
        "firefox",
        "zen",
        "zen-browser",
        "chromium",
        "google-chrome",
        "brave-browser",
    }
    if win is not None:
        wm_class = (win.get_wm_class() or [""])[0].lower()
        if wm_class in browser_classes and win.fullscreen:
            win.toggle_fullscreen()

    if direction == "next":
        qtile.current_group.cmd_next_layout()
    elif direction == "prev":
        qtile.current_group.cmd_prev_layout()


@hook.subscribe.startup_complete
def hide_bars_on_startup():
    """Hide all top bars when Qtile starts"""
    for screen in qtile.screens:
        if screen.top:
            screen.top.show(False)


keys = [
    # The essentials
    Key([mod], "Return", lazy.spawn(myTerm), desc="Terminal"),
    Key([mod, "shift"], "Return", lazy.spawn("rofi -show drun"), desc="Run Launcher"),
    Key([mod], "w", lazy.spawn(myBrowser), desc="Web browser"),
    Key([mod], "i", lazy.spawn(myBrowser1), desc="Web browser"),
    Key([mod], "u", lazy.spawn(myFiles), desc="File Manager"),
    Key(
        [mod],
        "b",
        lazy.hide_show_bar(position="all"),
        desc="Toggles the bar to show/hide",
    ),
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod], "c", lazy.window.kill(), desc="Kill focused window"),
    Key([mod, "shift"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "shift"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    Key([mod], "r", lazy.spawncmd(), desc="Spawn a command using a prompt widget"),
    Key([mod], "s", lazy.spawn("flameshot gui"), desc="Take a screenshot"),
    # Switch between windows
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Move window focus to other window"),
    Key(
        [mod, "shift"],
        "h",
        lazy.layout.shuffle_left(),
        lazy.layout.move_left().when(layout=["treetab"]),
        desc="Move window to the left/move tab left in treetab",
    ),
    Key(
        [mod, "shift"],
        "l",
        lazy.layout.shuffle_right(),
        lazy.layout.move_right().when(layout=["treetab"]),
        desc="Move window to the right/move tab right in treetab",
    ),
    Key(
        [mod, "shift"],
        "j",
        lazy.layout.shuffle_down(),
        lazy.layout.section_down().when(layout=["treetab"]),
        desc="Move window down/move down a section in treetab",
    ),
    Key(
        [mod, "shift"],
        "k",
        lazy.layout.shuffle_up(),
        lazy.layout.section_up().when(layout=["treetab"]),
        desc="Move window downup/move up a section in treetab",
    ),
    Key(
        [mod, "shift"],
        "space",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
    # Treetab prompt
    Key(
        [mod, "shift"],
        "a",
        add_treetab_section,
        desc="Prompt to add new section in treetab",
    ),
    Key(
        [mod],
        "equal",
        lazy.layout.grow_left().when(layout=["bsp", "columns"]),
        lazy.layout.grow().when(layout=["monadtall", "monadwide"]),
        desc="Grow window to the left",
    ),
    Key(
        [mod],
        "minus",
        lazy.layout.grow_right().when(layout=["bsp", "columns"]),
        lazy.layout.shrink().when(layout=["monadtall", "monadwide"]),
        desc="Grow window to the left",
    ),
    Key([mod, "control"], "h", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key(
        [mod, "control"], "l", lazy.layout.grow_right(), desc="Grow window to the right"
    ),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([mod], "m", lazy.layout.maximize(), desc="Toggle between min and max sizes"),
    Key([mod], "t", lazy.window.toggle_floating(), desc="toggle floating"),
    Key(
        [mod],
        "f",
        maximize_by_switching_layout(),
        lazy.window.toggle_fullscreen(),
        desc="toggle fullscreen",
    ),
    Key(
        [mod],
        "m",
        minimize_all(),
        desc="Toggle hide/show all windows on current group",
    ),
    # Switch focus of monitors
    Key([mod], "period", lazy.next_screen(), desc="Move focus to next monitor"),
    Key([mod], "comma", lazy.prev_screen(), desc="Move focus to prev monitor"),
    # Switch layouts even when Firefox/Zen is in fullscreen
    Key(
        [mod],
        "n",
        switch_layout_from_fullscreen(direction="next"),
        desc="Next layout (exits browser fullscreen if needed)",
    ),
    Key(
        [mod],
        "p",
        switch_layout_from_fullscreen(direction="prev"),
        desc="Prev layout (exits browser fullscreen if needed)",
    ),
    # Emacs programs launched using the key chord CTRL+e followed by 'key'
    KeyChord(
        [mod],
        "e",
        [
            Key([], "e", lazy.spawn(myNeovim), desc="Emacs Dashboard"),
            Key(
                [],
                "a",
                lazy.spawn(
                    myNeovim + "--eval '(emms-play-directory-tree \"~/Music/\")'"
                ),
                desc="Emacs EMMS",
            ),
            Key(
                [],
                "b",
                lazy.spawn(myNeovim + "--eval '(ibuffer)'"),
                desc="Emacs Ibuffer",
            ),
            Key(
                [],
                "d",
                lazy.spawn(myNeovim + "--eval '(dired nil)'"),
                desc="Emacs Dired",
            ),
            Key([], "i", lazy.spawn(myNeovim + "--eval '(erc)'"), desc="Emacs ERC"),
            Key(
                [], "s", lazy.spawn(myNeovim + "--eval '(eshell)'"), desc="Emacs Eshell"
            ),
            Key([], "v", lazy.spawn(myNeovim + "--eval '(vterm)'"), desc="Emacs Vterm"),
            Key(
                [],
                "w",
                lazy.spawn(myNeovim + "--eval '(eww \"distro.tube\")'"),
                desc="Emacs EWW",
            ),
            Key(
                [],
                "F4",
                lazy.spawn("killall emacs"),
                lazy.spawn("/usr/bin/emacs --daemon"),
                desc="Kill/restart the Emacs daemon",
            ),
        ],
    ),
    # Dmenu/rofi scripts launched using the key chord SUPER+p followed by 'key'
    KeyChord(
        [mod],
        "p",
        [
            Key([], "h", lazy.spawn("dm-hub -r"), desc="List all dmscripts"),
            Key([], "a", lazy.spawn("dm-sounds -r"), desc="Choose ambient sound"),
            Key([], "b", lazy.spawn("dm-setbg -r"), desc="Set background"),
            Key([], "c", lazy.spawn("dtos-colorscheme -r"), desc="Choose color scheme"),
            Key(
                [],
                "e",
                lazy.spawn("dm-confedit -r"),
                desc="Choose a config file to edit",
            ),
            Key([], "i", lazy.spawn("dm-maim -r"), desc="Take a screenshot"),
            Key([], "k", lazy.spawn("dm-kill -r"), desc="Kill processes "),
            Key([], "m", lazy.spawn("dm-man -r"), desc="View manpages"),
            Key([], "n", lazy.spawn("dm-note -r"), desc="Store and copy notes"),
            Key([], "o", lazy.spawn("dm-bookman -r"), desc="Browser bookmarks"),
            Key([], "p", lazy.spawn("rofi-pass"), desc="Logout menu"),
            Key([], "q", lazy.spawn("dm-logout -r"), desc="Logout menu"),
            Key([], "r", lazy.spawn("dm-radio -r"), desc="Listen to online radio"),
            Key([], "s", lazy.spawn("dm-websearch -r"), desc="Search various engines"),
            Key([], "t", lazy.spawn("dm-translate -r"), desc="Translate text"),
        ],
    ),
]

groups = [
    Group(
        "1",
        layout="max",
        matches=[
            Match(wm_class="firefox"),
            Match(wm_class="zen"),
        ],
    ),
    Group(
        "2",
        layout="max",
        matches=[
            Match(wm_class="ghostty"),
        ],
    ),
    Group(
        "3",
        layout="max",
    ),
    Group(
        "4",
        layout="max",
        matches=[
            Match(wm_class="excalidraw"),
        ],
    ),
    Group(
        "5",
        layout="max",
        matches=[
            Match(wm_class="ticktick"),
        ],
    ),
]


group_names = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
group_labels = ["󰖟", "󰨊", "󰈙", "󰏬", "󰃰", "󰙯", "󰎙", "󰕧", "󰊢"]
# Nerd Font icons: browser, terminal, docs, design, calendar, chat, music, video, git
# Fallback plain labels if Nerd Fonts not installed:
# group_labels = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

group_layouts = ["max"] * 9

for i in range(len(group_names)):
    groups.append(
        Group(
            name=group_names[i],
            layout=group_layouts[i].lower(),
            label=group_labels[i],
        )
    )

for i in groups:
    keys.extend(
        [
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc="Switch to group {}".format(i.name),
            ),
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=False),
                desc="Move focused window to group {}".format(i.name),
            ),
        ]
    )

colors = colors.DoomOne

# ── Palette shortcuts for the bar ─────────────────────────────────────────────
BG = colors[0][0]  # #282c34  deep charcoal
FG = colors[1][0]  # #bbc2cf  soft silver
DARK = colors[2][0]  # #1c1f24  near-black
RED = colors[3][0]  # #ff6c6b
GREEN = colors[4][0]  # #98be65
ORANGE = colors[5][0]  # #da8548
BLUE = colors[6][0]  # #51afef
MAGENTA = colors[7][0]  # #c678dd
CYAN = colors[8][0]  # #46d9ff

# ── Semi-transparent panel background ─────────────────────────────────────────
PANEL_BG = "#1c1f24ee"  # slightly transparent near-black
PILL_BG = "#23272eee"  # pill widget background

layout_theme = {
    "border_width": 2,
    "margin": 6,
    "border_focus": CYAN,
    "border_normal": DARK,
}

layouts = [
    layout.MonadTall(**layout_theme),
    layout.Max(border_width=0, margin=0),
    layout.TreeTab(
        font="JetBrainsMono Nerd Font Bold",
        fontsize=11,
        border_width=0,
        bg_color=BG,
        active_bg=CYAN,
        active_fg=DARK,
        inactive_bg=DARK,
        inactive_fg=FG,
        padding_left=8,
        padding_x=8,
        padding_y=6,
        sections=["ONE", "TWO", "THREE"],
        section_fontsize=10,
        section_fg=MAGENTA,
        section_top=15,
        section_bottom=15,
        level_shift=8,
        vspace=3,
        panel_width=240,
    ),
]

widget_defaults = dict(
    font="JetBrainsMono Nerd Font",
    fontsize=11,
    padding=0,
    background=PANEL_BG,
)
extension_defaults = widget_defaults.copy()


# ── Helper: slim pill RectDecoration ──────────────────────────────────────────
# padding_y is fixed for ALL pills so every badge renders at the same height.
def pill(color, radius=6, padding=6):
    return [
        RectDecoration(
            colour=color,
            radius=radius,
            filled=True,
            padding_y=4,
            padding_x=padding,
            group=True,
        )
    ]


# ── Helper: thin underline accent ─────────────────────────────────────────────
def underline(color):
    return [BorderDecoration(colour=color, border_width=[0, 0, 2, 0])]


# ── Helper: dot separator ─────────────────────────────────────────────────────
def sep(padding=6):
    return widget.TextBox(
        text="·",
        font="JetBrainsMono Nerd Font",
        fontsize=14,
        foreground="#3d4251",
        background=PANEL_BG,
        padding=padding,
    )


def spacer(n=4):
    return widget.Spacer(length=n, background=PANEL_BG)


# ══════════════════════════════════════════════════════════════════════════════
#  BAR WIDGET LIST  — slim, size=26, no margin
# ══════════════════════════════════════════════════════════════════════════════
def init_widgets_list():
    widgets_list = [
        # ── Logo ──────────────────────────────────────────────────────────────
        spacer(5),
        widget.TextBox(
            text=" ",
            font="JetBrainsMono Nerd Font Bold",
            fontsize=12,
            foreground=DARK,
            background=PANEL_BG,
            padding=0,
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(myTerm)},
            decorations=pill(CYAN, radius=7, padding=7),
        ),
        spacer(8),
        # ── Groups ────────────────────────────────────────────────────────────
        widget.GroupBox(
            font="JetBrainsMono Nerd Font Bold",
            fontsize=12,
            margin_y=3,
            margin_x=1,
            padding_y=3,
            padding_x=6,
            borderwidth=0,
            active=CYAN,
            inactive="#3d4251",
            rounded=True,
            highlight_color=[PANEL_BG, DARK],
            highlight_method="block",
            this_current_screen_border="#46d9ff1a",
            this_screen_border="#51afef11",
            other_current_screen_border="#c678dd11",
            other_screen_border=DARK,
            urgent_border=RED,
            background=PANEL_BG,
            foreground=FG,
            disable_drag=True,
        ),
        sep(),
        # ── Layout ────────────────────────────────────────────────────────────
        widget.CurrentLayoutIcon(
            foreground=MAGENTA,
            background=PANEL_BG,
            padding=2,
            scale=0.5,
        ),
        widget.CurrentLayout(
            foreground=MAGENTA,
            background=PANEL_BG,
            padding=3,
            font="JetBrainsMono Nerd Font Bold",
            fontsize=11,
            decorations=underline(MAGENTA),
        ),
        sep(),
        # ── Prompt + Window name ──────────────────────────────────────────────
        widget.Prompt(
            font="JetBrainsMono Nerd Font",
            fontsize=11,
            foreground=GREEN,
            background=PANEL_BG,
            padding=2,
        ),
        widget.WindowName(
            foreground="#4b5263",
            background=PANEL_BG,
            max_chars=40,
            font="JetBrainsMono Nerd Font",
            fontsize=11,
            padding=2,
            format="{state}{name}",
        ),
        # ── Flex spacer ───────────────────────────────────────────────────────
        widget.Spacer(background=PANEL_BG),
        # ── Kernel ────────────────────────────────────────────────────────────
        widget.GenPollText(
            update_interval=300,
            func=lambda: subprocess.check_output(
                "uname -r | cut -d'-' -f1", shell=True, text=True
            ).strip(),
            foreground=GREEN,
            background=PANEL_BG,
            font="JetBrainsMono Nerd Font",
            fontsize=11,
            padding=4,
        ),
        # ── CPU ───────────────────────────────────────────────────────────────
        widget.CPU(
            format=" {load_percent:.0f}%",
            foreground=ORANGE,
            background=PANEL_BG,
            font="JetBrainsMono Nerd Font",
            fontsize=11,
            padding=4,
            update_interval=2,
        ),
        # ── Memory ────────────────────────────────────────────────────────────
        widget.Memory(
            foreground=BLUE,
            background=PANEL_BG,
            font="JetBrainsMono Nerd Font",
            fontsize=11,
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(myTerm + " -e htop")},
            format="{MemUsed:.0f}{mm}",
            measure_mem="G",
            padding=4,
        ),
        # ── Volume ────────────────────────────────────────────────────────────
        widget.Volume(
            foreground=MAGENTA,
            background=PANEL_BG,
            font="JetBrainsMono Nerd Font",
            fontsize=11,
            fmt="{}",
            padding=4,
        ),
        # ── Clock ─────────────────────────────────────────────────────────────
        widget.Clock(
            foreground=CYAN,
            background=PANEL_BG,
            font="JetBrainsMono Nerd Font",
            fontsize=11,
            format="%H:%M  %a %d",
            padding=4,
        ),
        spacer(6),
        # ── Systray ───────────────────────────────────────────────────────────
        widget.Systray(
            background=PANEL_BG,
            padding=4,
            icon_size=14,
        ),
        spacer(6),
    ]
    return widgets_list


def init_widgets_screen1():
    return init_widgets_list()


def init_widgets_screen2():
    widgets = init_widgets_list()
    # Remove systray (last two: systray + spacer)
    del widgets[-2:]
    return widgets


def init_screens():
    return [
        Screen(
            top=bar.Bar(
                widgets=init_widgets_screen1(),
                size=26,
                background=PANEL_BG,
                margin=0,
                border_width=0,
                opacity=1.0,
            )
        ),
        Screen(
            top=bar.Bar(
                widgets=init_widgets_screen2(),
                size=26,
                background=PANEL_BG,
                margin=0,
                border_width=0,
            )
        ),
        Screen(
            top=bar.Bar(
                widgets=init_widgets_screen2(),
                size=26,
                background=PANEL_BG,
                margin=0,
                border_width=0,
            )
        ),
    ]


if __name__ in ["config", "__main__"]:
    screens = init_screens()
    widgets_list = init_widgets_list()
    widgets_screen1 = init_widgets_screen1()
    widgets_screen2 = init_widgets_screen2()


def window_to_prev_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i - 1].name)


def window_to_next_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i + 1].name)


def window_to_previous_screen(qtile):
    i = qtile.screens.index(qtile.current_screen)
    if i != 0:
        group = qtile.screens[i - 1].group.name
        qtile.current_window.togroup(group)


def window_to_next_screen(qtile):
    i = qtile.screens.index(qtile.current_screen)
    if i + 1 != len(qtile.screens):
        group = qtile.screens[i + 1].group.name
        qtile.current_window.togroup(group)


def switch_screens(qtile):
    i = qtile.screens.index(qtile.current_screen)
    group = qtile.screens[i - 1].group
    qtile.current_screen.set_group(group)


mouse = [
    Drag(
        [mod],
        "Button1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    border_focus=CYAN,
    border_width=2,
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="dialog"),
        Match(wm_class="download"),
        Match(wm_class="error"),
        Match(wm_class="file_progress"),
        Match(wm_class="kdenlive"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="notification"),
        Match(wm_class="pinentry-gtk-2"),
        Match(wm_class="ssh-askpass"),
        Match(wm_class="toolbar"),
        Match(wm_class="Yad"),
        Match(title="branchdialog"),
        Match(title="Confirmation"),
        Match(title="Qalculate!"),
        Match(title="pinentry"),
        Match(title="tastycharts"),
        Match(title="tastytrade"),
        Match(title="tastytrade - Portfolio Report"),
        Match(wm_class="tasty.javafx.launcher.LauncherFxApp"),
    ],
)
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wl_input_rules = None


@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser("~")
    subprocess.call([home + "/.config/qtile/autostart.sh"])


wmname = "LG3D"

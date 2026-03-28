# ─────────────────────────────────────────────────────────────────────────────
# cses.nu — Fetch + compile + test CSES problems in one command
#
# Install:
#   1. cp cses_scrape.py ~/.local/bin/cses_scrape.py
#      chmod +x ~/.local/bin/cses_scrape.py
#   2. Add to config.nu:
#        source ~/.config/nushell/cses.nu
#
# Commands:
#   cses <id> <file.cpp>     — fetch samples, compile, run, show results
#   cses-cached              — list all cached problems
#   cses-clear [id]          — delete cache for one problem (or all)
#
# Flags for cses:
#   --time  / -t             show ms per test case
#   --keep  / -k             keep compiled binary at /tmp/__cses_out
#   --force / -F             re-fetch even if cached
#   --show  / -s             print test cases before running
#   --flags <str>            extra g++ flags (e.g. "-fsanitize=address")
#
# Examples:
#   cses 1068 weird_algorithm.cpp
#   cses 1068 weird_algorithm.cpp --time
#   cses 1068 weird_algorithm.cpp --force
#   cses 1621 sol.cpp --flags "-D_GLIBCXX_DEBUG"
# ─────────────────────────────────────────────────────────────────────────────

# ── Internal helpers ──────────────────────────────────────────────────────────

def _c [code: string, text: string]: nothing -> string {
    $"(ansi $code)(ansi reset)" | str replace "" $text
    # safe version: build outside interpolation
}

# Simpler, interpolation-safe color helper
def _cc [code: string, text: string]: nothing -> string {
    (ansi $code) + $text + (ansi reset)
}

def _divider []: nothing -> nothing {
    print ((_cc "dark_gray" "  ─────────────────────────────────────────────"))
}

def _cses_compile [file: string, extra_flags: string]: nothing -> record {
    let flag_list = (
        if ($extra_flags | str trim | is-empty) { [] }
        else {
            $extra_flags
            | split row " "
            | where { |s| not ($s | str trim | is-empty) }
        }
    )
    ^g++ -O2 -std=c++17 -Wall -Wextra -o /tmp/__cses_out ...$flag_list $file
    | complete
}

def _cses_run_case [
    input:     string
    expected:  string
    idx:       int
    show_time: bool
]: nothing -> bool {
    let tmp_in = (^mktemp)
    $input | save --force $tmp_in

    let start  = (date now)
    let result = (^bash -c $"/tmp/__cses_out < ($tmp_in)" | complete)
    let ms     = (((date now) - $start) / 1ms | math round --precision 1)

    rm -f $tmp_in

    let actual    = ($result.stdout | str trim)
    let exp_clean = ($expected | str trim)
    let pass      = ($actual == $exp_clean)

    let label = (if $pass { "PASS" } else { "FAIL" })
    let color = (if $pass { "green_bold" } else { "red_bold" })

    let time_part = (if $show_time { " " + (_cc "dark_gray" (($ms | into string) + "ms")) } else { "" })

    print ((_cc $color ("  " + $label)) + "  case " + ($idx | into string) + $time_part)

    if not $pass {
        print ""
        print (_cc "yellow" "    input:")
        for ln in ($input | lines) { print ("      " + $ln) }
        print (_cc "yellow" "    expected:")
        for ln in ($exp_clean | lines) { print ("      " + (_cc "green" $ln)) }
        print (_cc "yellow" "    got:")
        for ln in ($actual | lines) { print ("      " + (_cc "red" $ln)) }
        print ""
    }

    $pass
}

def _cses_parse_cases [path: string]: nothing -> list {
    (open $path)
    | split row "---"
    | each { |block|
        let b = ($block | str trim)
        if ($b | is-empty) {
            null
        } else {
            let parts = ($b | split row ">>>")
            if ($parts | length) != 2 {
                error make { msg: ("Corrupt cache — missing '>>>' in " + $path) }
            }
            {
                input:    ($parts | get 0 | str trim)
                expected: ($parts | get 1 | str trim)
            }
        }
    }
    | where { |x| $x != null }
}

# ── Main command ──────────────────────────────────────────────────────────────

# Test a C++ solution against CSES sample cases (auto-fetched and cached)
def cses [
    problem_id: string       # Problem ID e.g. 1068, or full https://cses.fi/... URL
    file: string             # C++ source file to compile and run
    --time  (-t)             # Show execution time per case
    --keep  (-k)             # Keep compiled binary after run
    --force (-F)             # Re-fetch samples even if already cached
    --show  (-s)             # Print the test cases before running
    --flags: string = ""     # Extra g++ flags
]: nothing -> nothing {

    # ── Resolve problem ID ───────────────────────────────────────────────────
    let pid = (
        if ($problem_id | str starts-with "http") {
            let m = ($problem_id | parse --regex ".*/task/(?P<id>\\d+)")
            if ($m | is-empty) {
                error make { msg: ("Cannot parse problem ID from: " + $problem_id) }
            }
            $m | get id.0
        } else {
            $problem_id
        }
    )

    let url        = "https://cses.fi/problemset/task/" + $pid
    let cache_dir  = ($env.HOME) + "/.cache/cses"
    let cache_file = $cache_dir + "/" + $pid + ".txt"
    let scraper    = ($env.HOME) + "/.local/bin/cses_scrape.py"

    # ── Header ───────────────────────────────────────────────────────────────
    print ""
    print (
        "  " + (_cc "cyan_bold" "[ cses ]") +
        "  problem " + (_cc "yellow_bold" $pid) +
        "  →  " + (_cc "yellow" $file)
    )
    print ("  " + (_cc "dark_gray" $url))
    _divider

    # ── Validate inputs ──────────────────────────────────────────────────────
    if not ($file | path exists) {
        print (_cc "red_bold" ("  error: file not found → " + $file))
        print ""
        return
    }

    if not ($scraper | path exists) {
        print (_cc "red_bold" "  error: cses_scrape.py not installed")
        print ("  expected at: " + (_cc "yellow" $scraper))
        print ""
        print "  install with:"
        print ("    cp ~/Downloads/cses_scrape.py " + $scraper)
        print "    chmod +x ~/.local/bin/cses_scrape.py"
        print ""
        return
    }

    # ── Fetch or use cache ───────────────────────────────────────────────────
    ^mkdir -p $cache_dir

    let needs_fetch = $force or (not ($cache_file | path exists))

    if $needs_fetch {
        print (_cc "dark_gray" "  fetching samples from cses.fi ...")

        let scrape = (^python3 $scraper $pid $cache_file | complete)

        if $scrape.exit_code != 0 {
            print (_cc "red_bold" "  fetch failed")
            if not ($scrape.stderr | str trim | is-empty) {
                print $scrape.stderr
            }
            print ""
            return
        }

        # Print scraper info lines from stderr
        let info_lines = (
            $scrape.stderr
            | lines
            | where { |l|
                let t = ($l | str trim)
                (not ($t | is-empty)) and (not ($t | str starts-with "__"))
            }
            | each { |l|
                $l | str trim | str replace "[cses] " "" | str replace "[CSES] " ""
            }
        )
        for ln in $info_lines {
            print ("  " + (_cc "dark_gray" $ln))
        }

    } else {
        print (_cc "dark_gray" ("  cache hit  ~/.cache/cses/" + $pid + ".txt"))
    }

    # ── Parse cases ──────────────────────────────────────────────────────────
    if not ($cache_file | path exists) {
        print (_cc "red_bold" "  cache file missing after fetch — aborting")
        print ""
        return
    }

    let cases = (_cses_parse_cases $cache_file)
    let total = ($cases | length)

    if $total == 0 {
        print (_cc "red" "  no sample cases found for this problem")
        print ""
        return
    }

    let total_str = ($total | into string)
    print (_cc "dark_gray" ("  " + $total_str + " sample case(s) loaded"))

    # ── Optionally print the test cases ──────────────────────────────────────
    if $show {
        _divider
        print (_cc "cyan" "  sample cases:")
        print ""
        mut si = 1
        for tc in $cases {
            let si_str = ($si | into string)
            print (_cc "dark_gray" ("  ── input " + $si_str + " ──────────────────────────────"))
            for ln in ($tc.input | lines) { print ("    " + $ln) }
            print (_cc "dark_gray" ("  ── expected " + $si_str + " ────────────────────────────"))
            for ln in ($tc.expected | lines) { print ("    " + (_cc "green" $ln)) }
            print ""
            $si += 1
        }
    }

    # ── Compile ───────────────────────────────────────────────────────────────
    _divider
    print (_cc "dark_gray" "  compiling ...")

    let comp = (_cses_compile $file $flags)

    if $comp.exit_code != 0 {
        print (_cc "red_bold" "  compile FAILED")
        print ""
        for ln in ($comp.stderr | lines) { print ("  " + $ln) }
        print ""
        return
    }

    print (_cc "green" "  compiled OK")
    _divider
    print ""

    # ── Run every sample case ─────────────────────────────────────────────────
    mut passed = 0
    mut idx    = 1

    for tc in $cases {
        let ok = (_cses_run_case $tc.input $tc.expected $idx $time)
        if $ok { $passed += 1 }
        $idx += 1
    }

    # ── Summary ───────────────────────────────────────────────────────────────
    print ""
    _divider

    let failed  = $total - $passed
    let p_str   = ($passed | into string)
    let t_str   = ($total  | into string)
    let f_str   = ($failed | into string)

    if $passed == $total {
        print (_cc "green_bold" ("  ✓  " + $p_str + " / " + $t_str + "  all samples passed"))
        print (_cc "dark_gray"  "     submit on cses.fi to check against hidden tests")
    } else {
        print (_cc "red_bold" (
            "  ✗  " + $f_str + " / " + $t_str + " failed" +
            "    " + $p_str + " / " + $t_str + " passed"
        ))
    }

    print ("  " + (_cc "dark_gray" $url))
    print ""

    if not $keep { rm -f /tmp/__cses_out }
}

# ── cses-cached ───────────────────────────────────────────────────────────────

# List all locally cached CSES problems
def cses-cached []: nothing -> nothing {
    let cache_dir = ($env.HOME) + "/.cache/cses"

    if not ($cache_dir | path exists) {
        print "no cached problems yet"
        return
    }

    let rows = (
        ls $cache_dir
        | where name =~ '\.txt$'
        | each { |f|
            let pid = ($f.name | path basename | str replace ".txt" "")
            let n   = (
                open $f.name
                | split row "---"
                | where { |b| not ($b | str trim | is-empty) }
                | length
            )
            {
                id:      $pid
                samples: $n
                cached:  ($f.modified | format date "%Y-%m-%d %H:%M")
                url:     ("https://cses.fi/problemset/task/" + $pid)
            }
        }
    )

    if ($rows | is-empty) {
        print "no cached problems yet"
    } else {
        $rows
    }
}

# ── cses-clear ────────────────────────────────────────────────────────────────

# Delete cached test cases for one problem, or wipe the entire cache
def cses-clear [
    problem_id?: string   # Problem ID to clear; omit to clear all
]: nothing -> nothing {
    let cache_dir = ($env.HOME) + "/.cache/cses"

    if ($problem_id == null) or ($problem_id | str trim | is-empty) {
        if ($cache_dir | path exists) {
            rm -rf $cache_dir
            print (_cc "green" "  cleared all cached CSES test cases")
        } else {
            print "nothing to clear"
        }
    } else {
        let f = $cache_dir + "/" + $problem_id + ".txt"
        if ($f | path exists) {
            rm $f
            print (_cc "green" ("  cleared cache for problem " + $problem_id))
        } else {
            print (_cc "yellow" ("  no cache found for " + $problem_id))
        }
    }
}

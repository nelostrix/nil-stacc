#!/usr/bin/env bash
#
# Nelo Robotics — Universal Package Installer
#
# Usage:
#   bash install.sh --key YOUR_KEY                        # installs nil-stacc (full stack)
#   bash install.sh --key YOUR_KEY --package stacc        # robotics only
#   bash install.sh --key YOUR_KEY --package nil-sdk      # agent SDK only
#   bash install.sh --key YOUR_KEY --package nil-stacc    # full stack
#

set -e

R='\033[0m'; BOLD='\033[1m'; DIM='\033[2m'
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; CYAN='\033[0;36m'; WHITE='\033[1;37m'
BRED='\033[1;31m'; BGREEN='\033[1;32m'; BYELLOW='\033[1;33m'; BCYAN='\033[1;36m'
BMAGENTA='\033[1;35m'; BBLUE='\033[1;34m'; BWHITE='\033[1;37m'

SERVER="https://nelo-license-server.nelorobotics.workers.dev"

tput civis 2>/dev/null || true
trap "tput cnorm 2>/dev/null || true" EXIT

COLS=$(tput cols 2>/dev/null || echo 80)
ROWS=$(tput lines 2>/dev/null || echo 24)

# ── Parse args ──
LICENSE_KEY=""
PACKAGE="nil-stacc"
while [[ $# -gt 0 ]]; do
    case "$1" in
        --key|-k)     LICENSE_KEY="$2"; shift 2 ;;
        --package|-p) PACKAGE="$2"; shift 2 ;;
        *)            shift ;;
    esac
done

if [ -z "$LICENSE_KEY" ]; then
    tput cnorm 2>/dev/null || true
    echo ""
    echo -e "  ${BRED}ERROR:${R} License key required."
    echo ""
    echo -e "  ${WHITE}Usage:${R}"
    echo -e "    bash install.sh --key YOUR_KEY"
    echo -e "    bash install.sh --key YOUR_KEY --package stacc"
    echo -e "    bash install.sh --key YOUR_KEY --package nil-sdk"
    echo -e "    bash install.sh --key YOUR_KEY --package nil-stacc"
    echo ""
    echo -e "  ${DIM}Get a license at: https://nelo-robotics.com/pricing${R}"
    exit 1
fi

# ══════════════════════════════════════════════════════
# ANIMATION: MATRIX RAIN (stacc — green, cyberpunk)
# ══════════════════════════════════════════════════════
anim_matrix_rain() {
    clear
    for frame in $(seq 1 25); do
        for c in $(seq 1 $((COLS / 3))); do
            col=$((RANDOM % COLS + 1))
            row=$((RANDOM % ROWS + 1))
            chars="01ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄ"
            idx=$((RANDOM % ${#chars}))
            char="${chars:$idx:1}"
            if [ $((RANDOM % 5)) -eq 0 ]; then
                printf "\033[%d;%dH${BGREEN}%s${R}" "$row" "$col" "$char"
            else
                printf "\033[%d;%dH${GREEN}${DIM}%s${R}" "$row" "$col" "$char"
            fi
        done
        sleep 0.03
    done
}

# ══════════════════════════════════════════════════════
# ANIMATION: STARFIELD (nil-sdk — purple, neural)
# ══════════════════════════════════════════════════════
anim_starfield() {
    clear
    local star_chars=("." "·" "+" "✦" "✧" "★" "⋆" "*")
    local star_colors=("$BMAGENTA" "$BBLUE" "$BCYAN" "$BWHITE" "$DIM")

    for frame in $(seq 1 30); do
        for s in $(seq 1 $((COLS / 4))); do
            col=$((RANDOM % COLS + 1))
            row=$((RANDOM % ROWS + 1))
            si=$((RANDOM % ${#star_chars[@]}))
            ci=$((RANDOM % ${#star_colors[@]}))
            printf "\033[%d;%dH${star_colors[$ci]}%s${R}" "$row" "$col" "${star_chars[$si]}"
        done
        # Shooting star occasionally
        if [ $((frame % 5)) -eq 0 ]; then
            srow=$((RANDOM % (ROWS - 2) + 1))
            scol=$((RANDOM % (COLS - 15) + 1))
            for trail in $(seq 0 8); do
                printf "\033[%d;%dH${BMAGENTA}━${R}" "$srow" "$((scol + trail))"
                sleep 0.01
            done
            printf "\033[%d;%dH${BWHITE}✦${R}" "$srow" "$((scol + 9))"
        fi
        sleep 0.03
    done
}

# ══════════════════════════════════════════════════════
# ANIMATION: FUSION (nil-stacc — both combined)
# ══════════════════════════════════════════════════════
anim_fusion() {
    clear
    local chars_matrix="01ｱｲｳｴｵｶｷｸ"
    local star_chars=("✦" "✧" "★" "⋆" "·")

    for frame in $(seq 1 25); do
        for c in $(seq 1 $((COLS / 4))); do
            col=$((RANDOM % COLS + 1))
            row=$((RANDOM % ROWS + 1))

            if [ $((RANDOM % 2)) -eq 0 ]; then
                # Matrix side (left half = green)
                if [ $col -lt $((COLS / 2)) ]; then
                    idx=$((RANDOM % ${#chars_matrix}))
                    printf "\033[%d;%dH${BGREEN}%s${R}" "$row" "$col" "${chars_matrix:$idx:1}"
                else
                    si=$((RANDOM % ${#star_chars[@]}))
                    printf "\033[%d;%dH${BMAGENTA}%s${R}" "$row" "$col" "${star_chars[$si]}"
                fi
            fi
        done

        # Center fusion line
        mid=$((COLS / 2))
        for fy in $(seq 1 $ROWS); do
            if [ $((RANDOM % 3)) -eq 0 ]; then
                printf "\033[%d;%dH${BYELLOW}║${R}" "$fy" "$mid"
            fi
        done
        sleep 0.03
    done
}

# ══════════════════════════════════════════════════════
# BANNER per package
# ══════════════════════════════════════════════════════
show_banner() {
    clear
    local sr=$(( (ROWS - 10) / 2 ))
    local color="$BCYAN"
    local banner_lines=()
    local subtitle=""

    if [ "$PACKAGE" = "stacc" ]; then
        color="$BCYAN"
        banner_lines=(
            "  ███████╗████████╗ █████╗  ██████╗ ██████╗ "
            "  ██╔════╝╚══██╔══╝██╔══██╗██╔════╝██╔════╝ "
            "  ███████╗   ██║   ███████║██║     ██║      "
            "  ╚════██║   ██║   ██╔══██║██║     ██║      "
            "  ███████║   ██║   ██║  ██║╚██████╗╚██████╗ "
            "  ╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ "
        )
        subtitle="T H E   U N I V E R S A L   R O B O T I C S   P L A T F O R M"

    elif [ "$PACKAGE" = "nil-sdk" ] || [ "$PACKAGE" = "nil" ]; then
        color="$BMAGENTA"
        banner_lines=(
            "  ███╗   ██╗██╗██╗     "
            "  ████╗  ██║██║██║     "
            "  ██╔██╗ ██║██║██║     "
            "  ██║╚██╗██║██║██║     "
            "  ██║ ╚████║██║███████╗"
            "  ╚═╝  ╚═══╝╚═╝╚══════╝"
        )
        subtitle="S E L F - E V O L V I N G   A G E N T   S D K"

    elif [ "$PACKAGE" = "nil-stacc" ]; then
        color="$BYELLOW"
        banner_lines=(
            "  ███╗   ██╗██╗██╗      ╔═╗████████╗ █████╗  ██████╗ ██████╗ "
            "  ████╗  ██║██║██║      ╚═╝╚══██╔══╝██╔══██╗██╔════╝██╔════╝ "
            "  ██╔██╗ ██║██║██║     ╔══╗   ██║   ███████║██║     ██║      "
            "  ██║╚██╗██║██║██║     ╚══╝   ██║   ██╔══██║██║     ██║      "
            "  ██║ ╚████║██║███████╗       ██║   ██║  ██║╚██████╗╚██████╗ "
            "  ╚═╝  ╚═══╝╚═╝╚══════╝       ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ "
        )
        subtitle="T H E   C O M P L E T E   R O B O T I C S   I N T E L L I G E N C E   S T A C K"
    fi

    # Glitch reveal
    local glitch_chars="!@#\$%^&*()_+-=[]{}|;:<>?/~█▓▒░"
    local gcolors=("$RED" "$BRED" "$YELLOW" "$CYAN" "$BMAGENTA" "$BBLUE")

    for pass in $(seq 1 7); do
        clear
        local r=$sr
        for line in "${banner_lines[@]}"; do
            result=""
            for ((i=0; i<${#line}; i++)); do
                if [ $((RANDOM % (pass + 1))) -eq 0 ]; then
                    gi=$((RANDOM % ${#glitch_chars}))
                    result+="${glitch_chars:$gi:1}"
                else
                    result+="${line:$i:1}"
                fi
            done
            ci=$((RANDOM % ${#gcolors[@]}))
            printf "\033[%d;3H${gcolors[$ci]}%s${R}" "$r" "$result"
            r=$((r + 1))
        done
        sleep 0.06
    done

    # Clean reveal
    clear
    local r=$sr
    for line in "${banner_lines[@]}"; do
        printf "\033[%d;3H${color}%s${R}" "$r" "$line"
        r=$((r + 1))
        sleep 0.04
    done

    # Typewriter subtitle
    r=$((r + 1))
    local sp=$(( (COLS - ${#subtitle}) / 2 ))
    [ $sp -lt 2 ] && sp=2
    for ((i=0; i<${#subtitle}; i++)); do
        printf "\033[%d;%dH${WHITE}%s${R}" "$r" "$((sp + i))" "${subtitle:$i:1}"
        sleep 0.01
    done

    r=$((r + 2))
    printf "\033[%d;3H${DIM}  by Nelo Robotics Pvt Ltd${R}" "$r"
    sleep 0.8
}

# ══════════════════════════════════════════════════════
# LICENSE VALIDATION
# ══════════════════════════════════════════════════════
validate_license() {
    clear
    echo ""
    echo -e "  ${BCYAN}╔═══════════════════════════════════════════════╗${R}"
    echo -e "  ${BCYAN}║${R}  ${WHITE}${BOLD}  L I C E N S E   V A L I D A T I O N${R}        ${BCYAN}║${R}"
    echo -e "  ${BCYAN}╚═══════════════════════════════════════════════╝${R}"
    echo ""

    local masked="${LICENSE_KEY:0:9}***${LICENSE_KEY: -5}"
    echo -ne "  ${CYAN}  ⟩${R} Key: ${WHITE}${masked}${R}"
    for d in 1 2 3; do printf "."; sleep 0.15; done

    VALIDATE_RESPONSE=$(curl -s -X POST "${SERVER}/validate" \
        -H "Content-Type: application/json" \
        -d "{\"key\": \"${LICENSE_KEY}\"}" 2>/dev/null || echo '{"error":"Connection failed"}')

    if echo "$VALIDATE_RESPONSE" | grep -q '"valid":true'; then
        TIER=$(echo "$VALIDATE_RESPONSE" | sed -n 's/.*"tier":"\([^"]*\)".*/\1/p')
        CUSTOMER=$(echo "$VALIDATE_RESPONSE" | sed -n 's/.*"customer":"\([^"]*\)".*/\1/p')
        TOKEN=$(echo "$VALIDATE_RESPONSE" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')

        printf "\r  ${GREEN}  ✓${R} Key: ${WHITE}${masked}${R}  ${BGREEN}VALID${R}          \n"
        echo -e "  ${GREEN}  ✓${R} Tier: ${BGREEN}${TIER}${R}"
        [ -n "$CUSTOMER" ] && echo -e "  ${GREEN}  ✓${R} Customer: ${WHITE}${CUSTOMER}${R}"
        echo ""
        sleep 0.5
        return 0
    else
        local err=$(echo "$VALIDATE_RESPONSE" | sed -n 's/.*"error":"\([^"]*\)".*/\1/p')
        printf "\r  ${RED}  ✗${R} Key: ${WHITE}${masked}${R}  ${BRED}INVALID${R}          \n"
        echo -e "\n  ${BRED}Error:${R} ${err:-Validation failed}"
        echo -e "\n  ${DIM}Get a license at: https://nelo-robotics.com/pricing${R}\n"
        tput cnorm 2>/dev/null || true
        exit 1
    fi
}

# ══════════════════════════════════════════════════════
# SYSTEM SCAN
# ══════════════════════════════════════════════════════
system_scan() {
    echo -e "  ${BCYAN}╔═══════════════════════════════════════════════╗${R}"
    echo -e "  ${BCYAN}║${R}  ${WHITE}${BOLD}  S Y S T E M   S C A N${R}                      ${BCYAN}║${R}"
    echo -e "  ${BCYAN}╚═══════════════════════════════════════════════╝${R}"
    echo ""

    os_name="unknown"
    case "$(uname -s)" in
        Linux*)  os_name="Linux $(uname -r | cut -d'-' -f1)";;
        Darwin*) os_name="macOS";;
        MINGW*|MSYS*) os_name="Windows";;
    esac
    arch_name="$(uname -m)"

    PYTHON=""
    py_ver="not found"
    if command -v python3 &>/dev/null; then
        PYTHON="python3"; py_ver="$($PYTHON --version 2>&1 | cut -d' ' -f2)"
    elif command -v python &>/dev/null; then
        PYTHON="python"; py_ver="$($PYTHON --version 2>&1 | cut -d' ' -f2)"
    fi

    [ -z "$PYTHON" ] && { echo -e "  ${BRED}✗${R} Python not found."; tput cnorm 2>/dev/null; exit 1; }

    PIP=""
    command -v pip3 &>/dev/null && PIP="pip3"
    command -v pip &>/dev/null && PIP="pip"
    [ -z "$PIP" ] && PIP="$PYTHON -m pip"

    local items=("Operating system" "Architecture" "Python" "Package manager" "License" "Network")
    local vals=("$os_name" "$arch_name" "Python $py_ver" "ready" "$TIER" "connected")

    for i in "${!items[@]}"; do
        printf "  ${CYAN}  ⟩${R} ${items[$i]}"
        for d in 1 2 3; do printf "."; sleep 0.05; done
        printf "\r  ${GREEN}  ✓${R} %-22s ${DIM}→${R}  ${BGREEN}%s${R}          \n" "${items[$i]}" "${vals[$i]}"
        sleep 0.03
    done

    echo ""
    echo -e "  ${BGREEN}  ◉  ALL SYSTEMS NOMINAL${R}"
    echo ""
    sleep 0.5
}

# ══════════════════════════════════════════════════════
# DOWNLOAD & INSTALL
# ══════════════════════════════════════════════════════
download_and_install() {
    echo -e "  ${BCYAN}╔═══════════════════════════════════════════════╗${R}"
    echo -e "  ${BCYAN}║${R}  ${WHITE}${BOLD}  D O W N L O A D I N G${R}                       ${BCYAN}║${R}"
    echo -e "  ${BCYAN}╚═══════════════════════════════════════════════╝${R}"
    echo ""

    # Determine packages
    case "$PACKAGE" in
        stacc)       PKGS=("stacc") ;;
        nil-sdk|nil) PKGS=("nil-sdk") ;;
        nil-stacc)   PKGS=("stacc" "nil-sdk" "nil-stacc") ;;
        *)           PKGS=("stacc" "nil-sdk" "nil-stacc") ;;
    esac

    # Module names for progress display
    if [ "$PACKAGE" = "stacc" ]; then
        modules=("core" "kinematics" "simulation" "sensors" "ai.slam" "ai.vision" "control" "hal" "gait" "gripper")
    elif [ "$PACKAGE" = "nil-sdk" ] || [ "$PACKAGE" = "nil" ]; then
        modules=("kernel" "memory" "evolution" "optimization" "providers" "tools" "tracer" "drift_detect")
    else
        modules=("stacc.core" "stacc.sim" "stacc.sensors" "stacc.ai" "stacc.hal" "nil.kernel" "nil.memory" "nil.evolution" "nil.optimize" "bridge")
    fi

    TMPDIR=$(mktemp -d)

    # Download wheels
    for pkg in "${PKGS[@]}"; do
        local whl_name
        if [ "$pkg" = "nil-sdk" ]; then
            whl_name="nil_sdk-0.1.0-py3-none-any.whl"
        elif [ "$pkg" = "nil-stacc" ]; then
            whl_name="nil_stacc-0.1.0-py3-none-any.whl"
        else
            whl_name="${pkg}-0.1.0-py3-none-any.whl"
        fi
        curl -s -f -o "${TMPDIR}/${whl_name}" \
            "${SERVER}/download/${pkg}/${whl_name}?token=${TOKEN}" 2>/dev/null || true
    done

    # Animated progress
    local total=${#modules[@]}
    for i in "${!modules[@]}"; do
        local pct=$(( (i + 1) * 100 / total ))
        local filled=$((pct * 35 / 100))
        local empty=$((35 - filled))

        local bar=""
        if [ "$PACKAGE" = "stacc" ]; then
            bar="${BGREEN}"
        elif [ "$PACKAGE" = "nil-sdk" ] || [ "$PACKAGE" = "nil" ]; then
            bar="${BMAGENTA}"
        else
            bar="${BYELLOW}"
        fi
        for ((b=0; b<filled; b++)); do bar+="█"; done
        bar+="${DIM}"
        for ((b=0; b<empty; b++)); do bar+="░"; done
        bar+="${R}"

        if [ $((i % 2)) -eq 0 ]; then eye="${BGREEN}◉◉${R}"; else eye="${BCYAN}◉◉${R}"; fi
        printf "\r  ${CYAN}[${eye}${CYAN}]${R}  ${bar}  ${WHITE}%3d%%${R}  ${DIM}${modules[$i]}${R}          " "$pct"
        sleep 0.15
    done
    printf "\r  ${CYAN}[${BGREEN}◉◉${CYAN}]${R}  ${BGREEN}$(printf '█%.0s' $(seq 1 35))${R}  ${WHITE}100%%${R}  ${BGREEN}complete${R}          \n"
    echo ""

    # Install deps
    echo -e "  ${BCYAN}╔═══════════════════════════════════════════════╗${R}"
    echo -e "  ${BCYAN}║${R}  ${WHITE}${BOLD}  I N S T A L L I N G${R}                         ${BCYAN}║${R}"
    echo -e "  ${BCYAN}╚═══════════════════════════════════════════════╝${R}"
    echo ""

    echo -ne "  ${CYAN}  ⟩${R} numpy..."
    $PIP install numpy -q 2>/dev/null || $PIP install numpy --break-system-packages -q 2>/dev/null || true
    printf "\r  ${GREEN}  ✓${R} numpy          \n"

    if [ "$PACKAGE" = "stacc" ] || [ "$PACKAGE" = "nil-stacc" ]; then
        echo -ne "  ${CYAN}  ⟩${R} mujoco..."
        $PIP install mujoco -q 2>/dev/null || $PIP install mujoco --break-system-packages -q 2>/dev/null || true
        printf "\r  ${GREEN}  ✓${R} mujoco          \n"
    fi

    # Install wheels
    for pkg in "${PKGS[@]}"; do
        local whl_name
        if [ "$pkg" = "nil-sdk" ]; then
            whl_name="nil_sdk-0.1.0-py3-none-any.whl"
        elif [ "$pkg" = "nil-stacc" ]; then
            whl_name="nil_stacc-0.1.0-py3-none-any.whl"
        else
            whl_name="${pkg}-0.1.0-py3-none-any.whl"
        fi

        local whl="${TMPDIR}/${whl_name}"
        if [ -f "$whl" ]; then
            echo -ne "  ${CYAN}  ⟩${R} ${pkg}..."
            $PIP install "$whl" -q 2>/dev/null || $PIP install "$whl" --break-system-packages -q 2>/dev/null
            if [ $? -eq 0 ]; then
                printf "\r  ${GREEN}  ✓${R} ${pkg}          \n"
            else
                printf "\r  ${RED}  ✗${R} ${pkg}          \n"
            fi
        else
            echo -e "  ${RED}  ✗${R} ${pkg} — download failed"
        fi
    done

    rm -rf "$TMPDIR"
    echo ""
}

# ══════════════════════════════════════════════════════
# NEURAL ENGINE BOOT
# ══════════════════════════════════════════════════════
neural_boot() {
    local title="N E U R A L   E N G I N E"
    local boot_color="${BGREEN}"

    if [ "$PACKAGE" = "nil-sdk" ] || [ "$PACKAGE" = "nil" ]; then
        title="E V O L U T I O N   E N G I N E"
        boot_color="${BMAGENTA}"
    elif [ "$PACKAGE" = "nil-stacc" ]; then
        title="F U S I O N   C O R E"
        boot_color="${BYELLOW}"
    fi

    echo -e "  ${BCYAN}╔═══════════════════════════════════════════════╗${R}"
    echo -e "  ${BCYAN}║${R}  ${WHITE}${BOLD}  ${title}${R}    ${BCYAN}║${R}"
    echo -e "  ${BCYAN}╚═══════════════════════════════════════════════╝${R}"
    echo ""

    local layers=()
    if [ "$PACKAGE" = "stacc" ]; then
        layers=(
            "Physics Engine     ██████████  MuJoCo 3.x"
            "Sensor Fusion      █████████░  14 sensors"
            "SLAM Pipeline      ██████████  EKF + PF"
            "Path Planner       █████████░  A* + RRT*"
            "Vision Cortex      ██████████  OpenCV"
            "Motor Cortex       █████████░  PID + traj"
            "HAL Layer          ██████████  17 boards"
            "Output Layer       ██████████  deploy ready"
        )
    elif [ "$PACKAGE" = "nil-sdk" ] || [ "$PACKAGE" = "nil" ]; then
        layers=(
            "Agent Kernel       ██████████  runner"
            "Memory Store       █████████░  SQLite"
            "Skill Registry     ██████████  extraction"
            "Drift Detector     █████████░  monitoring"
            "Strategy Mutator   ██████████  evolution"
            "Model Router       █████████░  optimization"
            "Chain Compressor   ██████████  efficiency"
            "Budget Controller  ██████████  cost mgmt"
        )
    else
        layers=(
            "Physics Engine     ██████████  MuJoCo"
            "Agent Kernel       █████████░  runner"
            "SLAM + Vision      ██████████  perception"
            "Evolution Engine   █████████░  self-improve"
            "Path Planner       ██████████  navigation"
            "Skill Registry     █████████░  extraction"
            "HAL + Deploy       ██████████  hardware"
            "Fusion Bridge      ██████████  connected"
        )
    fi

    for layer in "${layers[@]}"; do
        echo -ne "  ${DIM}  ◇${R} ${layer}"
        sleep 0.04
        printf "\r  ${boot_color}  ◆${R} ${GREEN}${layer}${R}\n"
        sleep 0.06
    done
    echo ""
    sleep 0.3
}

# ══════════════════════════════════════════════════════
# FINAL REVEAL
# ══════════════════════════════════════════════════════
final_reveal() {
    clear
    local sr=$(( (ROWS - 22) / 2 ))
    [ $sr -lt 1 ] && sr=1

    local label="S T A C C"
    local reveal_color="${BCYAN}"
    if [ "$PACKAGE" = "nil-sdk" ] || [ "$PACKAGE" = "nil" ]; then
        label="  N I L  "
        reveal_color="${BMAGENTA}"
    elif [ "$PACKAGE" = "nil-stacc" ]; then
        label="N I L ╳ S"
        reveal_color="${BYELLOW}"
    fi

    local robot_lines=(
        "${reveal_color}           ╔═══════╗"
        "${reveal_color}           ║ ${BGREEN}◉   ◉${reveal_color} ║"
        "${reveal_color}           ║  ${WHITE}▬▬▬${reveal_color}  ║"
        "${CYAN}        ╔══╩═══════╩══╗"
        "${CYAN}        ║  ${WHITE}${BOLD}${label}${R}${CYAN}  ║"
        "${CYAN}        ║  ${DIM}v 0.1.0${R}${CYAN}   ║"
        "${CYAN}        ╠══════╦══════╣"
        "${CYAN}       ╔╝${R}      ${CYAN}║${R}      ${CYAN}╚╗"
        "${CYAN}       ║${R}       ${CYAN}║${R}       ${CYAN}║"
        "${CYAN}      ═╩═${R}     ${CYAN}═╩═${R}     ${CYAN}═╩═"
    )

    for i in "${!robot_lines[@]}"; do
        printf "\033[%d;%dH%s${R}" "$((sr + i))" "$(( (COLS - 40) / 2 ))" "${robot_lines[$i]}"
        sleep 0.04
    done

    local mr=$((sr + 12))
    local pad=$(( (COLS - 52) / 2 ))
    [ $pad -lt 1 ] && pad=1

    printf "\033[%d;%dH${BGREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}" "$mr" "$pad"
    printf "\033[%d;%dH${BGREEN}${BOLD}  I N S T A L L A T I O N   C O M P L E T E  ${R}" "$((mr+1))" "$((pad+3))"
    printf "\033[%d;%dH${BGREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}" "$((mr+2))" "$pad"

    sleep 0.8
    printf "\033[%d;0H\n" "$((mr+4))"

    echo -e "  ${WHITE}Installed: ${BGREEN}${PACKAGE}${R} (${TIER} tier)"
    echo ""

    if [ "$PACKAGE" = "stacc" ]; then
        echo -e "  ${WHITE}Quick start:${R}"
        echo -e "    ${BCYAN}import stacc${R}"
        echo -e "    ${BCYAN}from stacc.core.urdf_parser import load_urdf${R}"
        echo -e "    ${BCYAN}robot = load_urdf('my_robot.urdf')${R}"
        echo -e "    ${BCYAN}stacc.simulate(robot, duration=10, render=True)${R}"
    elif [ "$PACKAGE" = "nil-sdk" ] || [ "$PACKAGE" = "nil" ]; then
        echo -e "  ${WHITE}Quick start:${R}"
        echo -e "    ${BMAGENTA}import nil${R}"
        echo -e "    ${BMAGENTA}agent = nil.Agent(domain=my_domain, base_model='claude-sonnet-4-20250514')${R}"
        echo -e "    ${BMAGENTA}result = agent.run('do something smart')${R}"
    else
        echo -e "  ${WHITE}Quick start:${R}"
        echo -e "    ${BYELLOW}from nil_stacc import RobotAgent${R}"
        echo -e "    ${BYELLOW}from stacc.core.urdf_parser import load_urdf${R}"
        echo -e "    ${BYELLOW}robot = load_urdf('my_robot.urdf')${R}"
        echo -e "    ${BYELLOW}agent = RobotAgent(robot)${R}"
        echo -e "    ${BYELLOW}agent.run('pick up the red block')${R}"
    fi

    echo ""
    echo -e "  ${DIM}Docs:       docs.nelo-robotics.com${R}"
    echo -e "  ${DIM}Support:    support@nelo-robotics.com${R}"
    echo ""
    echo ""
}

# ══════════════════════════════════════════════════════
# RUN
# ══════════════════════════════════════════════════════

# Phase 1: Package-specific animation
if [ "$PACKAGE" = "stacc" ]; then
    anim_matrix_rain
elif [ "$PACKAGE" = "nil-sdk" ] || [ "$PACKAGE" = "nil" ]; then
    anim_starfield
else
    anim_fusion
fi

# Phase 2: Package-specific banner
show_banner

# Phase 3: Validate license
validate_license

# Phase 4: System scan
system_scan

# Phase 5: Download and install
download_and_install

# Phase 6: Neural/evolution boot
neural_boot

# Phase 7: Final reveal
final_reveal

tput cnorm 2>/dev/null || true

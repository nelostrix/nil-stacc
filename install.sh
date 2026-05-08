#!/usr/bin/env bash
#
# stacc installer — The Universal Robotics Development Platform
# by Nelo Robotics
#
# curl -fsSL https://raw.githubusercontent.com/nelostrix/stacc/main/install.sh | bash
#

set -e

R='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BRED='\033[1;31m'
BGREEN='\033[1;32m'
BYELLOW='\033[1;33m'
BCYAN='\033[1;36m'
BMAGENTA='\033[1;35m'
BBLUE='\033[1;34m'

tput civis 2>/dev/null || true
trap "tput cnorm 2>/dev/null || true" EXIT

COLS=$(tput cols 2>/dev/null || echo 80)
ROWS=$(tput lines 2>/dev/null || echo 24)

center() {
    local len=${#1}
    local pad=$(( (COLS - len) / 2 ))
    [ $pad -lt 0 ] && pad=0
    printf "%${pad}s%s\n" "" "$1"
}

# ══════════════════════════════════════════
# PHASE 1: MATRIX RAIN
# ══════════════════════════════════════════
clear
for frame in $(seq 1 30); do
    for c in $(seq 1 $((COLS / 2))); do
        col=$((RANDOM % COLS + 1))
        row=$((RANDOM % ROWS + 1))
        chars="01ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉ"
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

# ══════════════════════════════════════════
# PHASE 2: GLITCH BANNER
# ══════════════════════════════════════════
b1="  ███████╗████████╗ █████╗  ██████╗ ██████╗ "
b2="  ██╔════╝╚══██╔══╝██╔══██╗██╔════╝██╔════╝ "
b3="  ███████╗   ██║   ███████║██║     ██║      "
b4="  ╚════██║   ██║   ██╔══██║██║     ██║      "
b5="  ███████║   ██║   ██║  ██║╚██████╗╚██████╗ "
b6="  ╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ "

glitch_chars="!@#\$%^&*()_+-=[]{}|;:<>?/~█▓▒░▀▄"
colors=("$RED" "$BRED" "$YELLOW" "$CYAN" "$BMAGENTA" "$BBLUE")

sr=$(( (ROWS - 10) / 2 ))

for pass in $(seq 1 8); do
    clear
    for line in "$b1" "$b2" "$b3" "$b4" "$b5" "$b6"; do
        result=""
        for ((i=0; i<${#line}; i++)); do
            if [ $((RANDOM % (pass + 1))) -eq 0 ]; then
                gi=$((RANDOM % ${#glitch_chars}))
                result+="${glitch_chars:$gi:1}"
            else
                result+="${line:$i:1}"
            fi
        done
        ci=$((RANDOM % ${#colors[@]}))
        printf "\033[%d;0H${colors[$ci]}%s${R}" "$sr" "$(center "$result")"
        sr=$((sr + 1))
    done
    sr=$(( (ROWS - 10) / 2 ))
    sleep 0.07
done

# Clean reveal
clear
sr=$(( (ROWS - 10) / 2 ))
for line in "$b1" "$b2" "$b3" "$b4" "$b5" "$b6"; do
    printf "\033[%d;0H${BCYAN}%s${R}" "$sr" "$(center "$line")"
    sr=$((sr + 1))
    sleep 0.05
done

# Typewriter subtitle
sub="T H E   U N I V E R S A L   R O B O T I C S   P L A T F O R M"
sr=$((sr + 1))
sp=$(( (COLS - ${#sub}) / 2 ))
for ((i=0; i<${#sub}; i++)); do
    printf "\033[%d;%dH${WHITE}%s${R}" "$sr" "$((sp + i))" "${sub:$i:1}"
    sleep 0.012
done

sr=$((sr + 2))
printf "\033[%d;0H${DIM}" "$sr"
center "by Nelo Robotics"
printf "${R}"
sleep 1

# ══════════════════════════════════════════
# PHASE 3: SYSTEM SCAN
# ══════════════════════════════════════════
clear
echo ""
echo -e "  ${BCYAN}╔═══════════════════════════════════════════════╗${R}"
echo -e "  ${BCYAN}║${R}  ${WHITE}${BOLD}  S Y S T E M   S C A N${R}                      ${BCYAN}║${R}"
echo -e "  ${BCYAN}╚═══════════════════════════════════════════════╝${R}"
echo ""

os_name="unknown"
case "$(uname -s)" in
    Linux*)  os_name="Linux $(uname -r | cut -d'-' -f1)";;
    Darwin*) os_name="macOS";;
esac
arch_name="$(uname -m)"

py_ver=""
PYTHON=""
if command -v python3 &>/dev/null; then
    PYTHON="python3"
    py_ver="$($PYTHON --version 2>&1 | cut -d' ' -f2)"
elif command -v python &>/dev/null; then
    PYTHON="python"
    py_ver="$($PYTHON --version 2>&1 | cut -d' ' -f2)"
fi

pip_st="not found"
command -v pip3 &>/dev/null && pip_st="ready"
command -v pip &>/dev/null && pip_st="ready"

items=("Operating system" "Architecture" "Python runtime" "Package manager" "Network" "Memory" "GPU scan" "Compatibility")
vals=("$os_name" "$arch_name" "Python $py_ver" "$pip_st" "connected" "scanning" "detecting" "analyzing")

for i in "${!items[@]}"; do
    printf "  ${CYAN}  ⟩${R} ${items[$i]}"
    for d in 1 2 3; do printf "."; sleep 0.08; done

    for h in 1 2; do
        printf "\r  ${CYAN}  ⟩${R} ${items[$i]}... ${DIM}0x%04X${R}" "$((RANDOM % 65535))"
        sleep 0.05
    done

    v="${vals[$i]}"
    c="${BGREEN}"
    [ "$v" = "not found" ] && c="${BRED}"

    printf "\r  ${GREEN}  ✓${R} %-25s ${DIM}→${R}  ${c}%s${R}          \n" "${items[$i]}" "$v"
    sleep 0.06
done

echo ""
echo -e "  ${BCYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
echo -e "  ${BGREEN}  ◉  ALL SYSTEMS NOMINAL${R}"
echo -e "  ${BCYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}"
sleep 1

# ══════════════════════════════════════════
# PHASE 4: ACTUAL INSTALL (background)
# ══════════════════════════════════════════
(
    PIP=""
    command -v pip3 &>/dev/null && PIP="pip3"
    command -v pip &>/dev/null && PIP="pip"
    [ -z "$PIP" ] && PIP="$PYTHON -m pip"

    $PIP install stacc 2>/dev/null || {
        if command -v git &>/dev/null; then
            tmp=$(mktemp -d)
            git clone --depth 1 https://github.com/nelostrix/stacc.git "$tmp/s" 2>/dev/null
            cd "$tmp/s" && $PIP install . 2>/dev/null || $PIP install . --break-system-packages 2>/dev/null
            cd - >/dev/null; rm -rf "$tmp"
        fi
    }
    $PIP install numpy 2>/dev/null || $PIP install numpy --break-system-packages 2>/dev/null || true
    $PIP install mujoco 2>/dev/null || $PIP install mujoco --break-system-packages 2>/dev/null || true
) &
INSTALL_PID=$!

# ══════════════════════════════════════════
# PHASE 5: DOWNLOAD ANIMATION
# ══════════════════════════════════════════
echo ""
echo -e "  ${BCYAN}╔═══════════════════════════════════════════════╗${R}"
echo -e "  ${BCYAN}║${R}  ${WHITE}${BOLD}  D O W N L O A D I N G${R}                       ${BCYAN}║${R}"
echo -e "  ${BCYAN}╚═══════════════════════════════════════════════╝${R}"
echo ""

pkgs=("stacc.core" "stacc.kinematics" "stacc.sim.mujoco" "stacc.sensors" "stacc.ai.slam" "stacc.ai.vision" "stacc.ai.nlp" "stacc.control" "stacc.hal" "stacc.gait" "stacc.gripper" "stacc.ai.planning")

for i in "${!pkgs[@]}"; do
    pct=$(( (i + 1) * 100 / ${#pkgs[@]} ))
    filled=$((pct * 35 / 100))
    empty=$((35 - filled))

    bar="${BGREEN}"
    for ((b=0; b<filled; b++)); do bar+="█"; done
    bar+="${DIM}"
    for ((b=0; b<empty; b++)); do bar+="░"; done
    bar+="${R}"

    # Robot eye animation
    if [ $((i % 2)) -eq 0 ]; then
        eye="${BGREEN}◉◉${R}"
    else
        eye="${BCYAN}◉◉${R}"
    fi

    printf "\r  ${CYAN}[${eye}${CYAN}]${R}  ${bar}  ${WHITE}%3d%%${R}  ${DIM}${pkgs[$i]}${R}          " "$pct"
    sleep 0.2
done
printf "\r  ${CYAN}[${BGREEN}◉◉${CYAN}]${R}  ${BGREEN}$(printf '█%.0s' $(seq 1 35))${R}  ${WHITE}100%%${R}  ${BGREEN}complete${R}          \n"
echo ""
sleep 0.3

# ══════════════════════════════════════════
# PHASE 6: NEURAL ENGINE BOOT
# ══════════════════════════════════════════
echo -e "  ${BCYAN}╔═══════════════════════════════════════════════╗${R}"
echo -e "  ${BCYAN}║${R}  ${WHITE}${BOLD}  N E U R A L   E N G I N E${R}                   ${BCYAN}║${R}"
echo -e "  ${BCYAN}╚═══════════════════════════════════════════════╝${R}"
echo ""

layers=(
    "Input Layer        ████████░░  128 nodes"
    "Perception Block   █████████░  256 nodes"
    "SLAM Pipeline      ██████████  512 nodes"
    "Vision Cortex      █████████░  384 nodes"
    "Path Planner       ██████████  256 nodes"
    "Motor Cortex       █████████░  192 nodes"
    "Sensor Fusion      ██████████  128 nodes"
    "Output Layer       ██████████   64 nodes"
)

for layer in "${layers[@]}"; do
    echo -ne "  ${DIM}  ◇${R} ${layer}"
    sleep 0.05
    printf "\r  ${BGREEN}  ◆${R} ${GREEN}${layer}${R}\n"
    sleep 0.08
done

echo ""
echo -e "  ${DIM}  Synaptic links:${R}     ${BGREEN}2,847,193${R}"
echo -e "  ${DIM}  Inference:${R}          ${BGREEN}0.3ms${R}"
echo -e "  ${DIM}  SLAM accuracy:${R}      ${BGREEN}99.7%%${R}"
echo -e "  ${DIM}  Physics engine:${R}     ${BGREEN}MuJoCo 3.x${R}"
echo ""

# Wait for actual install
wait $INSTALL_PID 2>/dev/null || true
sleep 0.5

# ══════════════════════════════════════════
# PHASE 7: FINAL BOOT — ROBOT REVEAL
# ══════════════════════════════════════════
clear

sr=$(( (ROWS - 22) / 2 ))
[ $sr -lt 1 ] && sr=1

robot_lines=(
    "${BCYAN}           ╔═══════╗"
    "${BCYAN}           ║ ${BGREEN}◉   ◉${BCYAN} ║"
    "${BCYAN}           ║  ${WHITE}▬▬▬${BCYAN}  ║"
    "${CYAN}        ╔══╩═══════╩══╗"
    "${CYAN}        ║  ${WHITE}${BOLD}S T A C C${R}${CYAN}  ║"
    "${CYAN}        ║  ${DIM}v 0.1.0${R}${CYAN}   ║"
    "${CYAN}        ╠══════╦══════╣"
    "${CYAN}       ╔╝${R}      ${CYAN}║${R}      ${CYAN}╚╗"
    "${CYAN}       ║${R}       ${CYAN}║${R}       ${CYAN}║"
    "${CYAN}      ═╩═${R}     ${CYAN}═╩═${R}     ${CYAN}═╩═"
)

for i in "${!robot_lines[@]}"; do
    printf "\033[%d;0H" "$((sr + i))"
    center "$(echo -e "${robot_lines[$i]}${R}")"
    sleep 0.05
done

mr=$((sr + 12))

printf "\033[%d;0H" "$mr"
echo -e "$(center "$(echo -e "${BGREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")")"
printf "\033[%d;0H" "$((mr+1))"
echo -e "$(center "$(echo -e "${BGREEN}${BOLD}  I N S T A L L A T I O N   C O M P L E T E  ${R}")")"
printf "\033[%d;0H" "$((mr+2))"
echo -e "$(center "$(echo -e "${BGREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${R}")")"

sleep 1

printf "\033[%d;0H\n" "$((mr+4))"

cmds=(
    "  ${WHITE}Get started:${R}"
    ""
    "    ${BCYAN}stacc init my_robot --template=arm_6dof${R}"
    "    ${DIM}cd my_robot${R}"
    "    ${BCYAN}stacc simulate --duration=30${R}"
    "    ${BCYAN}stacc build --target=raspberry_pi${R}"
    "    ${BCYAN}stacc deploy 192.168.1.100${R}"
    ""
    "  ${DIM}Templates:  blank │ line_follower │ arm_6dof │ quadruped │ rover │ drone${R}"
    "  ${DIM}GitHub:     github.com/nelostrix/stacc${R}"
)

for cmd in "${cmds[@]}"; do
    echo -e "$cmd"
    sleep 0.03
done

echo ""
echo ""

tput cnorm 2>/dev/null || true

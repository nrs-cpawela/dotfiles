#!/usr/bin/env zsh
# ============================================================
# Brewless cask installer — for Macs without Homebrew (Intel)
# ============================================================
# Homebrew is Tier 3 on Intel macOS, but its cask metadata API
# (formulae.brew.sh) still describes where each app lives, its sha256, and the
# Intel build under OS-codename variations. This script reuses that metadata to
# install the `cask "…"` lines of a Brewfile without brew itself.
#
# Supported artifacts: app (→ $APPDIR), font (→ $FONTDIR), and binaries inside
# an app bundle (symlink → $BINDIR). Completions, manpages, uninstall and zap
# stanzas are ignored. Any other artifact (pkg, installer, suite, standalone
# binary, …) fails that cask with a message.
#
# Usage: cask.sh <Brewfile>     (invoked via make mise-bundle)
#   APPDIR=/Applications  FONTDIR=~/Library/Fonts  BINDIR=~/.local/bin
# ============================================================

set -euo pipefail

APPDIR="${APPDIR:-/Applications}"
FONTDIR="${FONTDIR:-$HOME/Library/Fonts}"
BINDIR="${BINDIR:-$HOME/.local/bin}"
API="https://formulae.brew.sh/api/cask"

GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; RESET=$'\033[0m'


# Flatten a cask's JSON into tab-separated lines the shell can loop over,
# applying the variation for this macOS version + CPU the way brew would.
plan() {
  python3 - "$1" "$(uname -m)" "$(sw_vers -productVersion)" <<'PY'
import json, sys
path, arch, osver = sys.argv[1:]
d = json.load(open(path))
codenames = {27: "golden_gate", 26: "tahoe", 15: "sequoia", 14: "sonoma",
             13: "ventura", 12: "monterey", 11: "big_sur"}
major = int(osver.split(".")[0])
prefix = "arm64_" if arch == "arm64" else ""
# Exact tag match only, like Homebrew::API.merge_variations: the API omits
# variations identical to the top-level default.
d.update((d.get("variations") or {}).get(prefix + codenames.get(major, ""), {}))
print(f"url\t{d['url']}")
print(f"sha256\t{d.get('sha256') or 'no_check'}")
ignored = {"uninstall", "zap", "manpage", "bash_completion", "zsh_completion",
           "fish_completion", "preflight", "postflight", "uninstall_preflight",
           "uninstall_postflight"}
for a in d.get("artifacts", []):
    kind = next(k for k in a if k != "target")
    if kind in ignored:
        continue
    src = a[kind][0] if isinstance(a[kind], list) and a[kind] else a[kind]
    tgt = a.get("target") or (a[kind][1].get("target") if isinstance(a[kind], list)
           and len(a[kind]) > 1 and isinstance(a[kind][1], dict) else None)
    name = (tgt or str(src)).rstrip("/").rsplit("/", 1)[-1]
    if kind in ("app", "font") or (kind == "binary" and str(src).startswith("$APPDIR/")):
        print(f"{kind}\t{src}\t{name}")
    else:
        print(f"unsupported\t{kind}")
PY
}

# Symlink CLI binaries that live inside an installed app bundle into $BINDIR.
# Reads the caller's $bins (zsh locals are dynamically scoped).
link_bins() {
  local e src name
  for e in $bins; do
    src="$APPDIR/${${e%%|*}#\$APPDIR/}"; name=${e#*|}
    [[ -e $src && ! -e "$BINDIR/$name" && ! -L "$BINDIR/$name" ]] || continue
    mkdir -p "$BINDIR"
    ln -s "$src" "$BINDIR/$name"
    printf "  ${GREEN}✓ %s → %s${RESET}\n" "$name" "$BINDIR"
  done
}

install_cask() {
  # errexit inside a function exits the shell without running `always`;
  # err_return makes failures return instead so cleanup still happens.
  setopt localoptions err_return no_err_exit
  local cask="$1" tmp json url sha kind src name stage mnt=""
  tmp=$(mktemp -d)
  {
    json="$tmp/cask.json"
    curl -fsSL "$API/$cask.json" -o "$json"

    local -a apps fonts bins
    while IFS=$'\t' read -r kind src name; do
      case $kind in
        url)         url=$src ;;
        sha256)      sha=$src ;;
        app)         apps+=("$src|$name") ;;
        font)        fonts+=("$src|$name") ;;
        binary)      bins+=("$src|$name") ;;
        unsupported) print -u2 "${RED}✗ $cask: '$src' artifact needs Homebrew — install it manually${RESET}"; return 1 ;;
      esac
    done < <(plan "$json")

    # Skip the download when every app and font is already present
    # (app-bundle binaries are satisfied by their app, so link them first).
    (( ${#apps} + ${#fonts} )) || { print -u2 "${RED}✗ $cask: no app or font artifact to install${RESET}"; return 1; }
    link_bins
    local missing=0 e
    for e in $apps;  do [[ -e "$APPDIR/${e#*|}" ]]  || missing=1; done
    for e in $fonts; do [[ -e "$FONTDIR/${e#*|}" ]] || missing=1; done
    if (( ! missing )); then
      printf "${GREEN}✓ %s already installed${RESET}\n" "$cask"
      return 0
    fi

    printf "${YELLOW}→ Installing %s from %s${RESET}\n" "$cask" "$url"
    local dl="$tmp/download"
    curl -fL --retry 3 --progress-bar "$url" -o "$dl"
    if [[ $sha == no_check ]]; then
      print -u2 "${YELLOW}! $cask publishes no sha256 — skipping checksum${RESET}"
    elif [[ $(shasum -a 256 "$dl" | cut -d' ' -f1) != "$sha" ]]; then
      print -u2 "${RED}✗ $cask: sha256 mismatch${RESET}"
      return 1
    fi

    # Unpack by content, not URL suffix (many cask URLs have no extension).
    stage="$tmp/stage"; mkdir -p "$stage"
    if hdiutil imageinfo "$dl" &>/dev/null; then
      mnt="$tmp/mnt"; mkdir -p "$mnt"
      hdiutil attach -quiet -nobrowse -readonly -noautoopen -mountpoint "$mnt" "$dl"
      stage="$mnt"
    elif [[ $(file -b "$dl") == *Zip* ]]; then
      ditto -x -k "$dl" "$stage"
    else
      tar -xf "$dl" -C "$stage"
    fi

    for e in $apps; do
      src=${e%%|*}; name=${e#*|}
      [[ -e "$APPDIR/$name" ]] && { printf "  ${GREEN}✓ %s present${RESET}\n" "$name"; continue; }
      mkdir -p "$APPDIR"
      ditto "$stage/$src" "$APPDIR/$name"
      printf "  ${GREEN}✓ %s → %s${RESET}\n" "$name" "$APPDIR"
    done

    if (( ${#fonts} )); then
      mkdir -p "$FONTDIR"
      for e in $fonts; do
        src=${e%%|*}; name=${e#*|}
        [[ -e "$FONTDIR/$name" ]] && continue
        src=$(find "$stage" -name "${src:t}" -print -quit)
        [[ -n $src ]] || { print -u2 "${RED}✗ $cask: ${e%%|*} not in archive${RESET}"; return 1; }
        cp "$src" "$FONTDIR/$name"
      done
      printf "  ${GREEN}✓ %d fonts → %s${RESET}\n" ${#fonts} "$FONTDIR"
    fi

    link_bins
  } always {
    [[ -n $mnt ]] && hdiutil detach -quiet "$mnt" 2>/dev/null
    rm -rf "$tmp"
  }
}

# Each cask runs in its own process so `set -e` stays in force there (errexit is
# suppressed inside anything on the left of `||`).
if [[ ${1:-} == --one ]]; then
  install_cask "$2"
  exit
fi

[[ $# == 1 && -f "$1" ]] || { print -u2 "usage: ${0:t} <Brewfile>"; exit 2; }
casks=("${(@f)$(sed -nE 's/^[[:space:]]*cask[[:space:]]+"([^"]+)".*/\1/p' "$1")}")
casks=(${casks:#})
(( ${#casks} )) || exit 0

failed=()
for c in $casks; do
  zsh "${0:A}" --one "$c" || failed+=("$c")
done

if (( ${#failed} )); then
  print -u2 "${RED}✗ casks not installed: ${failed[*]}${RESET}"
  exit 1
fi

#!/usr/bin/env bash

# Zhyllan Fyllah | MIT License

set -eu

REPO="${MTK_REPO:-jirankun/media-toolkit}"
BRANCH="${MTK_BRANCH:-main}"
PREFIX="${MTK_PREFIX:-${XDG_DATA_HOME:-$HOME/.local/share}/media-toolkit}"
BIN="${MTK_BIN:-${XDG_BIN_HOME:-$HOME/.local/bin}}"
DO_PATH=1
DO_DEPS=1
ACTION=install

shell_name() {
    basename "${SHELL:-sh}"
}

shell_rc() {
    case $(shell_name) in
        zsh)  printf '%s' "$HOME/.zshrc" ;;
        bash) printf '%s' "$HOME/.bashrc" ;;
        fish) printf '%s' "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish" ;;
        *)    printf '%s' "$HOME/.profile" ;;
    esac
}

RC_FILE=$(shell_rc)

say() { printf '%s\n' "$*"; }
err() { printf 'error: %s\n' "$*" >&2; }
die() { err "$*"; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

detect_pm() {
    PM=''
    if have apt-get; then PM=apt
    elif have dnf; then PM=dnf
    elif have pacman; then PM=pacman
    elif have zypper; then PM=zypper
    elif have apk; then PM=apk
    elif have brew; then PM=brew
    fi
}

pm_label() {
    case $PM in
        apt)    printf '%s' 'apt (Debian/Ubuntu/Mint/Pop!_OS)' ;;
        dnf)    printf '%s' 'dnf (Fedora/RHEL/CentOS Stream)' ;;
        pacman) printf '%s' 'pacman (Arch/Manjaro/EndeavourOS/CachyOS)' ;;
        zypper) printf '%s' 'zypper (openSUSE)' ;;
        apk)    printf '%s' 'apk (Alpine)' ;;
        brew)   printf '%s' 'brew (macOS/Linuxbrew)' ;;
        *)      printf '%s' '' ;;
    esac
}

pm_deps() {
    case $PM in
        apt)    DEPS='ffmpeg imagemagick libjpeg-turbo-progs' ;;
        dnf)    DEPS='ffmpeg ImageMagick libjpeg-turbo-utils' ;;
        pacman) DEPS='ffmpeg imagemagick libjpeg-turbo' ;;
        zypper) DEPS='ffmpeg ImageMagick' ;;
        apk)    DEPS='ffmpeg imagemagick' ;;
        brew)   DEPS='ffmpeg imagemagick jpeg-turbo' ;;
        *)      DEPS='' ;;
    esac
}

pm_install_cmd() {
    PM_CMD=''
    case $PM in
        apt)    PM_CMD="apt-get install -y $DEPS" ;;
        dnf)    PM_CMD="dnf install -y $DEPS" ;;
        pacman) PM_CMD="pacman -S --needed --noconfirm $DEPS" ;;
        zypper) PM_CMD="zypper --non-interactive install $DEPS" ;;
        apk)    PM_CMD="apk add $DEPS" ;;
        brew)   PM_CMD="brew install $DEPS" ;;
    esac
    if [ "$(id -u)" -ne 0 ] && [ "$PM" != brew ] && have sudo; then
        PM_CMD="sudo $PM_CMD"
    fi
}

install_deps() {
    MISSING=''
    have ffmpeg || MISSING="$MISSING ffmpeg"
    have ffprobe || MISSING="$MISSING ffprobe"
    if ! have magick && ! have convert; then
        MISSING="$MISSING imagemagick"
    fi

    if [ -z "$MISSING" ]; then
        say "Dependencies: ffmpeg, ffprobe and ImageMagick are already installed"
        return 0
    fi

    detect_pm
    if [ -z "$PM" ]; then
        say "Dependencies missing:$MISSING"
        say "No supported package manager found. Install ffmpeg and ImageMagick manually."
        return 0
    fi

    pm_deps
    pm_install_cmd

    say "Dependencies missing:$MISSING"
    say "Installing with $(pm_label):"
    say "  $PM_CMD"

    if [ "${MTK_DRY_RUN:-0}" = 1 ]; then
        say "  (dry run, command not executed)"
        return 0
    fi

    if $PM_CMD; then
        say "Dependencies installed"
    else
        say "Dependency install failed. Retry later from the Setup menu (mt -> Setup)."
    fi
    return 0
}

usage() {
    cat <<EOF
Media Toolkit installer

Usage:
  install [options]

Options:
  --repo OWNER/REPO   GitHub repository (default: $REPO)
  --branch NAME       branch to download (default: $BRANCH)
  --prefix DIR        install directory (default: ${XDG_DATA_HOME:-~/.local/share}/media-toolkit)
  --bin DIR           command directory (default: ${XDG_BIN_HOME:-~/.local/bin})
  --no-path           do not touch shell rc files
  --no-deps           do not install ffmpeg / ImageMagick
  --uninstall         remove the installed copy and commands
  -h, --help          show this help

Examples:
  curl -fsSL https://raw.githubusercontent.com/$REPO/main/install | bash
  ./install --prefix ~/.local/share/media-toolkit --bin ~/.local/bin
  ./install --uninstall

Shell:
  PATH is added to the rc file of your login shell ($(shell_name) -> $RC_FILE).
EOF
}

while [ $# -gt 0 ]; do
    case $1 in
        --repo)    REPO=${2:-}; shift 2 ;;
        --branch)  BRANCH=${2:-}; shift 2 ;;
        --prefix)  PREFIX=${2:-}; shift 2 ;;
        --bin)     BIN=${2:-}; shift 2 ;;
        --no-path) DO_PATH=0; shift ;;
        --no-deps) DO_DEPS=0; shift ;;
        --uninstall) ACTION=uninstall; shift ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown option: $1 (try --help)" ;;
    esac
done

[ -n "$REPO" ] || die "empty repository name"
[ -n "$PREFIX" ] || die "empty install prefix"
[ -n "$BIN" ] || die "empty command directory"

case $PREFIX in
    /|"$HOME") die "refusing to install into $PREFIX" ;;
esac

if [ "$ACTION" = "uninstall" ]; then
    for n in mt media-toolkit; do
        rm -f "$BIN/$n"
    done
    rm -rf "$PREFIX"
    for rc in "$RC_FILE" "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile" \
              "${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"; do
        [ -f "$rc" ] || continue
        grep -q '# media-toolkit' "$rc" 2>/dev/null || continue
        awk -v p="export PATH=\"$BIN:\$PATH\"" -v f="set -gx PATH \"$BIN\" \$PATH" '
            $0 != "# media-toolkit" && $0 != p && $0 != f
        ' "$rc" > "$rc.tmp.$$"
        mv "$rc.tmp.$$" "$rc"
    done
    say "Removed $PREFIX and the mt / media-toolkit commands."
    exit 0
fi

command -v bash >/dev/null 2>&1 || die "bash is required"

HERE=$(cd -- "$(dirname -- "$0")" 2>/dev/null && pwd || printf '.')
SRC=''
if [ -f "$HERE/media-toolkit" ] && [ -f "$HERE/lib/core" ]; then
    SRC=$HERE
fi

CLEANUP=''
if [ -z "$SRC" ]; then
    TMP=$(mktemp -d 2>/dev/null || mktemp -d -t mtk) || die "cannot create a temporary directory"
    CLEANUP=$TMP
    URL="${MTK_TARBALL_URL:-https://codeload.github.com/$REPO/tar.gz/refs/heads/$BRANCH}"

    say "Downloading $REPO ($BRANCH) ..."
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$URL" -o "$TMP/repo.tar.gz" || die "download failed: $URL"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$TMP/repo.tar.gz" "$URL" || die "download failed: $URL"
    else
        die "curl or wget is required to download the toolkit"
    fi

    command -v tar >/dev/null 2>&1 || die "tar is required to unpack the toolkit"
    mkdir -p "$TMP/src"
    tar -xzf "$TMP/repo.tar.gz" -C "$TMP/src" || die "cannot extract the downloaded archive"

    FOUND=$(find "$TMP/src" -maxdepth 3 -type f -name media-toolkit -print 2>/dev/null | head -n 1)
    [ -n "$FOUND" ] && SRC=$(dirname "$FOUND")
    if [ -z "$SRC" ] || [ ! -f "$SRC/lib/core" ]; then
        die "the archive does not look like media-toolkit"
    fi
fi

cleanup() {
    if [ -n "$CLEANUP" ]; then
        rm -rf "$CLEANUP"
    fi
    return 0
}
trap cleanup EXIT INT TERM

say "Installing to $PREFIX"
mkdir -p "$PREFIX" "$BIN" || die "cannot create $PREFIX or $BIN"

if [ "$(cd -- "$PREFIX" && pwd -P)" != "$(cd -- "$SRC" && pwd -P)" ]; then
    rm -rf "$PREFIX/media-toolkit" "$PREFIX/lib"
    cp -a "$SRC/media-toolkit" "$PREFIX/media-toolkit" || die "copy failed"
    cp -a "$SRC/lib" "$PREFIX/lib" || die "copy failed"
    for extra in README.md LICENSE; do
        [ -f "$SRC/$extra" ] && cp -a "$SRC/$extra" "$PREFIX/$extra"
    done
    chmod +x "$PREFIX/media-toolkit"
fi

for name in mt media-toolkit; do
    printf '#!/usr/bin/env bash\nexec %q "$@"\n' "$PREFIX/media-toolkit" > "$BIN/$name" || die "cannot write $BIN/$name"
    chmod +x "$BIN/$name"
done

if [ "$DO_DEPS" -eq 1 ]; then
    install_deps
fi

if [ "$DO_PATH" -eq 1 ]; then
    case ":$PATH:" in
        *":$BIN:"*)
            say "$BIN is already on PATH"
            ;;
        *)
            mkdir -p "$(dirname "$RC_FILE")" 2>/dev/null || true
            if ! grep -q '# media-toolkit' "$RC_FILE" 2>/dev/null; then
                if [ -s "$RC_FILE" ] && [ "$(tail -c 1 "$RC_FILE" | wc -l)" -eq 0 ]; then
                    printf '\n' >> "$RC_FILE"
                fi
                case $(shell_name) in
                    fish)
                        printf '# media-toolkit\nset -gx PATH "%s" $PATH\n' "$BIN" >> "$RC_FILE"
                        ;;
                    *)
                        printf '# media-toolkit\nexport PATH="%s:$PATH"\n' "$BIN" >> "$RC_FILE"
                        ;;
                esac
            fi
            say "Added $BIN to PATH in $RC_FILE (shell: $(shell_name))"
            ;;
    esac
fi

say ""
say "Media Toolkit installed"
say "  code    : $PREFIX/media-toolkit"
say "  command : $BIN/mt"
say "            $BIN/media-toolkit"
say ""
say "Open a new terminal (or reload your shell config), then run:"
say "  mt"

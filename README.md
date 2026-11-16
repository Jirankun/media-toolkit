# Media Toolkit

A terminal toolkit for batch media work: format conversion, compression, repair,
audio extraction, and media inspection. The interface is a self-contained
bash + ANSI TUI with a black and purple theme — no `dialog`, no ncurses.

```
╭─ Media Toolkit  2.1.0 ───────────────────────╮
│ source: /home/user/videos                    │
├──────────────────────────────────────────────┤
│  ▸ Convert media      change container/codec │
│    Compress media     smaller target level   │
│    Repair media       fix containers         │
│    Extract audio      video → mp3 · flac     │
│    Media info         codec, resolution      │
│    Setup              install tools          │
│    About              author & license       │
├──────────────────────────────────────────────┤
│ ↑↓ move   ↵ select   1-9 jump   q quit      │
╰──────────────────────────────────────────────╯
```

## Features

- **Convert** — video (mp4, mkv, webm, mov, avi, gif), audio (mp3, wav, flac, ogg, m4a, aac, opus), images (png, jpg, webp, bmp, tiff, gif).
- **Compress** — Light / Balanced / Strong presets or your own percentage; video to H.264 + AAC, audio to MP3, images with a quality setting.
- **Repair** — fast remux, full re-encode, untrunc for MP4, metadata stripping, and lossless jpegtran.
- **Extract audio** — pull the audio track out of a video to mp3, m4a/aac, flac, wav, or opus.
- **Media info** — duration, size, container, bitrate, codecs, resolution, fps, and audio layout.
- **Setup & dependencies** — detect `apt/dnf/pacman/zypper/apk/brew`, install ffmpeg + ImageMagick, and install the `mt` launcher.
- **About** — author, license, and project links.

## Requirements

| Requirement | Notes |
|---|---|
| bash 4+ | present on virtually every distribution |
| ffmpeg + ffprobe | required for video and audio |
| ImageMagick (`magick` / `convert`) | required for images |
| jpegtran, untrunc | optional, used by specific repair modes |

Both the installer and the in-app **Setup & dependencies → Install dependencies**
fill in what is missing automatically. The command is chosen from the detected
package manager:

| Distribution family | Package manager | Packages installed |
|---|---|---|
| Debian, Ubuntu, Mint, Pop!_OS, Kali | `apt-get` | `ffmpeg imagemagick libjpeg-turbo-progs` |
| Fedora, RHEL, CentOS Stream, Rocky, Alma | `dnf` | `ffmpeg ImageMagick libjpeg-turbo-utils` |
| Arch, Manjaro, EndeavourOS, CachyOS, Garuda | `pacman` | `ffmpeg imagemagick libjpeg-turbo` |
| openSUSE Leap / Tumbleweed | `zypper` | `ffmpeg ImageMagick` |
| Alpine | `apk` | `ffmpeg imagemagick` |
| macOS, Linuxbrew | `brew` | `ffmpeg imagemagick jpeg-turbo` |
| anything else | — | install ffmpeg + ImageMagick manually |

On Fedora and RHEL, `ffmpeg` comes from RPM Fusion; enable it first if the
package cannot be found. `jpegtran` and `untrunc` are optional and are used only
by specific repair modes.

If something is missing, open **Setup & dependencies → Install dependencies** and
the toolkit will use your package manager.

## Installation

### Quick install

```sh
curl -fsSL https://raw.githubusercontent.com/jirankun/media-toolkit/main/install | bash
```

Open a new terminal afterwards and run:

```sh
mt
```

The installer also creates a `media-toolkit` command, so both names work.

### Manual install

```sh
git clone https://github.com/jirankun/media-toolkit.git
cd media-toolkit
./install
```

### Run without installing

```sh
./media-toolkit
```

### Installer options

```sh
./install --repo OWNER/REPO     # use a different GitHub repository
./install --branch dev          # use a different branch
./install --prefix DIR          # code location (default $XDG_DATA_HOME/media-toolkit)
./install --bin DIR             # command location (default $XDG_BIN_HOME)
./install --no-path             # do not modify shell rc files
./install --no-deps             # do not install ffmpeg / ImageMagick
./install --uninstall           # remove the installed copy and both commands
```

The installer downloads the repository archive with `curl` or `wget`, installs
it under `${XDG_DATA_HOME:-~/.local/share}/media-toolkit`, creates the `mt` and
`media-toolkit` commands in `${XDG_BIN_HOME:-~/.local/bin}`, installs missing
dependencies through your package manager (with `sudo` when needed), and adds
that directory to `PATH` when needed.

It follows the XDG user-directory layout, so no root access is required. To
install system-wide instead:

```sh
sudo ./install --prefix /usr/local/share/media-toolkit \
               --bin /usr/local/bin --no-path
```

### Shell detection

The installer reads your login shell from `$SHELL` and appends a single
`PATH` block at the end of that shell's rc file:

| Shell | File |
|---|---|
| zsh | `~/.zshrc` |
| bash | `~/.bashrc` |
| fish | `~/.config/fish/config.fish` |
| anything else | `~/.profile` |

The block is idempotent (added once) and is removed again by `--uninstall`.
Use `--no-path` to manage `PATH` yourself.

### Uninstall

```sh
curl -fsSL https://raw.githubusercontent.com/jirankun/media-toolkit/main/install | bash -s -- --uninstall
```

## Usage

```sh
mt
```

Navigation: `↑↓` / `j k`, `PgUp` `PgDn`, `Home` `End`, number keys `1-9` to jump,
`Enter` to choose, `q` / `Esc` to go back. In file lists: `Space` toggles a file
and `a` toggles all of them.

Progress is shown per batch with a live percentage bar, and every run is
appended to `outputs/toolkit.log`.

Results go to the folder you run the toolkit from:

```
outputs/
├── convert/
├── compress/
├── repair/
├── extract/
└── toolkit.log
```

Your source files are never modified.

## How it is built

```
media-toolkit      entry point and main menu
install            standalone installer
lib/ui             theme, menus, checklists, prompts, pager, progress bar
lib/core           paths, logging, dependency detection, file helpers
lib/convert        format conversion
lib/compress       compression presets and bitrate maths
lib/repair         container and stream repair
lib/extract        audio extraction
lib/info           media info, system info, about
lib/setup          dependency install and launcher management
README.md
LICENSE
```

The UI adapts to the terminal: 256 colours with a 16-colour fallback, UTF-8
box drawing with an ASCII fallback, and a numbered plain-text mode when the
output is not a terminal.

## License

MIT © 2026 Zhyllan Fyllah

- Website: <https://zhyllanfyllah.my.id>
- GitHub: [@jirankun](https://github.com/jirankun)

  > semua kode buatan saya sendiri, kecuali readme ini, karena saya tidak ada waktu lebih untuk membuat readme dengan mengamati kode🙏

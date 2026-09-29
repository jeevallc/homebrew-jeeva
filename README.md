# Jeeva Studio Homebrew tap

The tap contains installation metadata only. Release downloads require a Jeeva
key, and neither the R2 bucket nor its objects have public access enabled.

Before installing, save the key locally without putting it into shell history:

```sh
mkdir -p "$HOME/.config/jeeva"
chmod 700 "$HOME/.config/jeeva"
# macOS zsh: input is hidden.
read -rs 'jeeva_download_key?Jeeva download key: '
printf '\n'
(umask 077; printf 'Authorization: Bearer %s\n' "$jeeva_download_key" > "$HOME/.config/jeeva/download-header")
unset jeeva_download_key
```

The cask passes only the header-file path to curl. The secret is not embedded in
Git, the URL, Homebrew cask metadata, or curl's command arguments. Do not enable
curl tracing when downloading. Store this header file as a credential.

Install or upgrade:

```sh
brew tap jeevallc/jeeva
brew install --cask jeevallc/jeeva/jeeva-studio
brew upgrade --cask jeevallc/jeeva/jeeva-studio
```

Homebrew installs the app into `/Applications` by default. Where that directory is
not writable, use `--appdir="$HOME/Applications"`. The cask will install `Jeeva Studio.app` and link the
bundled `jeeva` CLI into Homebrew's bin directory.

Version 0.21.0 targets Apple Silicon and macOS 14 or later. The app and DMG are
signed, notarized and stapled. The CLI currently reports its crate version
(`jeeva-cli 0.1.0`); Homebrew tracks the application release version (`0.21.0`).
Revoking a download key blocks new downloads, not use of a previously downloaded
app or a copy in Homebrew's local cache.

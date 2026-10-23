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

Version 0.72.0 targets Apple Silicon and macOS 14 or later. The app and DMG are
signed, notarized and stapled. The CLI currently reports its crate version
(`jeeva-cli 0.1.0`); Homebrew tracks the application release version (`0.72.0`).
Revoking a download key blocks new downloads, not use of a previously downloaded
app or a copy in Homebrew's local cache.

## Licence delivery

Install and upgrade download a signed licence from the same key-protected
`downloads.jeeva.io` service as the app. The cask checks its SHA-256 and validity
window, then calls the installed app's `jeeva org licence install` command to
verify its signature and write `~/.config/jeeva/org/licence.json`. A failed
download, checksum, validity or signature check fails the step without replacing
an existing licence. Temporary downloads are removed. No licence or vendor
signing secret belongs in this public repository.

The current licence expires on **2026-11-17 at 23:25 UTC**. Homebrew reports the
cask as `0.72.0,20261018`: the second component identifies the licence delivery,
and the signed licence remains compatible with 0.72.0. Upgrade from an older
release with `brew update` followed by
`brew upgrade --cask jeevallc/jeeva/jeeva-studio`. `brew update` alone only updates
metadata. If retrying a failed postflight on an installed current version, use
`brew reinstall --cask jeevallc/jeeva/jeeva-studio` (add
`--appdir="$HOME/Applications"` for a user-local installation).

Before expiry, generate a new signed file with `script/release-30-day.sh licence`
in the Jeeva source repository. Verify it with the released CLI, upload it to
`jeeva-private-releases/releases/licences/<sha256>.json` with private/no-store
caching, and check that missing/invalid download keys get HTTP 401. Update the
licence URL, checksum, expiry documentation and second version component in this
tap, then push. Keep the app version as the first component and its DMG URL and
checksum tied to that release. A licence refresh requires `brew upgrade` (or a
manual `jeeva org licence install`); the app does not automatically renew it.

The download gateway's source is `distribution/worker.mjs`. It admits only
versioned DMG/ZIP paths and content-addressed licence JSON paths, after checking
the download key. When deploying it to the existing `jeeva-downloads` Worker,
preserve the `DOWNLOAD_KEY_HASHES` secret, the `RELEASES` R2 binding, and its
existing domain; do not enable public bucket access. The signing secret is not
needed to distribute an already signed file.

Validation:

```sh
node tests/downloads.mjs
HOMEBREW_DEVELOPER=1 brew ruby tests/licence_postflight.rb
# Optional live test: requires the app in ~/Applications and a download key; installs the licence.
HOMEBREW_DEVELOPER=1 brew ruby -- tests/licence_postflight.rb --sandbox
```

The licence step explicitly declares network access and access to `~/.config/jeeva`
for Homebrew’s sandbox. Its config path comes from Homebrew’s original home
context because the sandbox replaces the child process’s home directory.

The cask uses Homebrew's current `postflight_steps` API. Run `brew update` before
installing or upgrading so Homebrew understands it.

# frozen_string_literal: true

# What the slim Jeeva app leaves out: the embedded browser's Chromium, Clef's MLX shaders,
# and Studio's video tools and Python, in one signed, notarized disk image. The version is
# the pack's key (`jeeva dependencies --key`) and the checksum is the one the app pins in
# crates/jeeva-services/src/dependencies.pin: the app installs no other file, so both are
# set from that pin when a release publishes a new pack.
cask "jeeva-dependencies" do
  version "80a6f2dcb5fcb8e5"
  # Not published yet: replaced by the pin's sha256 when the pack is uploaded. Until then
  # every download fails its checksum, so nothing is installed.
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"

  url "https://downloads.jeeva.io/releases/v1-dependencies/Jeeva-dependencies-#{version}-arm64.dmg",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Dependencies"
  desc "Browser engine, on-device model shaders and video tools for Jeeva Studio"
  homepage "https://jeeva.io/"

  depends_on arch: :arm64
  depends_on macos: :sonoma
  depends_on cask: "jeevallc/jeeva/jeeva-studio"

  # Kept whole: Jeeva checks the disk image against its pin before it opens it.
  container type: :naked

  postflight_steps do
    run "#{HOMEBREW_PREFIX}/bin/jeeva",
        args: ["dependencies", "--install", "--from",
               "{{staged_path}}/Jeeva-dependencies-#{version}-arm64.dmg"],
        writable_paths: [".config/jeeva"], writable_base: :home
  end
end

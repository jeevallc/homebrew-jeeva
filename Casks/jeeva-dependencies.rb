# frozen_string_literal: true

# What the slim Jeeva app leaves out: the embedded browser's Chromium, Clef's MLX shaders,
# and Studio's video tools and Python, in one signed, notarized disk image. The version is
# the pack's key (`jeeva dependencies --key`) and the checksum is the one the app pins in
# crates/jeeva-services/src/dependencies.pin: the app installs no other file, so both are
# set from that pin when a release publishes a new pack.
cask "jeeva-dependencies" do
  version "80a6f2dcb5fcb8e5"
  sha256 "60aaef5afa7116c716d54fb870649f0bce2c19c285b6cf2abab5f98204828992"

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

  # A block rather than steps: Homebrew's step sandbox gives the step a home of its own
  # (where Jeeva finds no licence) and does not let it open a disk image.
  postflight do # rubocop:disable Cask/InstallSteps
    system_command "#{HOMEBREW_PREFIX}/bin/jeeva",
                   args:         ["dependencies", "--install", "--from",
                                  "#{staged_path}/Jeeva-dependencies-#{version}-arm64.dmg"],
                   env:          { "JEEVA_CONFIG_DIR" => "#{Dir.home}/.config/jeeva" },
                   print_stdout: true
  end
end

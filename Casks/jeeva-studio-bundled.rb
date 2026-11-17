# frozen_string_literal: true

licence_installer = <<~'RUBY'
require "digest"
require "json"
require "time"
require "tmpdir"
config_directory = ARGV.fetch(1)
Dir.mktmpdir("jeeva-licence-") do |directory|
  licence_file = File.join(directory, "licence.json")
  downloaded = system("/usr/bin/curl", *["--fail", "--silent", "--show-error", "--proto", "=https",
                        "--connect-timeout", "30", "--max-time", "120",
                        "--header", "@#{config_directory}/download-header",
                        "--output", licence_file,
                        "https://downloads.jeeva.io/releases/licences/f802ae944b926e68d7f8b52b3ee211d7b56a7ac563030ede775d6ab950d4d67b.json"])
  raise "Jeeva licence download failed; the existing licence was not changed." unless downloaded
  unless Digest::SHA256.file(licence_file).hexdigest == "f802ae944b926e68d7f8b52b3ee211d7b56a7ac563030ede775d6ab950d4d67b"
    raise "Jeeva licence checksum mismatch; the existing licence was not changed."
  end

  licence = JSON.parse(JSON.parse(File.read(licence_file)).fetch("licence"))
  now = Time.now.utc
  unless Time.iso8601(licence.fetch("issued_at")) <= now &&
         Time.iso8601(licence.fetch("expires_at")) > now &&
         Time.iso8601(licence.fetch("valid_until")) > now
    raise "Jeeva licence is not currently valid; the existing licence was not changed."
  end

  installed = system({ "JEEVA_CONFIG_DIR" => config_directory },
                     ARGV.fetch(0), "org", "licence", "install", licence_file)
  raise "Jeeva licence signature was refused; the existing licence was not changed." unless installed
end
RUBY

cask "jeeva-studio-bundled" do
  version "1.11.0,20261018"
  sha256 "5bda38883a8cb70ce826e222483905844a18962d939df50442bda3a7f38578ed"

  url "https://downloads.jeeva.io/releases/v1.11.0-app/Jeeva-v1.11.0-app-studio-arm64.dmg",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Studio (Bundled Video Tools)"
  desc "Native workspace for coding agents with bundled video tools"
  homepage "https://jeeva.io/"

  # From 1.12 the app is slim and its video tools come in the dependencies pack: install
  # jeeva-dependencies, which brings jeeva-studio with it.
  deprecate! date: "2026-11-16", because: :discontinued, replacement_cask: "jeeva-dependencies"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  conflicts_with cask: ["jeeva-studio", "jeeva-studio-complete"]

  app "Jeeva Studio.app"
  binary "#{appdir}/Jeeva Studio.app/Contents/Helpers/jeeva", target: "jeeva"

  postflight_steps do
    run "/usr/bin/ruby", args: ["-e", licence_installer,
                                "{{appdir}}/Jeeva Studio.app/Contents/Helpers/jeeva",
                                "#{Dir.home}/.config/jeeva"],
                         writable_paths: [".config/jeeva"], writable_base: :home, network_access: true
  end
end

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
                        "https://downloads.jeeva.io/releases/licences/e6f5633f6e26008da4dcfc7f26f81f9b8d6c8a396ae6c294d2cd4405ae25b32f.json"])
  raise "Jeeva licence download failed; the existing licence was not changed." unless downloaded
  unless Digest::SHA256.file(licence_file).hexdigest == "e6f5633f6e26008da4dcfc7f26f81f9b8d6c8a396ae6c294d2cd4405ae25b32f"
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

cask "jeeva-studio" do
  version "0.74.0,20261018"
  sha256 "4bc622135628b49579d4284d741d6f09a7e8b8f8521d9aeafa1603d2af6a0517"

  url "https://downloads.jeeva.io/releases/v0.74.0-app/Jeeva-Studio-v0.74.0-app-arm64.dmg",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Studio"
  desc "Native workspace for coding agents"
  homepage "https://jeeva.io/"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Jeeva Studio.app"
  binary "#{appdir}/Jeeva Studio.app/Contents/Helpers/jeeva", target: "jeeva"

  postflight_steps do
    run "/usr/bin/ruby", args: ["-e", licence_installer,
                                "{{appdir}}/Jeeva Studio.app/Contents/Helpers/jeeva",
                                "#{Dir.home}/.config/jeeva"],
                         writable_paths: [".config/jeeva"], writable_base: :home, network_access: true
  end
end

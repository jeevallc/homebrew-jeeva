# frozen_string_literal: true

licence_installer = <<~'RUBY'
require "digest"
require "json"
require "time"
require "tmpdir"
Dir.mktmpdir("jeeva-licence-") do |directory|
  licence_file = File.join(directory, "licence.json")
  downloaded = system("/usr/bin/curl", *["--fail", "--silent", "--show-error", "--proto", "=https",
                        "--connect-timeout", "30", "--max-time", "120",
                        "--header", "@#{Dir.home}/.config/jeeva/download-header",
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

  installed = system({ "JEEVA_CONFIG_DIR" => "#{Dir.home}/.config/jeeva" },
                     ARGV.fetch(0), "org", "licence", "install", licence_file)
  raise "Jeeva licence signature was refused; the existing licence was not changed." unless installed
end
RUBY

cask "jeeva-studio" do
  version "0.59.0,20261018"
  sha256 "7427c899713846185bf5e4f284a4e45c41ac4be0f0148f0ffd6622516011f917"

  url "https://downloads.jeeva.io/releases/v0.59.0-app/Jeeva-Studio-v0.59.0-app-arm64.dmg",
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
                                "{{appdir}}/Jeeva Studio.app/Contents/Helpers/jeeva"]
  end
end

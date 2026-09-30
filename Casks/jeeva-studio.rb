# frozen_string_literal: true

cask "jeeva-studio" do
  version "0.23.0"
  sha256 "98a3156dcc507645891559ecae5f12c42b7d123187424561d69d716532c54974"

  url "https://downloads.jeeva.io/releases/v0.23.0-app/Jeeva-Studio-v0.23.0-app-arm64.dmg",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Studio"
  desc "Native workspace for coding agents"
  homepage "https://jeeva.io/"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Jeeva Studio.app"
  binary "#{appdir}/Jeeva Studio.app/Contents/Helpers/jeeva", target: "jeeva"
end

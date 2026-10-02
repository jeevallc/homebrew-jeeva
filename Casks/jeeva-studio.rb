# frozen_string_literal: true

cask "jeeva-studio" do
  version "0.26.1"
  sha256 "e7ff3cf9546ebb63e322faf0ccd465b23fa8085714f3918e7c5e13785ffb8f48"

  url "https://downloads.jeeva.io/releases/v0.26.1-app/Jeeva-Studio-v0.26.1-app-arm64.dmg",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Studio"
  desc "Native workspace for coding agents"
  homepage "https://jeeva.io/"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Jeeva Studio.app"
  binary "#{appdir}/Jeeva Studio.app/Contents/Helpers/jeeva", target: "jeeva"
end

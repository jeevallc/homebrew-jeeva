# frozen_string_literal: true

cask "jeeva-studio" do
  version "0.58.0"
  sha256 "d1e645fc228cb02d21f330abc0dcb5117e9b651654a41ee76eb9dc3ba06d93bf"

  url "https://downloads.jeeva.io/releases/v0.58.0-app/Jeeva-Studio-v0.58.0-app-arm64.dmg",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Studio"
  desc "Native workspace for coding agents"
  homepage "https://jeeva.io/"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Jeeva Studio.app"
  binary "#{appdir}/Jeeva Studio.app/Contents/Helpers/jeeva", target: "jeeva"
end

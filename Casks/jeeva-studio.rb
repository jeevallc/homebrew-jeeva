# frozen_string_literal: true

cask "jeeva-studio" do
  version "0.24.0"
  sha256 "f49a61ba3f581ea1431ba385af5b9743f4c2f35942db7e4d1483677afb4dabb6"

  url "https://downloads.jeeva.io/releases/v0.24.0-app/Jeeva-Studio-v0.24.0-app-arm64.dmg",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Studio"
  desc "Native workspace for coding agents"
  homepage "https://jeeva.io/"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Jeeva Studio.app"
  binary "#{appdir}/Jeeva Studio.app/Contents/Helpers/jeeva", target: "jeeva"
end

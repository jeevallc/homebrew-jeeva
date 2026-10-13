# frozen_string_literal: true

cask "jeeva-studio" do
  version "0.50.0"
  sha256 "4807efd295724f85945be9bda552662585f3038c7837a6f6f23212254e2a615c"

  url "https://downloads.jeeva.io/releases/v0.50.0-app/Jeeva-Studio-v0.50.0-app-arm64.dmg",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Studio"
  desc "Native workspace for coding agents"
  homepage "https://jeeva.io/"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Jeeva Studio.app"
  binary "#{appdir}/Jeeva Studio.app/Contents/Helpers/jeeva", target: "jeeva"
end

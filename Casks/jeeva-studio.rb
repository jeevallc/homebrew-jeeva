# frozen_string_literal: true

cask "jeeva-studio" do
  version "0.52.0"
  sha256 "593421a92dd44cadb9ff4da17ea0495f64f25cc19f21c7b8167a7555b16bc679"

  url "https://downloads.jeeva.io/releases/v0.52.0-app/Jeeva-Studio-v0.52.0-app-arm64.dmg",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Studio"
  desc "Native workspace for coding agents"
  homepage "https://jeeva.io/"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Jeeva Studio.app"
  binary "#{appdir}/Jeeva Studio.app/Contents/Helpers/jeeva", target: "jeeva"
end

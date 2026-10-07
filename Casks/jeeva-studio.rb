# frozen_string_literal: true

cask "jeeva-studio" do
  version "0.34.1"
  sha256 "79c72f553d1485d9c86017036c3555afad8391fd9ee16725ed50d23ce85566c1"

  url "https://downloads.jeeva.io/releases/v0.34.1-app/Jeeva-Studio-v0.34.1-app-arm64.dmg",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Studio"
  desc "Native workspace for coding agents"
  homepage "https://jeeva.io/"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Jeeva Studio.app"
  binary "#{appdir}/Jeeva Studio.app/Contents/Helpers/jeeva", target: "jeeva"
end

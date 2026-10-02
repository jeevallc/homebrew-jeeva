# frozen_string_literal: true

cask "jeeva-studio" do
  version "0.26.4"
  sha256 "5b66cd0c12662e32f0229c8a6e0d114b8ca426504e19718176e08aed6d8b75dc"

  url "https://downloads.jeeva.io/releases/v0.26.4-app/Jeeva-Studio-v0.26.4-app-arm64.dmg",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Studio"
  desc "Native workspace for coding agents"
  homepage "https://jeeva.io/"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Jeeva Studio.app"
  binary "#{appdir}/Jeeva Studio.app/Contents/Helpers/jeeva", target: "jeeva"
end

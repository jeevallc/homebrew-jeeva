# frozen_string_literal: true

cask "jeeva-studio" do
  version "0.33.1"
  sha256 "015fef74194700c6b8f57f52420dddbdf6455e73e3eca089063bd78baa782593"

  url "https://downloads.jeeva.io/releases/v0.33.1-app/Jeeva-Studio-v0.33.1-app-arm64.dmg",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Studio"
  desc "Native workspace for coding agents"
  homepage "https://jeeva.io/"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Jeeva Studio.app"
  binary "#{appdir}/Jeeva Studio.app/Contents/Helpers/jeeva", target: "jeeva"
end

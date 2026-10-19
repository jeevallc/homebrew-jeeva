# frozen_string_literal: true

cask "jeeva-studio" do
  version "0.59.0"
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
end

# frozen_string_literal: true

cask "jeeva-studio" do
  version "0.45.2"
  sha256 "8b6f8566e98297acca8e1535dbe3dbcde5f633eea14085f77a4e01b7496b5917"

  url "https://downloads.jeeva.io/releases/v0.45.2-app/Jeeva-Studio-v0.45.2-app-arm64.dmg",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Studio"
  desc "Native workspace for coding agents"
  homepage "https://jeeva.io/"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Jeeva Studio.app"
  binary "#{appdir}/Jeeva Studio.app/Contents/Helpers/jeeva", target: "jeeva"
end

# frozen_string_literal: true

cask "jeeva-studio" do
  version "0.57.0"
  sha256 "2ada59a21aafacc77b00f23a01e3846ba4098e52b1e4596d3d5f9bf6d475ac69"

  url "https://downloads.jeeva.io/releases/v0.57.0-app/Jeeva-Studio-v0.57.0-app-arm64.dmg",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Studio"
  desc "Native workspace for coding agents"
  homepage "https://jeeva.io/"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Jeeva Studio.app"
  binary "#{appdir}/Jeeva Studio.app/Contents/Helpers/jeeva", target: "jeeva"
end

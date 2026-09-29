cask "jeeva-studio" do
  version "0.21.0"
  sha256 "b7a33e3dcc062c386253c96e62506885ba9e55924c22a649e8ee3301805a1852"

  url "https://downloads.jeeva.io/releases/v0.21.0-app/Jeeva-Studio-v0.21.0-app-arm64.dmg",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Studio"
  desc "Native workspace for coding agents"
  homepage "https://jeeva.io"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Jeeva Studio.app"

  binary "#{appdir}/Jeeva Studio.app/Contents/Helpers/jeeva", target: "jeeva"
end

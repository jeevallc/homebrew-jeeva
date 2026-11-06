# frozen_string_literal: true

cask "jeeva-local-models" do
  version "1"
  sha256 "176212f0a17da1ee845bffdbf58c2aa2a619cccf6d16b16d32303b0767f30566"

  url "https://downloads.jeeva.io/releases/v#{version}-models/Jeeva-local-models-#{version}.zip",
      header: "@#{Dir.home}/.config/jeeva/download-header"
  name "Jeeva Local Models"
  desc "Local models for decisions, recall, library search, and reranking"
  homepage "https://jeeva.io/"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  postflight_steps do
    run "/usr/bin/ruby", args: ["{{staged_path}}/Local Models/install.rb",
                                "{{staged_path}}/Installer/jeeva",
                                "#{Dir.home}/.config/jeeva"],
                         writable_paths: [".config/jeeva"], writable_base: :home
  end
end

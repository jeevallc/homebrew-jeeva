# Run with HOMEBREW_DEVELOPER=1 brew ruby tests/licence_postflight.rb
require "cask/cask_loader"
require "digest"
require "json"
require "time"
require "tmpdir"

sandbox_appdir = ARGV.delete("--sandbox") ? Pathname(Dir.home)/"Applications" : nil

source = File.read(File.expand_path("../Casks/jeeva-studio.rb", __dir__))
original_hash = source.match(/licences\/([a-f0-9]{64})\.json/)[1]
base_cask = Cask::CaskLoader::FromContentLoader.new(source).load(config: nil)
raise "upgrade not offered" unless base_cask.version > base_cask.version.class.new("0.61.0,20261018")
raise "auth missing" unless base_cask.url.specs[:headers] == ["@#{Dir.home}/.config/jeeva/download-header"]
postflight = base_cask.artifacts.find { |artifact| artifact.is_a?(Cask::Artifact::PostflightSteps) }
step = postflight.steps.fetch(0)
raise "network access missing" unless step["network_access"]
raise "real config argument missing" unless step["args"].last == "#{Dir.home}/.config/jeeva"
paths = Homebrew::InstallSteps::Runner.new(context: base_cask).sandbox_write_paths(postflight.steps)
raise "config access missing" unless paths.include?(Pathname(Dir.home)/".config/jeeva")

%w[valid download_failure checksum expired future signature_failure].each do |scenario|
  now = Time.now.utc
  payload = JSON.generate(licence: JSON.generate(
    issued_at: (scenario == "future" ? now + 3600 : now - 3600).iso8601,
    expires_at: (scenario == "expired" ? now - 60 : now + 3600).iso8601,
    valid_until: (now + 3600).iso8601,
  ), signature: "test-only")
  digest = Digest::SHA256.hexdigest(payload)
  installer = source.split("licence_installer = <<~'RUBY'\n", 2)[1].split("\nRUBY", 2)[0].gsub(original_hash, digest)
  calls = []
  download = nil
  runner = Object.new
  runner.define_singleton_method(:system) do |*arguments|
    calls << arguments
    if arguments.first == "/usr/bin/curl"
      next false if scenario == "download_failure"
      raise "auth missing" unless arguments.include?("@#{Dir.home}/.config/jeeva/download-header")
      download = arguments[arguments.index("--output") + 1]
      File.write(download, scenario == "checksum" ? "corrupt" : payload)
      true
    else
      raise "wrong CLI arguments" unless arguments[2, 3] == ["org", "licence", "install"]
      raise "wrong config destination" unless arguments.first == { "JEEVA_CONFIG_DIR" => "#{Dir.home}/.config/jeeva" }
      scenario != "signature_failure"
    end
  end
  ARGV.replace(["/test/Jeeva Studio.app/Contents/Helpers/jeeva", "#{Dir.home}/.config/jeeva"])
  failed = false
  begin
    runner.instance_eval(installer)
  rescue RuntimeError
    failed = true
  end
  raise "unexpected result: #{scenario}" unless failed == (scenario != "valid")
  expected_calls = %w[valid signature_failure].include?(scenario) ? 2 : 1
  raise "unexpected CLI call: #{scenario}" unless calls.size == expected_calls
  raise "temporary credential retained" if download && File.exist?(File.dirname(download))
  puts "#{scenario}: passed"
end

if sandbox_appdir
  config = Cask::Config.new(explicit: { appdir: sandbox_appdir })
  cask = Cask::CaskLoader::FromContentLoader.new(source).load(config: config)
  cask.artifacts.find { |artifact| artifact.is_a?(Cask::Artifact::PostflightSteps) }.install_phase
  puts "Actual Homebrew sandbox licence installation passed"
end

# Verify a real postflight installation in an isolated user's config directory.
require "digest"
require "json"

config = File.expand_path(ARGV.fetch(0))
models = JSON.parse(File.read(File.join(__dir__, "../distribution/models/manifest.json")))
models.each do |folder, model|
  if folder == "clef"
    record = JSON.parse(File.read(File.join(config, "clef/install.json")))
    root = File.join(config, "clef/weights")
    raise "Unexpected Clef location" unless File.realpath(record.fetch("weights")) == File.realpath(root)
    raise "Unexpected Clef source" unless record.fetch("model_repo") == model.fetch("repo")
    revision = record.fetch("revision")
  else
    repo = File.join(config, "models/fastembed", folder)
    revision = File.read(File.join(repo, "refs/main")).strip
    root = File.join(repo, "snapshots", revision)
  end
  raise "Wrong revision for #{folder}" unless revision == model.fetch("revision")
  model.fetch("files").each do |name, sha|
    raise "Incorrect installed file #{folder}/#{name}" unless Digest::SHA256.file(File.join(root, name)).hexdigest == sha
  end
  puts "Verified #{folder}"
end

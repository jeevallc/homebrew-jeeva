# Runs inside the Homebrew postflight sandbox with network access disabled.
require "digest"
require "fileutils"
require "json"
require "tempfile"

cli, config = ARGV
abort "Expected the installed jeeva executable and config directory" unless cli && config
models = JSON.parse(File.read(File.join(__dir__, "manifest.json")))
FileUtils.mkdir_p(config)
File.open(File.join(config, ".offline-model-install.lock"), "a", 0600) do |lock|
  lock.flock(File::LOCK_EX)
  # The app owns Clef's hardware check, checksum validation and installation record.
  success = system({ "JEEVA_CONFIG_DIR" => config }, cli, "clef", "install", "--from", File.join(__dir__, "clef"))
  abort "Clef installation failed" unless success

  models.reject { |folder, _| folder == "clef" }.each do |folder, model|
    repo = File.join(config, "models", "fastembed", folder)
    revision = model.fetch("revision")
    snapshot = File.join(repo, "snapshots", revision)
    model.fetch("files").each do |name, expected|
      destination = File.join(snapshot, name)
      next if File.file?(destination) && Digest::SHA256.file(destination).hexdigest == expected

      FileUtils.mkdir_p(File.dirname(destination))
      Tempfile.create(".incoming-", File.dirname(destination)) do |file|
        File.open(File.join(__dir__, folder, name), "rb") { |source| IO.copy_stream(source, file) }
        file.close
        abort "Checksum mismatch for #{folder}/#{name}" unless Digest::SHA256.file(file.path).hexdigest == expected
        File.rename(file.path, destination)
      end
    end
    # Publish the revision only after all tokenizer and inference files are present.
    refs = File.join(repo, "refs")
    FileUtils.mkdir_p(refs)
    Tempfile.create(".main-", refs) do |file|
      file.write(revision)
      file.close
      File.rename(file.path, File.join(refs, "main"))
    end
  end
end

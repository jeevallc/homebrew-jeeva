"""Stage only the pinned model files for the independent Homebrew model pack."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("cache", type=Path, help="Jeeva config directory containing the verified models")
parser.add_argument("destination", type=Path, help="New Local Models directory in the model pack")
args = parser.parse_args()
source_dir = Path(__file__).resolve().parent
manifest = json.loads((source_dir / "manifest.json").read_text())
args.destination.mkdir(parents=True, exist_ok=False)
for folder, model in manifest.items():
    if folder == "clef":
        source = args.cache / "clef/weights"
    else:
        source = args.cache / "models/fastembed" / folder / "snapshots" / model["revision"]
    for filename, expected in model["files"].items():
        target = args.destination / folder / filename
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source / filename, target)
        digest = hashlib.sha256()
        with target.open("rb") as data:
            for block in iter(lambda: data.read(1024 * 1024), b""):
                digest.update(block)
        if digest.hexdigest() != expected:
            raise SystemExit(f"Checksum mismatch for {target}")
for name in ("install.rb", "manifest.json"):
    shutil.copyfile(source_dir / name, args.destination / name)
shutil.copytree(source_dir / "notices", args.destination / "notices")

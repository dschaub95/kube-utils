import os
from pathlib import Path
import shutil
import sqlite3
import sys
import tempfile
import time
from urllib.parse import quote

os.umask(0o077)
source, destination = map(Path, sys.argv[1:3])


def snapshot():
    databases = []
    for root, directories, files in os.walk(source):
        directories[:] = [name for name in directories if name != "logs"]
        relative = Path(root).relative_to(source)
        target = destination / relative
        target.mkdir(parents=True, exist_ok=True)
        for name in files:
            original = Path(root) / name
            copied = target / name
            # T3 holds this empty ownership-lock database exclusively for its lifetime.
            if name == "server-owner.sqlite" or name.endswith(("-wal", "-shm", "-journal")):
                continue
            if name.endswith(".sqlite"):
                databases.append((original, copied))
                continue
            if copied.exists() and not original.is_symlink():
                a, b = original.stat(), copied.stat()
                if a.st_size == b.st_size and a.st_mtime_ns == b.st_mtime_ns:
                    continue
            temporary = copied.with_name(copied.name + ".backup-tmp")
            shutil.copy2(original, temporary, follow_symlinks=False)
            os.replace(temporary, copied)
    for original, copied in databases:
        with tempfile.NamedTemporaryFile(dir=copied.parent, suffix=".sqlite", delete=False) as file:
            temporary = Path(file.name)
        try:
            reader = sqlite3.connect("file:" + quote(str(original)) + "?mode=ro", uri=True)
            writer = sqlite3.connect(temporary)
            try:
                reader.backup(writer, pages=1024, sleep=0.05)
            finally:
                writer.close()
                reader.close()
            os.replace(temporary, copied)
        finally:
            temporary.unlink(missing_ok=True)
    (destination / ".complete").touch()
    print(time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "snapshot of", source, "complete", flush=True)


if sys.argv[3] == "once":
    snapshot()
else:
    while True:
        time.sleep(300)
        try:
            snapshot()
        except Exception as error:
            print(time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "T3 snapshot failed", type(error).__name__, flush=True)

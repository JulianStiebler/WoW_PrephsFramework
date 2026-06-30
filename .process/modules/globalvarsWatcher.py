"""
watcher.py - Watch globalvars.preph and trigger preproc.py on save.
"""
import sys
import time
import subprocess
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# Use Config to resolve paths — same as every other script
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from modules.config import Config

cfg = Config()

WATCHED_FILE  = cfg.PATH_GLOBALVARS          # .process/globalvars.preph
PREPROC_SCRIPT = cfg.RUN_PREPROCESS          # .process/preproc.py


class GlobalVarsHandler(FileSystemEventHandler):
    def __init__(self):
        self._last_run: float = 0
        self._debounce: float = 1.0

    def on_modified(self, event):
        if event.is_directory:
            return
        if Path(event.src_path).resolve() != WATCHED_FILE.resolve():
            return

        now = time.time()
        if now - self._last_run < self._debounce:
            return
        self._last_run = now

        print(f"\n[watch] {WATCHED_FILE.name} saved — running preproc.py...")
        result = subprocess.run(
            [sys.executable, str(PREPROC_SCRIPT)],
            cwd=str(cfg.DIR_PROCESS),
        )
        if result.returncode != 0:
            print(f"[watch] ✗ preproc.py exited with {result.returncode}")
        else:
            print(f"[watch] ✓ preproc.py OK")


if __name__ == "__main__":
    handler = GlobalVarsHandler()
    observer = Observer()
    observer.schedule(handler, str(cfg.DIR_PROCESS), recursive=False)
    print(f"[watch] Watching : {WATCHED_FILE}")
    print(f"[watch] Will run : {PREPROC_SCRIPT}")
    print(f"[watch] Press Ctrl+C to stop.")
    observer.start()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
"""
configure.py - One-time setup script for PrephsFramework development environment.

Creates .vscode/tasks.json if it does not exist, using paths derived from Config.
"""
import sys
import json
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from modules.config import Config, Report



TASKS_TEMPLATE = {
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Watch: globalvars.preph",
            "type": "shell",
            "command": "python {watcher_path}",
            "isBackground": True,
            "problemMatcher": [],
            "presentation": {
                "reveal": "always",
                "panel": "dedicated"
            },
            "runOptions": {
                "runOn": "folderOpen"
            }
        },
        {
            "label": "Run: preproc.py",
            "type": "shell",
            "command": "python {preproc_path}",
            "presentation": {
                "reveal": "always",
                "panel": "shared"
            }
        }
    ]
}


def configure() -> int:
    cfg    = Config()
    report = Report("configure", cfg=cfg)
    report.step("Configure VS Code tasks")

    tasks_path  = cfg.DIR_VSCODE / "tasks.json"

    # Paths use forward slashes so VS Code is happy on all platforms
    watcher_path = cfg.RUN_GLOBALWATCHER.as_posix()
    preproc_path = cfg.RUN_PREPROCESS.as_posix()

    # Fill template
    tasks = json.loads(
        json.dumps(TASKS_TEMPLATE)
            .replace("{watcher_path}", "${workspaceFolder}/" + watcher_path)
            .replace("{preproc_path}", "${workspaceFolder}/" + preproc_path)
    )

    # Create .vscode dir if needed
    if not cfg.DIR_PROCESS.exists():
        cfg.DIR_PROCESS.mkdir(parents=True)
        report.record("created", ".vscode/")

    # Never overwrite an existing tasks.json
    if tasks_path.exists():
        report.record("skipped", ".vscode/tasks.json", "already exists")
        report.summary("Configure", noun="file")
        return report.exit_code

    try:
        with open(tasks_path, "w", encoding="utf-8") as f:
            json.dump(tasks, f, indent=4)
        report.record("created", ".vscode/tasks.json")
        report.detail("~", f"watcher : {watcher_path}")
        report.detail("~", f"preproc : {preproc_path}")
    except OSError as e:
        report.record("error", ".vscode/tasks.json", str(e))

    report.summary("Configure", noun="file")

    return report.exit_code


if __name__ == "__main__":
    sys.exit(configure())
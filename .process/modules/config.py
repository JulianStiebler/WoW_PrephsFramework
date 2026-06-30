"""
config.py - Shared configuration for all pre-processing scripts.

Parses globalvars.preph once and exposes project metadata, paths, and
per-module version info through a singleton Config instance.
"""
import ast
import logging
import re
import os
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional

TOC_PATTERN_CONT_START = r"<!-- START DEFINITION TOC -->"
TOC_PATTERN_CONT_END = r"<!-- END DEFINITION TOC -->"
TOC_PATTERN_CONT_FULL = rf"{TOC_PATTERN_CONT_START}.*?{TOC_PATTERN_CONT_END}"
TOC_GEN_HEADER = "# Table of Contents"


# Format templates: call .format(name=foo) to get e.g. "<!-- START CONTENT {{foo}} -->"
ALIAS_PATTERN_CONT_START = "<!-- START CONTENT {{{{{name}}}}} -->"
ALIAS_PATTERN_CONT_END   = "<!-- END CONTENT {{{{{name}}}}} -->"
ALIAS_PATTERN_DEF_START  = "<!-- START DEFINITION {{{{{name}}}}} -->"
ALIAS_PATTERN_DEF_END    = "<!-- END DEFINITION {{{{{name}}}}} -->"

# Regex patterns built from the templates above:
# CONT_FULL captures (name,); DEF_FULL captures (name, content)
ALIAS_PATTERN_CONT_FULL = r"<!-- START CONTENT \{\{(\w+)\}\} -->.*?<!-- END CONTENT \{\{\w+\}\} -->"
ALIAS_PATTERN_DEF_FULL  = r"<!-- START DEFINITION \{\{(\w+)\}\} -->(.*?)<!-- END DEFINITION \{\{\w+\}\} -->"


ADDITIONAL_IGNORE_DIRS = {
    "libs",
    ".process",
    ".github",
}
ADDITIONAL_IGNORE_FILES = set()

class Config:
    """Singleton configuration for PrephsFramework processing scripts.

    Parses globalvars.preph on first instantiation and caches the result;
    subsequent ``Config()`` calls return the same object.
    """

    _instance: "Config | None" = None

    def __new__(cls) -> "Config":
        if cls._instance is None:
            cls._instance = super().__new__(cls)
            cls._instance._initialize()
        return cls._instance

    # ------------------------------------------------------------------
    # Initialisation (called exactly once)
    # ------------------------------------------------------------------

    def _initialize(self) -> None:
        """Populate all config attributes from globalvars.preph."""

        # ---------------------------------------------------------------------------
        # Directories
        # ---------------------------------------------------------------------------
        #new
        self.DIR_MODULES: Path = Path(__file__).resolve().parent        # .process/modules/
        self.DIR_PROCESS: Path = self.DIR_MODULES.parent                # .process/
        self.DIR_PROJECT_ROOT: Path = self.DIR_PROCESS.parent           # project root
        self.DIR_VSCODE: Path = self.DIR_PROJECT_ROOT / ".vscode"       # .vscode directory

        # ---------------------------------------------------------------------------
        # Global variables and project metadata (from globalvars.preph)
        # ---------------------------------------------------------------------------

        self.PATH_GLOBALVARS: Path = self.DIR_PROCESS / "globalvars.preph"

        self.GLOBALVARS, _meta = self._parse_globalvars(self.PATH_GLOBALVARS)
        print(f"Loaded global variables from {self.PATH_GLOBALVARS.as_posix()}: {len(self.GLOBALVARS)} variables, {len(_meta)} metadata entries, "
              f"entries = {list(self.GLOBALVARS.keys())}, metadata keys = {list(_meta.keys())}")
        self.PROJECT_NAME: str  = self.GLOBALVARS.get("G_projectName",  "PrephsFramework")
        self.GITHUB_AUTHOR: str = self.GLOBALVARS.get("G_projectAuthor", "JulianStiebler")
        self.GITHUB_BRANCH: str = self.GLOBALVARS.get("G_gitHubBranch", "main")
        self.MODULE_PREFIX: str = self.GLOBALVARS.get("G_modulePrefix", "")

        # Per-module version metadata  { "Core": {"name": ..., "major": ..., ...}, ... }
        self.PROJECT_METADATA: Dict[str, Any] = _meta

        # ---------------------------------------------------------------------------
        # Runner paths
        # ---------------------------------------------------------------------------
        self.RUN_GLOBALWATCHER: Path = self.DIR_MODULES / "globalvarsWatcher.py"
        
        # --- Configure
        self.RUN_CONFIGURE: Path = self.DIR_PROCESS / "configure.py"

        # --- Pre-processing steps
        self.RUN_PREPROCESS: Path = self.DIR_PROCESS / "preproc.py"

        # --- Bundle steps
        self.RUN_BUNDLE: Path = self.DIR_PROCESS / "bundle.py"



        # ---------------------------------------------------------------------------
        # Shared file paths
        # ---------------------------------------------------------------------------

        self.PATH_ALIASES: Path = self.DIR_PROJECT_ROOT / "aliases.md"

        # README files processed by generateTOC.py and syncAliases.py
        # Root README + one per module derived from G_projectMetadata paths
        self.PATH_READMES: List[Path] = [self.DIR_PROJECT_ROOT / "README.md"] + [
            self.DIR_PROJECT_ROOT / module["path"] / "README.md"
            for module in _meta.values()
            if "path" in module
        ]

        # All files scanned for definition blocks by syncAliases.py
        # aliases.md is always first (lowest precedence); later files override on name collision
        self.DEFINITION_PATHS: List[Path] = list(dict.fromkeys(
            [self.PATH_ALIASES] + self.PATH_READMES
        ))

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _parse_globalvars(PATH_GLOBALVARS: Path) -> tuple[Dict[str, Any], Dict[str, Any]]:
        """
        Parse a .preph globalvars file.

        Handles simple scalar assignments (``G_key = "value"``) and nested
        dict blocks (``G_key = { … }``).  The ``G_projectMetadata`` block is
        returned separately as *metadata*; all other keys are in *variables*.
        """
        variables: Dict[str, str] = {}
        metadata: Dict[str, Any] = {}
        try:
            with open(PATH_GLOBALVARS, "r", encoding="utf-8") as f:
                content = f.read()

            # --- nested dict blocks (G_key = { ... }) ---
            block_pattern = re.compile(
                r"^(G_\w+)\s*=\s*(\{.*?^\})",
                re.MULTILINE | re.DOTALL,
            )
            for m in block_pattern.finditer(content):
                key = m.group(1)
                try:
                    value = ast.literal_eval(m.group(2))
                except (ValueError, SyntaxError) as e:
                    print(f"Warning: Could not parse block \"{key}\": {e}")
                    value = {}
                if key == "G_projectMetadata":
                    metadata = value
                else:
                    variables[key] = value

            # --- simple scalar assignments (G_key = "value" or G_key = 123) ---
            scalar_pattern = re.compile(
                r"^(G_\w+)\s*=\s*([^{\n][^\n]*)",
                re.MULTILINE,
            )
            for m in scalar_pattern.finditer(content):
                key = m.group(1)
                raw = m.group(2).strip()
                try:
                    variables[key] = ast.literal_eval(raw)
                except (ValueError, SyntaxError):
                    variables[key] = raw.strip("\"'")

        except Exception as e:
            print(f"Warning: Could not read globalvars: {e}")

        return variables, metadata
    

class IconMapper:
    """Maps file extensions and names to display emoji icons."""

    def __init__(self, mappings: Optional[Dict[tuple, str]] = None) -> None:
        """Initialise with built-in extension-to-icon mappings.

        Pass *mappings* to merge additional or override existing entries.
        """
        self.mappings = {
            # Code files
            (".py",): "🐍",
            (".js", ".ts"): "🟨",
            (".java",): "☕",
            (".cpp", ".hpp", ".c", ".h"): "⚡",
            (".cs",): "🔷",
            
            # Web files
            (".html", ".htm"): "🌐",
            (".css",): "🎨",
            (".sass", ".scss"): "💅",
            
            # Data files
            (".json",): "📊",
            (".yml", ".yaml"): "⚙️",
            (".xml",): "📰",
            (".csv",): "📑",
            (".sql",): "🗄️",
            
            # Documentation
            (".md", ".markdown"): "📝",
            (".txt",): "📄",
            (".pdf",): "📕",
            (".doc", ".docx"): "📘",
            
            # Config files
            (".env", ".gitignore", "requirements.txt", "package.json"): "⚙️",
            
            # Media files
            (".jpg", ".jpeg", ".png", ".gif"): "🖼️",
            (".mp3", ".wav", ".ogg"): "🎵",
            (".mp4", ".mov", ".avi"): "🎬",
            
            # Archive files
            (".zip", ".rar", ".7z", ".tar", ".gz"): "📦",
            
            # Special files
            ("LICENSE", "LICENSE.md"): "📜",
            ("README", "README.md"): "📖",
            ("Dockerfile",): "🐳",
        }
        if mappings:
            for exts, icon in mappings.items():
                if not isinstance(exts, tuple):
                    exts = (exts,)
                self.mappings[exts] = icon

    def get_icon(self, filename: str) -> str:
        """Return the emoji icon for *filename* based on extension, falling back to 📄."""
        ext = os.path.splitext(filename)[1].lower()
        for extensions, icon in self.mappings.items():
            if ext in extensions or filename in extensions:
                return icon
        return "📄"  # default icon


class Report:
    """Centralised progress tracking and logging for pre-processing scripts.

    Each script creates one ``Report`` instance and uses it to record per-file
    outcomes and print a final summary.  The ``log`` attribute is a standard
    :class:`logging.Logger` that modules can use for free-form messages::

        report = Report("my_task")
        report.log.debug("Checking %s", path)
        report.record("updated", rel_path)
        report.detail("~", "key: old -> new")
        report.summary("Processed", noun=".toc file")
        return report.exit_code
    """

    # All recognised outcome keys (callers may also pass ad-hoc strings).
    _STATUSES: List[str] = [
        "updated", "created", "skipped", "empty",
        "missing", "error", "override", "skip",
    ]

    # Fixed-width labels used in log output - longest is 8 chars.
    _LABELS: Dict[str, str] = {
        "updated":  "UPDATED",
        "created":  "CREATED",
        "skipped":  "SKIPPED",
        "empty":    "EMPTY",
        "missing":  "MISSING",
        "error":    "ERROR",
        "override": "OVERRIDE",
        "skip":     "SKIP",
    }

    def __init__(self, name: str = "preproc", cfg: "Config | None" = None) -> None:
        self.name = name
        self.counts: Dict[str, int] = {s: 0 for s in self._STATUSES}

        # Step tracking (populated by plan())
        self._steps: List[str] = []
        self._step_index: int = 0
        self._failed_steps: List[str] = []

        # Attach a StreamHandler once so callers can also call report.log.debug()
        self.log: logging.Logger = logging.getLogger(f"preproc.{name}")
        if not self.log.handlers:
            _handler = logging.StreamHandler(sys.stdout)
            _handler.setFormatter(logging.Formatter("%(message)s"))
            self.log.addHandler(_handler)
            self.log.setLevel(logging.DEBUG)
        # Prevent propagation to the root logger (avoids duplicate output).
        self.log.propagate = False

        if cfg is not None:
            self.log.info(f"=== {cfg.PROJECT_NAME} Pre-Processor ===")
            self.log.info(f"Project root : {cfg.DIR_PROJECT_ROOT.as_posix()}")
            self.log.info(f"Project name : {cfg.PROJECT_NAME}")
            self.log.info(f"GitHub       : {cfg.GITHUB_AUTHOR}/{cfg.PROJECT_NAME}@{cfg.GITHUB_BRANCH}")
            self.log.info("")

    # ------------------------------------------------------------------
    # Step tracking
    # ------------------------------------------------------------------

    def plan(self, steps: List[str]) -> None:
        """Register the ordered list of step labels for this run.

        Call once before the first ``step()`` so the total is known and
        ``[N/total]`` counters can be printed automatically."""
        self._steps = list(steps)
        self._step_index = 0

    def step(self, label: str) -> None:
        """Print a step header, auto-deriving the N/total counter.

        If ``plan()`` was called the label is matched against the registered
        list (fallback: sequential index).  The counter is printed as
        ``[N/total]``; if no plan was registered, just ``[N]`` is used."""
        self._step_index += 1
        n     = self._step_index
        total = len(self._steps) if self._steps else None
        counter = f"{n}/{total}" if total else str(n)
        self.log.info(f"--- [{counter}] {label} ---")

    # ------------------------------------------------------------------
    # Recording helpers
    # ------------------------------------------------------------------

    def result(self, name: str, code: int) -> int:
        """Record the integer return code of a named step.

        Non-zero codes are tracked internally so ``stop()`` can report them.
        Returns *code* unchanged so callers can still use the value if needed."""
        if code != 0:
            self._failed_steps.append(name)
        return code

    def stop(self, message: str = "All steps completed successfully") -> int:
        """Print the final success or failure banner and return an exit code.

        If any step recorded a non-zero result via ``result()``, prints a
        failure banner listing those steps and returns ``1``; otherwise prints
        *message* wrapped in ``=== … ===`` and returns ``0``."""
        if self._failed_steps:
            self.log.info(f"=== Finished with errors in: {', '.join(self._failed_steps)} ===")
            return 1
        self.log.info(f"=== {message} ===")
        return 0

    def record(self, status: str, path: str = "", detail: str = "") -> None:
        """Print a status line and increment the matching counter."""
        if status not in self.counts:
            self.counts[status] = 0
        label = self._LABELS.get(status, status.upper())
        msg = f"  [{label:<8}]  {path}"
        if detail:
            msg += f"  ({detail})"
        self.log.info(msg)
        self.counts[status] += 1

    def detail(self, prefix: str, text: str) -> None:
        """Print an indented detail line beneath a ``record()`` call."""
        self.log.info(f"    {prefix} {text}")

    def summary(self, label: str, noun: str = "file") -> None:
        """Print a final summary line showing every non-zero counter."""
        total = sum(self.counts.values())
        parts = [f"{v} {k}" for k, v in self.counts.items() if v]
        self.log.info(f"\n{label} {total} {noun}(s): {', '.join(parts)}")

    # ------------------------------------------------------------------
    # Convenience properties
    # ------------------------------------------------------------------

    @property
    def has_errors(self) -> bool:
        """``True`` if at least one ``"error"`` outcome was recorded."""
        return self.counts.get("error", 0) > 0

    @property
    def exit_code(self) -> int:
        """``0`` on clean run, ``1`` if any errors were recorded."""
        return 1 if self.has_errors else 0

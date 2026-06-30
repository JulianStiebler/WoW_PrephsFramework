"""
parseDataIntoTocs.py - Sync module metadata from globalvars.preph into .toc files.

For each module in G_projectMetadata:
- Locates the .toc file at <path>/<path>.toc
- If it finds a .toc file in the specified path:
    - Constructs:
        Version                      = major.minor.patch
        Title                        = G_modulePrefix + title
        X-PrephsFramework-ModuleID   = title  (consumer modules only)
    - Passes through any key prefixed with "## " in globalvars (e.g. "## Interface")
        into the .toc, stripping the prefix to recover the real key name.
    - Keys without a "## " prefix (title, major, minor, patch, path, …) are
        internal globals and are never written to the .toc directly.
    - Keeps any .toc-only keys untouched (e.g. Dependencies, DefaultState, X-SAO-Build).
    - Appends new keys from globalvars if they don"t yet exist in the .toc.
    - Re-sorts ALL ## directives:
        1. Fixed priority keys (_KEY_ORDER) in declaration order.
        2. All remaining non-X-* keys alphabetically.
        3. All X-* keys alphabetically.
"""

import re
import sys
from pathlib import Path
from typing import Any
from modules.config import Config, Report

# Fixed display order for well-known keys (lowercase for comparison).
# Sort tiers: (0) keys listed here, in order
#             (1) all other non-X-* keys, alphabetically
#             (2) all X-* keys, alphabetically
_KEY_ORDER = [
    "interface",
    "title",
    "version",
    "author",
    "notes",
    "loadondemand",
    "defaultstate",
    "dependencies",
    "optionaldeps",
    "savedvariables",
    "savedvariablespercharacter",
]


def _sort_key(key_lower: str) -> tuple[int, int, str]:
    """Sort tuple for .toc directive ordering: priority keys first, then non-X-* alpha, then X-* alpha."""
    try:
        return (0, _KEY_ORDER.index(key_lower), "")
    except ValueError:
        if key_lower.startswith("x-"):
            return (2, 0, key_lower)
        return (1, 0, key_lower)


def _find_toc(module_dir: Path) -> Path | None:
    """Return the single .toc file inside module_dir, or None."""
    matches = list(module_dir.glob("*.toc"))
    if not matches:
        return None
    # Prefer the one whose stem matches the folder name
    for m in matches:
        if m.stem.lower() == module_dir.name.lower():
            return m
    return matches[0]


def _parse_toc(text: str) -> tuple[dict[str, tuple[str, str]], list[str]]:
    """
    Split a .toc file into its directive header and trailing file list.

    Returns:
        directives: ``{ key_lower: (key_orig, value) }`` for every ``## Key: Value`` line.
        files:      raw lines after the header block (blank lines, comments, .lua paths).
    """
    lines = text.splitlines(keepends=True)
    directives = {}  # key_lower -> (key_orig, value); last occurrence wins on dupes
    files = []
    in_files = False

    for line in lines:
        if in_files:
            files.append(line)
            continue

        stripped = line.rstrip("\n").rstrip("\r")
        m = re.match(r"^##\s*([^:]+):\s*(.*)", stripped)
        if m:
            key_orig = m.group(1).rstrip()
            value    = m.group(2).strip()
            directives[key_orig.lower()] = (key_orig, value)
        else:
            # First non-## line ends the header block
            in_files = True
            files.append(line)

    return directives, files


def _build_updates(module_key: str, meta: dict[str, Any], cfg: Config) -> dict[str, tuple[str, str]]:
    """
    Build a dict of { toc_key_lower: (display_key, value) } for all fields
    that should be written/updated in the .toc.

    Only globalvars keys prefixed with "## " are treated as .toc directives.
    The prefix is stripped to recover the real key name (e.g. "## Interface" → "Interface").
    All other keys (title, major, minor, patch, path, …) are internal and ignored.

    For the Core module, all X-PrephsFramework-* pass-through keys are skipped
    (Core is the framework itself, not a consumer module).
    """
    major   = meta.get("major", 0)
    minor   = meta.get("minor", 0)
    patch   = meta.get("patch", 0)
    title   = meta.get("title", module_key)
    prefix  = cfg.MODULE_PREFIX
    is_core = (module_key == "Core")

    updates = {
        "version": ("Version", f"{major}.{minor}.{patch}"),
        "title":   ("Title",   f"{prefix} {title}" if prefix else title),
    }

    # X-PrephsFramework-ModuleID is only meaningful for consumer modules
    if not is_core:
        updates["x-prephsframework-moduleid"] = ("X-PrephsFramework-ModuleID", title)

    for key, val in meta.items():
        # Only keys prefixed with "## " are .toc directives; all others are internal
        if not key.startswith("## "):
            continue
        toc_key = key[3:]  # strip the "## " prefix
        # Skip all X-PrephsFramework-* pass-through keys for Core
        if is_core and toc_key.lower().startswith("x-prephsframework-"):
            continue
        updates[toc_key.lower()] = (toc_key, str(val))

    return updates


def sync_toc(toc_path: Path, module_key: str, meta: dict[str, Any], cfg: Config) -> dict[str, Any]:
    """
    Sync one .toc file in-place.

    Returns a result dict with keys:
      ``status``    - ``"updated"`` | ``"skipped"`` | ``"error"``
      ``updated``   - list of changed key descriptions
      ``added``     - list of newly inserted key descriptions
      ``reordered`` - ``True`` if the header order changed without value changes
      ``error``     - error message (only when ``status == "error"``)
    """
    result = {"status": "error", "updated": [], "added": [], "reordered": False, "error": ""}

    try:
        original = toc_path.read_text(encoding="utf-8")
    except Exception as e:
        result["error"] = str(e)
        return result

    updates          = _build_updates(module_key, meta, cfg)
    existing, files  = _parse_toc(original)

    merged = {}  # key_lower -> (display_key, value)

    for key_lower, (key_orig, value) in existing.items():
        if key_lower in updates:
            _, new_val = updates[key_lower]
            if new_val != value:
                result["updated"].append(f"{key_orig}: {value!r} -> {new_val!r}")
            merged[key_lower] = (key_orig, new_val)
        else:
            merged[key_lower] = (key_orig, value)

    for key_lower, (display_key, new_val) in updates.items():
        if key_lower not in merged:
            result["added"].append(f"{display_key}: {new_val!r}")
            merged[key_lower] = (display_key, new_val)

    sorted_keys = sorted(merged.keys(), key=_sort_key)
    new_header  = [f"## {merged[k][0]}: {merged[k][1]}\n" for k in sorted_keys]
    new_content = "".join(new_header) + "".join(files)

    # Detect if the order of existing keys changed (independent of value changes)
    old_order = [k for k in existing if k in merged]
    new_order = [k for k in sorted_keys if k in existing]
    result["reordered"] = old_order != new_order

    if new_content == original:
        result["status"] = "skipped"
        return result

    try:
        toc_path.write_text(new_content, encoding="utf-8")
        result["status"] = "updated"
    except Exception as e:
        result["error"] = str(e)

    return result


def toc_syncGlobalData() -> int:
    cfg    = Config()
    report = Report("toc_sync")
    report.step("Sync .toc Files")
    report.detail("@", cfg.DIR_PROJECT_ROOT.as_posix())
    metadata = cfg.PROJECT_METADATA

    if not metadata:
        report.record("skip", "globalvars.preph", "no module metadata found")
        return 0

    for module_key, meta in metadata.items():
        module_path = meta.get("path")
        if not module_path:
            report.record("skip", module_key, "no 'path' defined")
            continue

        module_dir = cfg.DIR_PROJECT_ROOT / module_path
        toc_path   = _find_toc(module_dir)

        if toc_path is None:
            report.record("missing", module_dir.as_posix(), "no .toc found")
            continue

        result = sync_toc(toc_path, module_key, meta, cfg)
        status = result["status"]
        rel    = toc_path.relative_to(cfg.DIR_PROJECT_ROOT).as_posix()

        if status == "updated":
            report.record("updated", rel)
            for change in result["updated"]:
                report.detail("~", change)
            for entry in result["added"]:
                report.detail("+", entry)
            if result["reordered"]:
                report.detail("*", "directives reordered")
        elif status == "skipped":
            report.record("skipped", rel, "no changes needed")
        else:
            report.record("error", rel, result["error"])

    report.summary("Processed", noun=".toc file")
    return report.exit_code


if __name__ == "__main__":
    sys.exit(toc_syncGlobalData())

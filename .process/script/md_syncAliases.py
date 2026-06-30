"""
md_syncAliases.py - Propagate shared content from aliases.md into README files.

Reads named definition blocks wrapped in:
  <!-- START DEFINITION {{NAME}} --> … <!-- END DEFINITION {{NAME}} -->
and injects their content into matching placeholder blocks wrapped in:
  <!-- START CONTENT {{NAME}} --> … <!-- END CONTENT {{NAME}} -->
"""
import re
import sys
from pathlib import Path
from modules.config import (
    Config,
    Report,
    ALIAS_PATTERN_DEF_FULL,
    ALIAS_PATTERN_CONT_FULL,
    ALIAS_PATTERN_CONT_START,
    ALIAS_PATTERN_CONT_END,
)


def extract_definitions(source_paths: list[Path], report: Report) -> dict[str, str]:
    """Parse all named definition blocks from one or more source files.

    Scans each path in *source_paths* in order.  Later files take precedence
    when the same NAME appears in multiple files.
    Returns a mapping of ``{NAME: content}``.
    """
    definitions: dict[str, str] = {}

    for path in source_paths:
        if not path.exists():
            continue
        try:
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()
        except PermissionError:
            report.record("error", path.as_posix(), "no read permission")
            continue
        except UnicodeDecodeError:
            with open(path, "r") as f:
                content = f.read()

        matches = re.findall(ALIAS_PATTERN_DEF_FULL, content, re.DOTALL)
        for variable_name, definition_content in matches:
            name = variable_name.strip()
            if name in definitions:
                report.record("override", name, f"redefined in '{path.name}'")
            definitions[name] = definition_content.strip()

    return definitions

def update_readme_files(root_dir: Path, definitions: dict[str, str], report: Report) -> None:
    """Apply definitions to every README listed in Config.PATH_READMES."""
    for path in Config().PATH_READMES:
        rel = path.as_posix()
        if not path.exists():
            report.record("missing", rel)
            continue
        status = update_single_readme(path, definitions, report)
        if status == "updated":
            report.record("updated", rel)
        elif status == "skipped":
            report.record("skipped", rel, "no changes needed")
        else:
            report.record("error", rel)

def update_single_readme(readme_path: Path, definitions: dict[str, str], report: Report) -> str:
    """Inject definitions into a single README file.

    Returns ``"updated"``, ``"skipped"``, or ``"error"``.
    """
    try:
        with open(readme_path, "r", encoding="utf-8") as f:
            content = f.read()
    except PermissionError:
        report.record("error", readme_path.as_posix(), "no read permission")
        return "error"
    except UnicodeDecodeError:
        with open(readme_path, "r") as f:
            content = f.read()

    needs_update = False

    def replace_content(match):
        nonlocal needs_update
        variable_name = match.group(1).strip()
        if variable_name in definitions:
            needs_update = True
            start = ALIAS_PATTERN_CONT_START.format(name=variable_name)
            end   = ALIAS_PATTERN_CONT_END.format(name=variable_name)
            return f"{start}\n{definitions[variable_name]}\n{end}"
        else:
            report.record("error", variable_name, "definition not found in aliases.md")
            return match.group(0)

    new_content = re.sub(ALIAS_PATTERN_CONT_FULL, replace_content, content, flags=re.DOTALL)

    if needs_update:
        try:
            with open(readme_path, "w", encoding="utf-8") as f:
                f.write(new_content)
            return "updated"
        except PermissionError:
            report.record("error", readme_path.as_posix(), "no write permission")
            return "error"

    return "skipped"

def md_syncAliases() -> int:
    cfg    = Config()
    report = Report("md_aliases")
    report.step("Sync Aliases")
    report.detail("@", cfg.DIR_PROJECT_ROOT.as_posix())
    report.detail("~", f"aliases: {cfg.PATH_ALIASES.as_posix()}")

    if not cfg.PATH_ALIASES.exists():
        report.record("error", cfg.PATH_ALIASES.as_posix(), "aliases file not found")
        return 1

    report.step(f"Scanning {len(cfg.DEFINITION_PATHS)} file(s) for definitions")
    definitions = extract_definitions(cfg.DEFINITION_PATHS, report)
    report.detail("+", f"{len(definitions)} definition(s) found")

    update_readme_files(cfg.DIR_PROJECT_ROOT, definitions, report)
    report.summary("Processed", noun="README file")
    return report.exit_code

if __name__ == "__main__":
    sys.exit(md_syncAliases())
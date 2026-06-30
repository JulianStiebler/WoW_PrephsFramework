"""
md_generateToC.py - Auto-generate a Table of Contents for README files.

Scans markdown headers (## to ######) and writes a ToC block between:
  <!-- START DEFINITION TOC --> … <!-- END DEFINITION TOC -->
"""
import re
import sys
from pathlib import Path
from modules.config import Config, Report, TOC_PATTERN_CONT_FULL, TOC_PATTERN_CONT_START, TOC_PATTERN_CONT_END, TOC_GEN_HEADER

def generate_toc_from_content(content: str) -> str | None:
    """Build a markdown ToC string from header lines in *content*.

    Skips headers inside fenced code blocks and the ToC block itself.
    Returns ``None`` if no H2+ headers are found outside those regions.
    """
    lines = content.split("\n")
    toc_lines = []
    anchor_counts = {}  # Track duplicate anchors
    
    # Skip the TOC block itself when scanning for headers
    in_toc_block = False
    in_code_block = False
    code_fence = ""

    for line in lines:
        # Track fenced code blocks (``` or ~~~, optionally with a language tag)
        fence_match = re.match(r"^(`{3,}|~{3,})", line)
        if fence_match:
            fence = fence_match.group(1)
            if not in_code_block:
                in_code_block = True
                code_fence = fence[0] * len(fence)  # normalise to pure char
            elif line.strip().startswith(code_fence):
                in_code_block = False
                code_fence = ""
            continue

        if in_code_block:
            continue

        # Skip TOC definition block
        if TOC_PATTERN_CONT_START in line:
            in_toc_block = True
            continue
        elif TOC_PATTERN_CONT_END in line:
            in_toc_block = False
            continue

        if in_toc_block:
            continue
        
        # Match markdown headers (## to ######, ignore single #)
        match = re.match(r"^(#{2,6})\s+(.+)$", line)
        if match:
            level = len(match.group(1))  # Number of # symbols
            title = match.group(2).strip()
            
            # Remove markdown formatting from title
            clean_title = re.sub(r"\[([^\]]+)\]\([^\)]+\)", r"\1", title)  # Remove links
            clean_title = re.sub(r"`([^`]+)`", r"\1", clean_title)  # Remove code blocks
            clean_title = re.sub(r"\*\*([^\*]+)\*\*", r"\1", clean_title)  # Remove bold
            clean_title = re.sub(r"\*([^\*]+)\*", r"\1", clean_title)  # Remove italic
            clean_title = re.sub(r"\_([^\_]+)\_", r"\1", clean_title)  # Remove underscores
            
            # Create anchor (GitHub style)
            anchor = clean_title.lower()
            # Remove special characters, keep only alphanumeric, spaces, and hyphens
            anchor = re.sub(r"[^\w\s-]", "", anchor)
            # Replace spaces with hyphens
            anchor = re.sub(r"\s+", "-", anchor)
            # Remove duplicate hyphens
            anchor = re.sub(r"-+", "-", anchor)
            # Strip leading/trailing hyphens
            anchor = anchor.strip("-")
            
            # Handle duplicate anchors (GitHub appends -1, -2, etc.)
            base_anchor = anchor
            if base_anchor in anchor_counts:
                anchor_counts[base_anchor] += 1
                anchor = f"{base_anchor}-{anchor_counts[base_anchor]}"
            else:
                anchor_counts[base_anchor] = 0
            
            # Create indented TOC entry
            indent = "  " * (level - 2)  # Start at 0 indent for ##
            toc_line = f"{indent}- [{clean_title}](#{anchor})"
            toc_lines.append(toc_line)
    
    if not toc_lines:
        return None
    
    return "\n".join(toc_lines)

def update_readme_toc(readme_path: Path, report: Report) -> bool:
    """Write an up-to-date ToC block into *readme_path*.

    Returns ``True`` if the file was modified, ``False`` otherwise.
    """
    try:
        with open(readme_path, "r", encoding="utf-8") as f:
            content = f.read()
    except (PermissionError, UnicodeDecodeError) as e:
        report.record("error", readme_path.as_posix(), str(e))
        return False

    # Check if TOC block exists
    if TOC_PATTERN_CONT_START not in content:
        report.record("skip", readme_path.as_posix(), "no TOC markers found")
        return False

    # Generate TOC
    toc_content = generate_toc_from_content(content)

    if toc_content is None:
        report.record("empty", readme_path.as_posix(), "no H2+ headers found outside code blocks")
        return False

    # Replace TOC block; use a lambda so toc_content is never treated as a
    # re replacement string (avoids \1, \g<> interpretation on backslashes).
    replacement = (
        f"{TOC_PATTERN_CONT_START}\n"
        f"{TOC_GEN_HEADER}\n\n"
        f"{toc_content}\n"
        f"{TOC_PATTERN_CONT_END}"
    )
    match = re.search(TOC_PATTERN_CONT_FULL, content, flags=re.DOTALL)
    if not match:
        report.record("error", readme_path.as_posix(), "TOC markers found but re.search failed")
        return False

    old_block = match.group(0)
    entry_count = toc_content.count("\n- ") + (1 if toc_content.startswith("- ") else 0)

    if old_block == replacement:
        report.record("skipped", readme_path.as_posix(), f"{entry_count} entries already up to date")
        return False

    new_content = content[:match.start()] + replacement + content[match.end():]
    try:
        with open(readme_path, "w", encoding="utf-8") as f:
            f.write(new_content)
        report.record("updated", readme_path.as_posix(), f"{entry_count} entries written")
        return True
    except PermissionError:
        report.record("error", readme_path.as_posix(), "no write permission")
        return False


def md_generateTableOfContents() -> int:
    cfg    = Config()
    report = Report("md_toc")
    report.step("Generate Table of Contents")
    report.detail("@", cfg.DIR_PROJECT_ROOT.as_posix())

    for path in cfg.PATH_READMES:
        if path.exists():
            update_readme_toc(path, report)
        else:
            report.record("missing", path.as_posix())

    report.summary("Processed", noun="README file")
    return report.exit_code

if __name__ == "__main__":
    sys.exit(md_generateTableOfContents())
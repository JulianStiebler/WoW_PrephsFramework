import os
import posixpath
import pathlib
from typing import Any, Dict, List, Optional
from modules.config import Config, Report, ADDITIONAL_IGNORE_DIRS, ADDITIONAL_IGNORE_FILES, IconMapper

DEFAULT_IGNORE_DIRS = {
    # Python
    "__pycache__",
    ".pytest_cache",
    "venv",
    ".venv",
    "env",
    "build",
    "dist",
    "*.egg-info",
    "vendor",
    
    # IDE
    ".idea",
    ".vscode",
    
    # Version Control
    ".git",
    ".svn",
    ".hg",
    
    # Node
    "node_modules",
    
    # Build outputs
    "bin",
    "obj",
    "out",
    "target",
    
    # Cache
    ".cache",
    ".mypy_cache",
    
    # OS
    "$RECYCLE.BIN",
    "System Volume Information",
} | ADDITIONAL_IGNORE_DIRS

DEFAULT_IGNORE_FILES = {
    # Python
    "__init__.py",
    "*.pyc",
    "*.pyo",
    "*.pyd",
    
    # IDE files
    ".idea",
    ".vscode",
    "*.code-workspace",
    
    # Version control
    ".git",
    ".gitignore",
    ".gitattributes",
    ".svn",
    
    # Build and cache
    "build",
    "dist",
    "*.egg-info",
    ".pytest_cache",
    ".coverage",
    
    # Environment
    "venv",
    ".env",
    ".venv",
    "env",
    
    # Temporary files
    "*.tmp",
    "*.bak",
    "*~",
    "*.swp",
    
    # OS specific
    ".DS_Store",
    "Thumbs.db"
} | ADDITIONAL_IGNORE_FILES


def should_include_path(name: str, is_dir: bool, ignore_patterns: Optional[set] = None) -> bool:
    """Return ``True`` if *name* should be included given the active ignore patterns."""
    from fnmatch import fnmatch
    
    # Choose default patterns based on type
    default_patterns = DEFAULT_IGNORE_DIRS if is_dir else DEFAULT_IGNORE_FILES
    patterns = default_patterns.copy()
    
    if ignore_patterns:
        patterns.update(ignore_patterns)
    
    return not any(fnmatch(name, pattern) for pattern in patterns)

def get_category_description(category_path: str, report: Report) -> str:
    """Return the first paragraph from *category_path*/README.md, or a fallback string."""
    readme_path = os.path.join(category_path, "README.md")
    if not os.path.exists(readme_path):
        return "Utility modules and helpers"

    try:
        with open(readme_path, "r", encoding="utf-8") as f:
            content = f.read()

        lines = [line.strip() for line in content.split("\n") if line.strip()]

        # Skip title and find the first paragraph
        for i, line in enumerate(lines):
            if line.startswith("# "):
                return lines[i + 1].lstrip("#").strip() if i + 1 < len(lines) else "No description available."

    except Exception as e:
        report.record("error", str(category_path), f"could not read README: {e}")

    return "Utility modules and helpers"

def generate_markdown_structure(
    # Required parameters
    start_path: pathlib.Path = ".",

    # Repository info
    repo: Optional[str] = None,
    author: Optional[str] = None,
    branch: Optional[str] = None,

    # Document formatting
    title: str = "# 📚 Directory Overview\n\n",
    intro: str = "A comprehensive collection of folders and files.\n\n",
    output_file: str = "DIRECTORY.md",

    # Filtering options
    ignore_dirs: Optional[List[str]] = None,
    allowed_extensions: Optional[List[str]] = None,
    ignore_patterns: Optional[List[str]] = None,

    # Customisation
    file_icons: Optional[Dict[str, str]] = None,
    links_disabled: Optional[bool] = False,

    # Reporting
    report: Optional[Report] = None,
) -> bool:
    """Walk *start_path* and write a structured DIRECTORY.md.

    Builds a summary table and a detailed per-folder listing, optionally
    linking files to their GitHub URLs when *repo*, *author* and *branch*
    are provided.

    Returns ``True`` on success, ``False`` on any unhandled exception.    Pass a ``Report`` instance to get structured logging instead of raw prints.    """
    try:
        ignore_dirs = ignore_dirs or [".git", ".github", "__pycache__"]
        icon_mapper = IconMapper(file_icons)
        allowed_extensions = allowed_extensions or [".py"]

        repo_url = f"https://www.github.com/{author}/{repo}/tree/{branch}" if repo and author and branch else None
        links_disabled = links_disabled or not repo_url

        table_header = (
            "| 📂 Folder | 📊 File Count | 📑 Sub-Folders | 🗑️ Description |\n"
            "|-----------|---------------|----------------|----------------|\n"
        )
        toc = [title, intro, table_header]
        categories: Dict[str, Dict[str, Any]] = {}

        for root, dirs, files in os.walk(start_path):
            dirs[:] = [d for d in dirs if d not in ignore_dirs]

            # Skip root directory or ignored directories
            rel_root = os.path.relpath(root, start_path)
            if rel_root == "." or any(part in ignore_dirs for part in rel_root.split(os.sep)):
                continue

            # Split relative path into parts
            parts = rel_root.split(os.sep)
            if not parts:
                continue

            main_category = parts[0]
            subfolder_path = os.sep.join(parts[1:]) if len(parts) > 1 else None
            
            if main_category not in categories:
                categories[main_category] = {
                    "root_files": [],
                    "subfolders": {},
                    "count": 0,
                    "description": get_category_description(os.path.join(start_path, main_category), report or Report("dir_md"))
                }

            dirs[:] = [
                d for d in dirs 
                if should_include_path(d, is_dir=True, ignore_patterns=ignore_patterns)
            ]
            
            # Filter files
            valid_files = [
                f for f in files 
                if f.endswith(tuple(allowed_extensions)) 
                and should_include_path(f, is_dir=False, ignore_patterns=ignore_patterns)
            ]
            
            for file in valid_files:
                # Generate relative path for URLs
                rel_path = os.path.relpath(os.path.join(root, file), start_path)
                # Convert to forward slashes for URLs regardless of platform
                url_path = rel_path.replace(os.sep, "/")

                file_icon = icon_mapper.get_icon(file)
                if links_disabled:
                    file_link = f"{file_icon} `{file}`"
                else:
                    file_link = f"{file_icon} [`{file}`]({posixpath.join(repo_url, url_path)})"

                if subfolder_path:
                    if subfolder_path not in categories[main_category]["subfolders"]:
                        categories[main_category]["subfolders"][subfolder_path] = {
                            "files": [],
                            "description": get_category_description(root, report or Report("dir_md"))
                        }
                    categories[main_category]["subfolders"][subfolder_path]["files"].append(file_link)
                else:
                    categories[main_category]["root_files"].append(file_link)
                categories[main_category]["count"] += 1


        for category, info in sorted(categories.items()):
            subfolder_count = len(info["subfolders"])
            subfolder_cell = f"{subfolder_count}" if subfolder_count > 0 else ""
            toc.append(
                f"| 📂 [{category}](#{category.lower()}) | "
                f"{info['count']} | "
                f"{subfolder_cell} | "
                f"{info['description']} |\n"
            )

        toc.append("\n## 🔍 Detailed Project Listing\n\n")

        for category, info in sorted(categories.items()):
            # Convert to URL-friendly path
            category_url_path = category.replace(os.sep, "/")
            folder_url = f"`{category}`" if links_disabled else f"[{category}]({posixpath.join(repo_url, category_url_path)})"
            toc.append(f"### 📂 {folder_url}\n")
            toc.append(f"*{info['description']}*\n\n")

            for file_link in sorted(info["root_files"]):
                toc.append(f"- {file_link}\n")

            # Organize subfolders by path depth
            path_map = {}
            for subfolder, subinfo in sorted(info["subfolders"].items()):
                parts = subfolder.split(os.sep)
                depth = len(parts)
                folder_name = parts[-1]
                
                if depth not in path_map:
                    path_map[depth] = []
                    
                path_map[depth].append({
                    "full_path": subfolder,
                    "name": folder_name,
                    "files": subinfo["files"]
                })
            
            # Process subfolders by depth
            for depth in sorted(path_map.keys()):
                for folder_info in path_map[depth]:
                    indent = "  " * (depth - 1)
                    subfolder_path = folder_info["full_path"]
                    folder_name = folder_info["name"]
                    
                    # Convert to URL-friendly path
                    url_path = posixpath.join(category_url_path, subfolder_path.replace(os.sep, "/"))
                    subfolder_url = f"`{folder_name}`" if links_disabled else f"[`{folder_name}`]({posixpath.join(repo_url, url_path)})"
                    
                    toc.append(f"{indent}- 📂 {subfolder_url}\n")
                    
                    for sf_file in sorted(folder_info["files"]):
                        toc.append(f"{indent}  - {sf_file}\n")

            toc.append("\n")
            toc.append("--- \n")

        output_full_path = pathlib.Path(start_path) / output_file
        with open(output_full_path, "w", encoding="utf-8") as f:
            f.writelines(toc)

        if report is not None:
            report.record("created", str(output_full_path), f"written to {output_full_path.parent.resolve()}")
        else:
            print(f"🗄️ Generated {output_file} in {output_full_path.parent.resolve()}")
        return True
    except Exception as e:
        if report is not None:
            report.record("error", output_file, str(e))
        else:
            print(f"Error: {e}")
        return False


def md_generateDirectoryMD() -> int:
    cfg    = Config()
    report = Report("md_dir")
    report.step("Generate Directory MD")
    report.detail("@", cfg.DIR_PROJECT_ROOT.as_posix())
    DEFAULT_IGNORE_DIRS.update([".preprocess", ".github", ".vscode", ".old"])
    generate_markdown_structure(
        start_path=cfg.DIR_PROJECT_ROOT,
        allowed_extensions=[".py", ".lua", ".toc", ".xml", ".blp", ".png"],
        output_file="DIRECTORY.md",
        repo=cfg.PROJECT_NAME,
        author=cfg.GITHUB_AUTHOR,
        branch=cfg.GITHUB_BRANCH,
        links_disabled=False,
        ignore_dirs=DEFAULT_IGNORE_DIRS,
        report=report,
    )
    report.summary("Generated", noun="directory file")
    return report.exit_code


if __name__ == "__main__":
    import sys
    sys.exit(md_generateDirectoryMD())

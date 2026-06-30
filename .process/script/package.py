import shutil
import sys
import glob # Added for pattern matching
from pathlib import Path
from modules.config import Config, Report

def pkg_createZipFiles() -> int:
    cfg = Config()
    report = Report("pkg_zip")
    report.step("Package Folders")
    
    package_dir = cfg.DIR_PROJECT_ROOT / ".package"
    package_dir.mkdir(exist_ok=True)
    report.detail("@", package_dir.as_posix())

    for mod_key, mod_data in cfg.PROJECT_METADATA.items():
        folder_name = mod_data.get("path")
        if not folder_name:
            continue
            
        # Semantic versioning string
        version_str = f"v{mod_data.get('major', 1)}.{mod_data.get('minor', 0)}.{mod_data.get('patch', 0)}"

        # SURGICAL CLEANUP: Delete only zips matching this module
        # Pattern: .package/PrephsFramework_Core_*.zip
        pattern = (package_dir / f"{folder_name}_*.zip").as_posix()
        for old_file in glob.glob(pattern):
            Path(old_file).unlink()
            report.detail("-", f"Removed: {Path(old_file).name}")

        source_dir = cfg.DIR_PROJECT_ROOT / folder_name
        if not source_dir.exists():
            continue

        output_base = package_dir / f"{folder_name}_{version_str}"

        try:
            shutil.make_archive(
                base_name=output_base.as_posix(),
                format="zip",
                root_dir=cfg.DIR_PROJECT_ROOT.as_posix(),
                base_dir=folder_name
            )
            report.record("created", f"{folder_name}_{version_str}.zip")
        except Exception as e:
            report.record("error", f"{folder_name}_{version_str}.zip", str(e))

    return report.exit_code

if __name__ == "__main__":
    sys.exit(pkg_createZipFiles())
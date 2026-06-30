"""
runPreProcess.py - Entry point for all PrephsFramework pre-processing steps.

Runs each preprocessing task in order and reports a combined exit code.
"""
import sys

from modules.config import Config, Report
from script import (
    md_generateTableOfContents, md_syncAliases, md_generateDirectoryMD,
    toc_syncGlobalData, pkg_createZipFiles
)


def main() -> int:
    cfg    = Config()
    report = Report("preproc", cfg=cfg)
    report.plan([
        "Generating Table of Contents",
        "Generating DIRECTORY.md",
        "Syncing aliases into README files",
        "Syncing module metadata into .toc files",
        "Packaging folders into .package/"
    ])

    report.step("Generating Table of Contents")
    report.result("generateTOC", md_generateTableOfContents())

    report.step("Generating DIRECTORY.md")
    report.result("MDGenerator", md_generateDirectoryMD())

    report.step("Syncing aliases into README files")
    report.result("syncAliases", md_syncAliases())

    report.step("Syncing module metadata into .toc files")
    report.result("parseDataIntoTocs", toc_syncGlobalData())

    report.step("Packaging folders into .package/")
    report.result("packageFolders", pkg_createZipFiles())

    return report.stop("All processing steps completed successfully")


if __name__ == "__main__":
    sys.exit(main())

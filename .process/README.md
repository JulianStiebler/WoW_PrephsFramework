# PrephsFramework Build System

A Python-based automated preprocessing and packaging system.

---

## 🛠️ Features

* **Centralized Configuration:** Uses a single `globalvars.preph` file to manage versioning, metadata, and dependencies across all addon modules.
* **`.toc` File Synchronization:** Automatically injects and updates metadata (Version, Title, Author, Interface, etc.) into WoW `.toc` files based on the global configuration.
* **Documentation Automation:**
    * **TOC Generation:** Scans README files and automatically generates Markdown Tables of Contents.
    * **Directory Mapping:** Generates a comprehensive `DIRECTORY.md` tree with GitHub-ready links and file counting.
    * **Alias Syncing:** Propagates shared documentation blocks from an `aliases.md` file into placeholder tags across all module READMEs.
* **Release Packaging:** Zips all modules into a `.package/` folder, appending semantic versions to the filenames (e.g., `PrephsFramework_Core_v1.0.0.zip`).
* **VS Code Integration & File Watching:** Includes a watchdog script and a configurator to generate VS Code tasks, automatically triggering rebuilds whenever `globalvars.preph` is saved.

---

## 📂 System Structure

The build system is composed of several modular Python scripts:

* `process.py`: The main entry point that runs all preprocessing tasks in sequence.
* `configure.py`: A one-time setup script that generates `.vscode/tasks.json` for IDE integration.
* `config.py`: The core configuration singleton that parses `globalvars.preph` and provides paths, metadata, and centralized logging.
* `globalvarsWatcher.py`: A `watchdog`-based script that monitors `globalvars.preph` and triggers the build process on file save.
* **Task Modules:**
    * `md_generateToC.py`: Handles Markdown Table of Contents injection.
    * `md_generatedDirectoryMD.py`: Builds the `DIRECTORY.md` overview.
    * `md_syncAliases.py`: Replaces `<!-- START CONTENT {{name}} -->` tags with shared aliases.
    * `toc_syncGlobalData.py`: Updates `.toc` directives while preserving custom/untracked variables.
    * `package.py`: Zips up the final addon folders.

---

## 🚀 Setup & Installation

1.  **Prerequisites:** Ensure you have Python 3.x installed. You will also need the `watchdog` package for the auto-builder.
    ```bash
    pip install watchdog
    ```
2.  **Initialize VS Code Tasks:** Run the configure script to generate a `.vscode/tasks.json` file. This allows you to run the watcher as a background task in VS Code.
    ```bash
    python configure.py
    ```

---

## 💻 Usage

### Manual Build
To run the entire pipeline manually (update docs, sync `.toc` files, and package zips), execute the main process script:
```bash
python process.py
```
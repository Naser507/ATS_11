ATS_11 Project Workbench
Welcome to the ATS_11 development environment. This repository is not just a codebase; it is a fully structured "Workbench" designed to jumpstart cross-platform C++ applications using wxWidgets.

🚀 Quick Start: Deploy Workbench
If you want to start your own project using this exact directory structure and build system, run the following command in your terminal from the location where you want the project folder created:

Bash
curl -L https://github.com/Naser507/ATS_11/raw/master/z_%20Extras/Workbench_Template.tar.gz | tar -xz
🛠 Project Structure
The workbench is organized to separate source code, assets, and automated build outputs:

/client & /server: Cross-platform source code (Linux/Windows).

/scripts: Automation tools for building (build.sh), packaging, and Git management.

/assets: Centralized storage for images, sounds, and icons.

/include & /lib: Dedicated spaces for headers and external libraries (like wxWidgets).

/Release_beta: Automated staging area for production-ready binaries and release notes.

⚙️ Post-Extraction Setup
After extracting the workbench, there are two small steps to make it yours:

Update Paths: Open scripts/build.sh and ensure the project path matches your local machine.

Link wxWidgets: The /lib/wxWidgets folder is a placeholder. You must point your compiler to your local wxWidgets installation or update the library paths in your build scripts.

Review Docs: Check z_ Extras/Before_starting.txt for a detailed breakdown of the environment.

📜 Automation Scripts
The workbench comes pre-loaded with utility scripts in the /scripts directory:

build.sh: Compiles the project.

full_delivery.sh: Runs the full build and packaging pipeline.

git_update.sh: Streamlines commits and pushes.

inspect_project.sh: Quickly visualizes the project tree.

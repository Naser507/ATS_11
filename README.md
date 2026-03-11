# ATS_11 Project Workbench

A structured boilerplate for cross-platform C++ development with wxWidgets.

## 🚀 Quick Start (Linux)
To download and extract the full workbench structure into your current folder, run this command:

curl -L https://github.com/Naser507/ATS_11/raw/master/z_%20Extras/Workbench_Template.tar.gz | tar -xz

---

## 📂 Workbench Folders
* **client/server**: Source code for both ends.
* **scripts**: Automation for building and packaging.
* **assets**: Images, sounds, and icons.
* **include/lib**: Headers and external libraries (wxWidgets).
* **Release_beta**: Staging area for your builds.

---

## ⚙️ Initial Setup
1. **Permissions**: Run `chmod +x scripts/*.sh` to enable the build scripts.
2. **Paths**: Update the directory paths in `scripts/build.sh` to match your local machine.
3. **Libraries**: Link your local `wxWidgets` installation in the `/lib` folder.

For more details, see: `z_ Extras/Before_starting.txt` 

SOME PROBLEMS : The issue seem to be not the functional part of the pipeline, but the naming, if I name it something else other than the default name, it will compile the previous source code, but if I keep the default name, it correctly compiles the currenct source code. this needs some deeper investigation. 


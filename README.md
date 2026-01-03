# HDB-DOS/16

A patch for HDB-DOS for the TRS-80 Color Computer, adding new functionalities by extending the ROM from 8KB to 16KB.

How to build your own HDB-DOS/16 (instructions for Linux):

- Install all system requirements for building Toolshed and HDB-DOS
    (See https://github.com/nitros9project/toolshed?tab=readme-ov-file#building-on-linux)
- Build and install Toolshed
- Clone this repository (you already did that)
- Change to the repository directory (you probably already did that)
- Run:
    `./prepare-toolshed.sh`

This script will:

- Clone the Toolshed original repository to a sister folder;
- Apply the HDB-DOS/16 patch
- Build `cocoroms` and `hdbdos` within Toolshed
- Create a binary package by running `hdbdos/mk16kpackage.sh`
- Copy the 16KB ROMs for various hardware configurations back into the HDB-DOS/16 directory
- More information in `README-16K.txt`

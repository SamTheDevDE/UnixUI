# LTCCT-Template

A Lua template project for ComputerCraft: Tweaked in Minecraft.

## Description

This project provides a template for developing ComputerCraft programs using Lua.

## Structure

```
src/          - Source code files
```

## Getting Started

1. Clone this repository
2. Add your Lua scripts to the `src/` directory
3. Deploy to your ComputerCraft computer

## GitHub Pages Manifest

This repo publishes a site with a `manifest.json` listing all files under `src/`, along with sizes and SHA-256 checksums. The site serves the files under `files/` keeping their repo-relative paths.

- Pages URL: `https://SamTheDevDE.github.io/LTCCT-Template`
- Manifest URL: `https://SamTheDevDE.github.io/LTCCT-Template/manifest.json`

### ComputerCraft Installer

Use `src/install.lua` on a ComputerCraft: Tweaked computer (HTTP must be enabled). It fetches the manifest and downloads files locally preserving paths.

Example (paste into CC shell):

```
wget https://SamTheDevDE.github.io/LTCCT-Template/files/src/install.lua install.lua
lua install.lua
```

Adjust `TARGET_DIR` in `src/install.lua` to change the install location.

## Requirements

- Minecraft with ComputerCraft: Tweaked mod

## License

[Add your license here]

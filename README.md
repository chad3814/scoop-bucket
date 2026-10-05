# chad3814/scoop-bucket

[Scoop](https://scoop.sh) manifests for [zenvik](https://github.com/chad3814/zenvik), which remuxes Blu-ray and DVD disc images to MKV.

```powershell
scoop bucket add chad3814 https://github.com/chad3814/scoop-bucket
scoop install chad3814/zenvik        # the zenvik command-line tool
scoop install chad3814/zenvik-gui    # the Zenvik desktop app
```

- `zenvik` installs `zenvik.exe` on your PATH. It includes `mkvmerge.exe` from [MKVToolNix](https://mkvtoolnix.download) (GPLv2; the notices are in the app folder).
- `zenvik-gui` installs the Zenvik app, with a Start-menu shortcut. It includes its own `mkvmerge`, and needs the Microsoft Edge WebView2 runtime, which Windows 11 includes.

zenvik's release workflow updates these manifests on every release, after `check.ps1` has proved they install. To check by hand on Windows with Scoop: `./check.ps1`.

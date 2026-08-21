# Koollook KDE 2 window decoration

Port of [kdecoration2-kde2](https://github.com/repos-holder/kdecoration2-kde2) (Christoph Feck) to **KDecoration3 / Plasma 6**.

```bash
cd theme/window-decoration/kdecoration-kde2
cmake -B build -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build
sudo cmake --install build
```

Then: System Settings → Window Decorations → **Koollook KDE 2**.

`./theme/install.sh` builds and installs to `~/.local` if cmake/KF6 are present.

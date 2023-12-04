Fex-Android is script install FEX-EMU for Android in Termux Without Root

## Installation
```
$ curl https://raw.githubusercontent.com/AllPlatform/Fex-Android/main/fex-android.sh -o fex.sh; bash fex.sh
```
## Device Support
from Android 8 onwards
## Mesa3D Turnip Vulkan Driver
- Support from Adreno 6xx
- Adreno 7xx ?? 
- mali GPU etc. not support
## minimum system recommended
- Snapdragon 845, 855
- 6GB RAM, 8GB RAM
## Root File System Information
- Ubuntu 22.04.3 LTS (Jammy Jellyfish) Aarch64
- Ubuntu 22.04.3 LTS (Jammy Jellyfish) X86_64
- Wine 7.12 x86_64
## Acknowledgements
Special thanks to the contributions of the following individuals and projects:
- [FEX-EMU](https://github.com/FEX-Emu/FEX)
- [Wine](https://gitlab.winehq.org/wine/wine)
- [Mesa3D](https://www.mesa3d.org/)
- [DXVK](https://github.com/doitsujin/dxvk)
- [DXVK-Async](https://github.com/Sporif/dxvk-async)
- [Termux And Termux-X11](https://github.com/termux)
- [proot](https://github.com/proot-me/proot)
## Note
fex works through proot which is quite slow, but cpu processing speed is not affected much, and quite consumes a lot of ram



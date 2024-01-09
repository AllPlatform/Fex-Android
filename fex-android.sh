#!/data/data/com.termux/files/usr/bin/bash
fex="FEX-Android Installation"

function check_storage
{
    dialog --title "$fex" --msgbox "Please allow access storage permission" 10 50
    am broadcast --user 0 --es com.termux.app.reload_style storage -a com.termux.app.reload_style com.termux >/dev/null
}

function termux_install
{
    termux-change-repo
    yes | pkg update
    pkg install x11-repo -y
    pkg install tsu termux-x11-nightly wget proot pulseaudio xz-utils -y
    rm /data/data/com.termux/files/usr/bin/fex
    rm -rf /data/data/com.termux/files/home/Fex-Android/*
    rm -r /sdcard/Fex-Android/*
    wget https://raw.githubusercontent.com/doitsujin/dxvk/master/dxvk.conf
    mv dxvk.conf /sdcard/Fex-Android/
    if grep -q "anonymous" ~/../usr/etc/pulse/default.pa;then
	echo "module already present"
    else
	echo "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" >> ~/../usr/etc/pulse/default.pa
    fi

    echo "exit-idle-time = -1" >> ~/../usr/etc/pulse/daemon.conf
    echo "autospawn = no" >> ~/../usr/etc/pulse/client.conf
    clear
    wget https://github.com/AllPlatform/Fex-Android/releases/download/v1.3-update/ubuntu.tar.xz -O ubuntu.tar.xz
    echo -e "\e[32m[+] Extracting Ubuntu 22.04.3 LTS RootFS...\e[0m"
    tar -xf ubuntu.tar.xz
    # echo -e "\e[32m[+] Extracting wine...\e[0m"
    echo -e "\e[32m[+] installation is complete\e[0m"
    echo -e "Type \e[31mfex\e[0m command to run"
    rm ubuntu.tar.xz

}

function fexinstall()
{
    dialog --title "$fex" --yesno "Do you want install FEX-Emu?" 10 50
    if [ $? == 0 ]; then
	termux_install
    else
	cd ~
	rm -r Fex-Android
	exit 0
    fi
}

function main()
{
    cd ~
    mkdir Fex-Android
    cd Fex-Android
    check_storage
    fexinstall

}
main

cat <<'EOF' >> start-proot.sh
#!/data/data/com.termux/files/usr/bin/bash
pulseaudio --start
source /data/data/com.termux/files/home/Fex-Android/start.sh
unset LD_PRELOAD
unset TMPDIR
unset PREFIX
unset BOOTCLASSPATH
unset ANDROID_ART_ROOT
unset ANDROID_DATA
unset ANDROID_I18N_ROOT
unset ANDROID_ROOT
unset ANDROID_TZDATA_ROOT
unset COLORTERM
unset DEX2OATBOOTCLASSPATH
export DXVK_CONFIG_FILE=/sdcard/Fex-Android/dxvk.conf
export USE_HEAP=1
export DISPLAY=:1
export MESA_LOADER_DRIVER_OVERRIDE=zink
export GALLIUM_DRIVER=zink
export ZINK_DESCRIPTORS=lazy
export PULSE_SERVER=127.0.0.1
export DXVK_HUD="devinfo,fps,api,version,gpuload"
export DXVK_ASYNC=1
SHELL=/bin/bash
HOME=/root
LANG=C.UTF-8
PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games
cmd="/data/data/com.termux/files/usr/bin/proot"
cmd+=" --link2symlink"
cmd+=" -0"
cmd+=" -r ubuntu-fs64"
cmd+=" -b /dev"
cmd+=" -b /proc"
cmd+=" -b /sys"
cmd+=" -b ubuntu-fs64/root:/dev/shm"
cmd+=" -b /data/data/com.termux/files/usr/tmp:/tmp"
cmd+=" -b /sdcard"
cmd+=" -w /root"
cmd+=" /bin/FEXInterpreter"
cmd+=" $cmdstart"
$cmd
EOF

cat <<'EOF' >> start-chroot.sh
#!/data/data/com.termux/files/usr/bin/bash
sudo rm -r /data/data/com.termux/files/usr/tmp/.wine*
sudo mount --bind /proc ubuntu-fs64/proc
sudo mount --bind /dev ubuntu-fs64/dev
sudo mount --bind /sys ubuntu-fs64/sys
sudo mount --bind /data/data/com.termux/files/usr/tmp ubuntu-fs64/tmp
sudo mount -t devpts devpts ubuntu-fs64/dev/pts
sudo mount --bind /sdcard ubuntu-fs64/sdcard
sudo chown root:root ubuntu-fs64/root/.wine
pulseaudio --start
source /data/data/com.termux/files/home/Fex-Android/start.sh
unset LD_PRELOAD
unset TMPDIR
unset PREFIX
unset BOOTCLASSPATH
unset ANDROID_ART_ROOT
unset ANDROID_DATA
unset ANDROID_I18N_ROOT
unset ANDROID_ROOT
unset ANDROID_TZDATA_ROOT
unset COLORTERM
unset DEX2OATBOOTCLASSPATH
export DXVK_CONFIG_FILE=/sdcard/Fex-Android/dxvk.conf
export WINEDEBUG=-all
export USE_HEAP=1
export DISPLAY=:1
export MESA_LOADER_DRIVER_OVERRIDE=zink
export GALLIUM_DRIVER=zink
export ZINK_DESCRIPTORS=lazy
export PULSE_SERVER=127.0.0.1
export DXVK_HUD="devinfo,fps,api,version,gpuload"
export DXVK_ASYNC=1
SHELL=/bin/bash
HOME=/root
LANG=C.UTF-8
PATH=/usr/local/sbin:/usr/local/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/games:/usr/local/games
cmd="/data/data/com.termux/files/usr/bin/sudo"
cmd+=" -E"
cmd+=" /data/data/com.termux/files/usr/bin/chroot"
cmd+=" ubuntu-fs64"
cmd+=" bin/FEXInterpreter"
cmd+=" $cmdstart"
$cmd
PATH="/data/data/com.termux/files/usr/bin"
user_t=$(whoami)
sudo rm -r ubuntu-fs64/tmp/.wine*
sudo chown $user_t:$user_t ubuntu-fs64/root/.wine
sudo umount -lf ubuntu-fs64/dev
sudo umount -lf ubuntu-fs64/sys
sudo umount ubuntu-fs64/tmp
sudo umount ubuntu-fs64/sdcard
sudo umount -lf ubuntu-fs64/proc
##
sudo chown $user_t:$user_t ubuntu-fs64/root/.wine
sudo umount -lf ubuntu-fs64/dev
sudo umount -lf ubuntu-fs64/sys
sudo umount ubuntu-fs64/tmp
sudo umount ubuntu-fs64/sdcard
sudo umount -lf ubuntu-fs64/proc
EOF

cat <<'EOF' >> fex
#!/data/data/com.termux/files/usr/bin/bash
FEX_DATA=/data/data/com.termux/files/home/Fex-Android/data/fex_data
source $FEX_DATA
cd /data/data/com.termux/files/home/Fex-Android
function start_ubuntu()
{
    echo kill
}
function uninstall()
{
    dialog --title "FEX-Android Uninstall" --yesno "Do you want uninstall Fex?" 10 50
    if [ $? == 0 ]; then
	rm -rf /data/data/com.termux/files/home/Fex-Android/
	rm /data/data/com.termux/files/usr/bin/fex
        exit 0
    else
        main_menu
    fi
}

function root_killall()
{
    sudo ps -ax | grep "[F]EXIn" | awk '{print $1}' | xargs sudo kill -9 > /dev/null 2>&1
    sudo ps -ax | grep "[p]ulseaudio" | awk '{print $1}' | xargs sudo kill -9 > /dev/null 2>&1
    sudo ps -ax | grep "[c]om.termux.x11.Loader" | awk '{print $1}' | xargs sudo kill -9 > /dev/null 2>&1
}
function root_kill()
{
    root_killall
    dialog --title "FEX-Android" --msgbox "All progress has been killed" 10 50
    main_menu
}

function _killall()
{
    ps -ax | grep "[p]root" | awk '{print $1}' | xargs kill -9 > /dev/null 2>&1
    ps -ax | grep "[F]EXIn" | awk '{print $1}' | xargs kill -9 > /dev/null 2>&1
    ps -ax | grep "[p]ulseaudio" | awk '{print $1}' | xargs kill -9 > /dev/null 2>&1
    ps -ax | grep "[c]om.termux.x11.Loader" | awk '{print $1}' | xargs kill -9 > /dev/null 2>&1
}

function _kill()
{
    _killall
    dialog --title "FEX-Android" --msgbox "All progress has been killed" 10 50
    main_menu
}
function write_env()
{
    printf "DRI3=$DRI3\nGL=$GL\nVK=$VK\nFEX=$FEX\nDBG=$DBG\nWINE=$WINE\nSCR=$SCR\nsrc1=$src1\nsrc2=$src2\nsrc3=$src3\nsrc4=$src4\nsrc5=$src5\nsrc6=$src6\nver=$ver" >$FEX_DATA
    chmod 777 $FEX_DATA
}
function start_fex()
{
    if [[ $DRI3 == "Enabled" ]]; then
	export FEX_X87REDUCEDPRECISION=true
	echo "cmdstart='/opt/wine/$WINE/bin/wine64 explorer /desktop=shell,$SCR /opt/tfm.exe'" > start.sh
    else
	export MESA_VK_WSI_DEBUG=sw
	export FEX_X87REDUCEDPRECISION=true
	echo "cmdstart='/opt/wine/$WINE/bin/wine64 explorer /desktop=shell,$SCR /opt/tfm.exe'" > start.sh
    fi
    _killall
    if [[ $DBG == "Enabled" ]]; then
	clear
	echo -e "\e[32m[+] run Debug mode in Proot\e[0m"
        echo -e "\e[32m[+] type command exit to automatic kill session\e[0m"
	termux-x11 :1 > /dev/null 2>&1 &
	am start -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1 &
	./start-proot.sh
	_kill
	main_menu
    fi
    termux-x11 :1 > /dev/null 2>&1 &
    checkroot=$(sudo whoami)
    if [[ $checkroot == "root" ]]; then
	./start-chroot.sh > /dev/null 2>&1 &
	mode="chroot root detected"
    else
	export WINEDEBUG=-all
	./start-proot.sh > /dev/null 2>&1 &
	mode="proot non-root detected"
    fi
    am start -n com.termux.x11/com.termux.x11.MainActivity
    dialog --title "FEX-Android" --msgbox "Tap Ok to Stop Wine\nWine Version $WINE\nscreen Resolution $SCR\nTermux-X11 DRI3 $DRI3\nMode $mode" 10 50
    if [[ $checkroot == "root" ]]; then
        root_kill
    else
        _kill
    fi
    main_menu
}
function config_fex()
{
    list=$(dialog --title "FEX-Android" --menu "FEX-Configuration" 20 70 25 \
	1 "DRI3    Enabled Termux-X11 DRI3                $DRI3" \
	2 "GL      Enabled OpenGL Thunk libs              $GL" \
	3 "Vulkan  Enabled Vulkan Thunk libs              $VK" \
	4 "FEX     Run FEX-Android when Termux startup    $FEX" \
	5 "DEBUG   Run Fex-emu with Wine Debug in proot   $DBG" 2>&1 >/dev/tty)
    if [[ $? == 1 ]]; then
        main_menu
    fi
    case $list in
    1)
	_dri3=$(dialog --title "FEX-Configuration" --menu "Do you want to Enabled/Disabled DRI3 feature?" \
		10 40 25 1 "Enabled" 2 "Disabled" 2>&1 >/dev/tty)
	case $_dri3 in
	1)
	    DRI3="Enabled"
	    write_env;;
	2)
	    DRI3="Disabled"
	    write_env;;
	esac
	config_fex
	;;
    2)
	_gl=$(dialog --title "FEX-Configuration" --menu "Do you want to Enabled/Disabled OpenGL feature?" \
		10 40 25 1 "Enabled" 2 "Disabled" 2>&1 >/dev/tty)
	case $_gl in
	1)
	    GL="Enabled"
	    write_env;;
	2)
	    GL="Disabled"
	    write_env;;
	esac
	config_fex
	;;
    3)
	_vk=$(dialog --title "FEX-Configuration" --menu "Do you want to Enabled/Disabled Vulkan feature?" \
		10 40 25 1 "Enabled" 2 "Disabled" 2>&1 >/dev/tty)
	case $_vk in
	1)
	    VK="Enabled"
	    echo '{"ThunksDB": {"Vulkan": 1}}' > ubuntu-fs64/root/.fex-emu/thunks.json
	    write_env;;
	2)
	    VK="Disabled"
	    echo '{"ThunksDB": {"Vulkan": 0}}' > ubuntu-fs64/root/.fex-emu/thunks.json
	    write_env;;
	esac
	config_fex
	;;
    4)
	_fex=$(dialog --title "FEX-Configuration" --menu "Do you want to Enabled/Disabled FEX feature?" \
		10 40 25 1 "Enabled" 2 "Disabled" 2>&1 >/dev/tty)
	case $_fex in
	1)
	    echo "fex" >~/.bashrc
	    FEX="Enabled"
            write_env;;
	2)
	    rm >~/.bashrc
	    FEX="Disabled"
            write_env;;
	esac
	config_fex;;
    5)
	_dbg=$(dialog --title "FEX-Configuration" --menu "Do you want to Enabled/Disabled debug mode?" \
                10 40 25 1 "Enabled" 2 "Disabled" 2>&1 >/dev/tty)
	case $_dbg in
	1)
	    DBG="Enabled"
	    write_env;;
	2)
	    DBG="Disabled"
	    write_env;;
	esac
	config_fex;;
    *)
	main_menu
	config_fex;;
    esac
    main_menu
}
function wine_scr()
{
    choice=$(dialog --radiolist "Screen Size" 20 40 25 \
	"1" "640x480" "$src1" \
	"2" "800x600" "$src2" \
	"3" "1024x768" "$src3" \
	"4" "1280x720" "$src4" \
	"5" "1600x900" "$src5" \
	"6" "1920x1080" "$src6" 2>&1 >/dev/tty)
    if [[ $? == 1 ]]; then
	main_menu
    fi
    case $choice in
    1)
	SCR="640x480";;
    2)
	SCR="800x600";;
    3)
	SCR="1024x768";;
    4)
	SCR="1280x720";;
    5)
	SCR="1600x900";;
    6)
	SCR="1920x1080";;
    esac
    write_env
    wine
}

function wine_csrc()
{
    width=$(dialog --inputbox "Width" 8 40 "" 2>&1 >/dev/tty)
    height=$(dialog --inputbox "Width" 8 40 "" 2>&1 >/dev/tty)
    SCR="$width""x""$height"
    write_env
    wine
}

function resetprefix()
{
    rm -rf ubuntu-fs64/root/.wine | dialog --infobox "removing files..." 10 50
    tar -xf ubuntu-fs64/opt/wine/$WINE/wine.tar.xz -C ubuntu-fs64/root | dialog --infobox "Extracting $WINE files..." 10 50
    dialog --title "Fex-Android $ver" --msgbox "$WINE has been set for Fex-Emu" 10 50
    main_menu
}

function wine_ver()
{
    _winever=$(dialog --menu "Select Wine version" 20 45 25 1 "wine-8.15-amd64 (Stable, Recommend)" 2 "wine-proton-8.0-4-amd64 (Unstable, Staging)" 3 "lutris-GE-Proton8-15-x86_64 (Unstable, Staging)" 2>&1 >/dev/tty)
    if [[ $? == 1 ]]; then
        wine;
    fi
    case $_winever in
    1)
	if [ -d ubuntu-fs64/opt/wine/wine-8.15-amd64 ]; then
	    WINE=wine-8.15-amd64
	    write_env
	    resetprefix
	    main_menu;
	else
	    dialog --yesno "Do you want download wine-8.15-amd64 from Kron4ek/Wine-Builds" 10 40
	    if [[ $? == 1 ]]; then
        	wine_ver;
    	    fi
	    clear
	    mkdir ubuntu-fs64/opt/wine/wine-8.15-amd64
	    WINE=wine-8.15-amd64
	    wget https://github.com/Kron4ek/Wine-Builds/releases/download/8.15/wine-8.15-amd64.tar.xz -O wine-8.15-amd64.tar.xz
	    wget https://github.com/AllPlatform/Fex-Android/releases/download/v1.3-update/prefix-wine-8.15-amd64.tar.xz -O ubuntu-fs64/opt/wine/wine-8.15-amd64/wine.tar.xz
	    echo -e "\e[32m[+] Completed Download $WINE ...\e[0m"
	    echo -e "\e[32m[+] Extracting Wine $WINE\e[0m"
	    tar -xf wine-8.15-amd64.tar.xz -C ubuntu-fs64/opt/wine
	    rm wine-8.15-amd64.tar.xz
            write_env
            resetprefix
            main_menu;
	fi
	;;
    2)
	if [ -d ubuntu-fs64/opt/wine/wine-proton-8.0-4-amd64 ]; then
            WINE=wine-proton-8.0-4-amd64
            write_env
            resetprefix
            main_menu;
	else
            dialog --yesno "Do you want download wine-proton-8.0-4-amd64 from Kron4ek/Wine-Builds" 10 40
            if [[ $? == 1 ]]; then
                wine_ver;
            fi
            clear
	    mkdir -p ubuntu-fs64/opt/wine/wine-proton-8.0-4-amd64
            wget https://github.com/Kron4ek/Wine-Builds/releases/download/proton-8.0-4/wine-proton-8.0-4-amd64.tar.xz -O wine-proton-8.0-4-amd64.tar.xz
            wget https://github.com/AllPlatform/Fex-Android/releases/download/v1.3-update/prefix-wine-proton-8.0-4-amd64.tar.xz -O ubuntu-fs64/opt/wine/wine-proton-8.0-4-amd64/wine.tar.xz
	    WINE=wine-proton-8.0-4-amd64
	    echo -e "\e[32m[+] Completed Download $WINE ...\e[0m"
            echo -e "\e[32m[+] Extracting Wine $WINE\e[0m"
	    tar -xf wine-proton-8.0-4-amd64.tar.xz -C ubuntu-fs64/opt/wine
	    rm wine-proton-8.0-4-amd64.tar.xz
            write_env
            resetprefix
            main_menu;
	fi
	;;
    3)
	if [ -d ubuntu-fs64/opt/wine/lutris-GE-Proton8-15-x86_64 ]; then
            WINE=lutris-GE-Proton8-15-x86_64
            write_env
            resetprefix
            main_menu;
        else
            dialog --yesno "Do you want download lutris-GE-Proton8-15-x86_64 from GloriousEggroll/wine-ge-custom" 10 40
            if [[ $? == 1 ]]; then
                wine_ver;
	    fi
            clear
	    mkdir -p ubuntu-fs64/opt/wine/lutris-GE-Proton8-15-x86_64
            wget https://github.com/GloriousEggroll/wine-ge-custom/releases/download/GE-Proton8-15/wine-lutris-GE-Proton8-15-x86_64.tar.xz -O wine-lutris-GE-Proton8-15-x86_64.tar.xz
	    wget https://github.com/AllPlatform/Fex-Android/releases/download/v1.3-update/prefix-wine-lutris-GE-Proton8-15-x86_64.tar.xz -O ubuntu-fs64/opt/wine/lutris-GE-Proton8-15-x86_64/wine.tar.xz
	    WINE=lutris-GE-Proton8-15-x86_64
	    echo -e "\e[32m[+] Completed Download $WINE ...\e[0m"
            echo -e "\e[32m[+] Extracting Wine $WINE\e[0m"
	    tar -xf wine-lutris-GE-Proton8-15-x86_64.tar.xz -C ubuntu-fs64/opt/wine
	    rm wine-lutris-GE-Proton8-15-x86_64.tar.xz
            write_env
            resetprefix
            main_menu;
	fi
	;;
    esac
    wine
}
function wine()
{
    output=$(dialog --menu "FEX-Android Wine Screen $SCR" 20 45 25 1 "Screen Size" 2 "Custom Screen Size" 3 "reset Wine Prefix" 4 "Select Wine version" 2>&1 >/dev/tty)
    if [[ $? == 1 ]]; then
	main_menu;
    fi
    case $output in
    1)
	wine_scr;;
    2)
	wine_csrc;;
    3)
	resetprefix;;
    4)
	wine_ver;;
    esac
    main_menu
}
function about_fex()
{
    dialog --title "FEX-Android Script ver $ver" --msgbox \
	" Termux script written by AkiraYuki\n\
	Fex-emu  https://github.com/FEX-Emu/FEX\n\
	Wine     https://gitlab.winehq.org/wine/wine\n\
	Mesa     https://gitlab.freedesktop.org/mesa\n\
	DXVK     https://github.com/doitsujin/dxvk\n\
	Termux   https://github.com/termux\n\
	Proot    https://github.com/proot-me" 30 65
    main_menu
}
function run_terminal()
{
    clear
    echo -e "\e[32m[+] run Terminal mode in Proot\e[0m"
    echo -e "\e[32m[+] type command  exit to automatic kill session\e[0m"
    echo "cmdstart='/bin/bash --login'" > start.sh
    ./start-proot.sh
    _kill
}
function main_menu()
{
    if [[ $WINE == "0" ]]; then
	wine_ver
    fi
    var=$(dialog --menu "FEX-Android $ver" 20 45 25 1 "Start FEX-Emu" 2 "Configure Fex" 3 "Wine" 4 "Run Terminal" 5 "Kill All" 6 "About" 7 "Uninstall" 8 "Exit" 2>&1 >/dev/tty)
    if [[ $? == 1 ]]; then
        exit 0
    fi
    case $var in
    1)
	start_fex;;
    2)
	config_fex;;
    3)
	wine;;
    4)
	run_terminal;;
    5)
	_kill;;
    6)
	about_fex;;
    7)
	uninstall;;
    8)
	exit 0;;
    esac
    exit 0
}
main_menu
EOF
cat <<'EOF' >> fex_data
DRI3=Enabled
GL=Disabled
VK=Enabled
FEX=Disabled
DBG=Disabled
WINE="0"
SCR="1280x720"
src1=off
src2=off
src3=off
src4=on
src5=off
src6=off
ver="1.3-update"
EOF

chmod +x start-chroot.sh
chmod +x fex
chmod +x fex_data
chmod +x start-proot.sh
mv fex /data/data/com.termux/files/usr/bin
mkdir -p /data/data/com.termux/files/home/Fex-Android/data/
mv fex_data /data/data/com.termux/files/home/Fex-Android/data/

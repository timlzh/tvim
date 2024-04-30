#!/bin/bash
addPathToWindows() {
	local p=$1
	cmd="[Environment]::SetEnvironmentVariable(\"PATH\", [Environment]::GetEnvironmentVariable(\"PATH\", [EnvironmentVariableTarget]::User) + \";$p\", [EnvironmentVariableTarget]::User)"
	powershell.exe -c $cmd
}

installFontForWindows() {
	local fontFolder=$1
	powershell.exe -c "$(/bin/cat "~/.config/nvim/installFont.ps1")Install-Fonts -Files \"$fontFolder\""
}

getWindowsFonts() {
	local cmd="[System.Console]::OutputEncoding=[System.Text.Encoding]::GetEncoding(65001);[System.Reflection.Assembly]::LoadWithPartialName(\"System.Drawing\") > \$null; [System.Drawing.Text.InstalledFontCollection]::new().Families | ForEach-Object { echo \$_.Name }"
	powershell.exe -c $cmd >/tmp/windowsFonts.txt
	for line in $(/bin/cat /tmp/windowsFonts.txt); do
		echo $line | tr -d '\r\n\t '
	done
}

info() {
	echo -e "\e[32m[+] $1\e[0m"
}

warning() {
	echo -e "\e[33m[*] $1\e[0m"
}

IS_WSL=false
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
	warning "WSL detected"
	IS_WSL=true
	WINDOWS_USER_FOLDER=$(wslpath $(cmd.exe /c "echo %USERPROFILE%"))
	WINDOWS_USER_FOLDER=$(echo $WINDOWS_USER_FOLDER | tr -d '\r\n\t ')
fi

sudo apt update

# Install Neovim 0.9.5
info "Installing Neovim 0.9.5..."
sudo apt remove neovim -y 2>/dev/null
if [ -f /tmp/nvim.tar.gz ]; then
	rm -rf /tmp/nvim.tar.gz
fi
wget https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz -O /tmp/nvim.tar.gz
mkdir -p ~/Documents/Apps
tar xvzf /tmp/nvim.tar.gz -C ~/Documents/Apps
rm -rf /tmp/nvim.tar.gz
ln -sf ~/Documents/Apps/nvim-linux64/bin/nvim ~/.local/bin/nvim

# Install Neovide
if [ $IS_WSL = true ]; then
	# Install Neovide for Windows
	info "Installing Neovide for Windows..."
	if [ -f /tmp/neovide.zip ]; then
		rm -rf /tmp/neovide.zip
	fi

	wget https://github.com/neovide/neovide/releases/download/0.12.2/neovide.exe.zip -O /tmp/neovide.zip
	NEOVIDE_PATH=${WINDOWS_USER_FOLDER}/AppData/Local/Programs/neovide
	mkdir -p ${NEOVIDE_PATH}
	unzip -o /tmp/neovide.zip -d ${NEOVIDE_PATH}
	rm -rf /tmp/neovide.zip

	addPathToWindows "\$ENV:USERPROFILE\\AppData\\Local\\Programs\\neovide"
	addPathToWindows $(wslpath -w ~/.local/bin)
	info "Neovide installed at ${NEOVIDE_PATH} and added to windows PATH."
else
	# Install Neovide for Linux
	info "Installing Neovide for Linux..."
	if [ -f /tmp/neovide.tar.gz ]; then
		rm -rf /tmp/neovide.tar.gz
	fi

	wget https://github.com/neovide/neovide/releases/download/0.12.2/neovide-linux-x86_64.tar.gz -O /tmp/neovide.tar.gz
	tar xvzf /tmp/neovide.tar.gz -C ~/Documents/Apps
	rm -rf /tmp/neovide.tar.gz
	ln -sf ~/Documents/Apps/neovide ~/.local/bin/neovide
fi

# init neovim
info "Downloading nvim config"
rm -rf ~/.config/nvim.bak
mv ~/.config/nvim ~/.config/nvim.bak
git clone https://github.com/timlzh/tvim ~/.config/nvim

# init neovide
if [ $IS_WSL = true ]; then
	NEOVIDE_CONFIG_PATH=${WINDOWS_USER_FOLDER}/AppData/Roaming/neovide
else
	NEOVIDE_CONFIG_PATH=~/.config/neovide
fi
mkdir -p ${NEOVIDE_CONFIG_PATH}
cp ~/.config/nvim/neovide/config.toml ${NEOVIDE_CONFIG_PATH}/config.toml
if [ $IS_WSL = true ]; then
	echo -e "wsl=true\nneovim_bin=\"$HOME/.local/bin/nvim\"\n$(/bin/cat ${NEOVIDE_CONFIG_PATH}/config.toml)" >${NEOVIDE_CONFIG_PATH}/config.toml
fi

# Download Sarasa Nerd Font
style="mono"
orthography="sc"
sarasaFontFileName="sarasa-${style}-${orthography}-nerd-font.zip"
pattern="sarasa-${style}-${orthography}-*-nerd-font.ttf"
fontDir="$HOME/.local/share/fonts"

rm -f "/tmp/${sarasaFontFileName}"

curl -fsSL "https://api.github.com/repos/jonz94/Sarasa-Gothic-Nerd-Fonts/releases/latest" |
	grep "browser_download_url.*${sarasaFontFileName}" |
	head -n 1 |
	cut -d '"' -f 4 |
	xargs curl -fL -o "/tmp/${sarasaFontFileName}"

# Download Cascadia Code Nerd Font
url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/CascadiaCode.zip"
rm -f "/tmp/CascadiaCode.zip"
wget $url -O "/tmp/CascadiaCode.zip"

info "Installing fonts..."
if [ $IS_WSL = false ]; then
	# Install the fonts
	unzip -o -d /tmp "/tmp/${sarasaFontFileName}"

	find -L /tmp -name $pattern 2>/dev/null | cut -d '/' -f 3 | xargs -I {} rm -f ${fontDir}/{}
	mkdir -p $fontDir
	find -L /tmp -name $pattern 2>/dev/null | xargs -I {} mv {} ${fontDir}/

	unzip -o -d ${fontDir} "/tmp/CascadiaCode.zip"

	rm -r /tmp/*.zip
	rm -r /tmp/*.ttf
	fc-cache -r
else
	mkdir -p ${WINDOWS_USER_FOLDER}/Documents/Fonts/Sarasa
	unzip -o -d ${WINDOWS_USER_FOLDER}/Documents/Fonts/Sarasa "/tmp/${sarasaFontFileName}"
	mkdir -p ${WINDOWS_USER_FOLDER}/Documents/Fonts/CascadiaCode
	unzip -o -d ${WINDOWS_USER_FOLDER}/Documents/Fonts/CascadiaCode "/tmp/CascadiaCode.zip"
	rm -f /tmp/*.zip

	font="$(getWindowsFonts)"
	if [[ $font == *"SarasaMonoSCNerdFont"* || $font == *"等距更纱黑体SCNerdFont"* ]]; then
		info "Sarasa Nerd Font already installed"
	else
		info "Installing Sarasa Nerd Font..."
		installFontForWindows "\$ENV:USERPROFILE/Documents/Fonts/Sarasa"
	fi

	if [[ $font == *"CaskaydiaCoveNF"* ]]; then
		info "Cascadia Code Nerd Font already installed"
	else
		info "Installing Cascadia Code Nerd Font..."
		installFontForWindows "\$ENV:USERPROFILE/Documents/Fonts/CascadiaCode"
	fi
fi

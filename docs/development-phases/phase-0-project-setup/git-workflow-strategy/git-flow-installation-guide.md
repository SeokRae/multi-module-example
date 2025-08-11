# Git Flow 설치 가이드

이 문서는 다양한 운영체제에서 git-flow 도구를 설치하는 방법을 설명합니다.

## 목차
1. [Git Flow 도구 종류](#git-flow-도구-종류)
2. [운영체제별 설치 방법](#운영체제별-설치-방법)
3. [설치 확인](#설치-확인)
4. [문제 해결](#문제-해결)
5. [IDE 통합](#ide-통합)

## Git Flow 도구 종류

### 1. git-flow (Original)
- 최초 Vincent Driessen이 개발
- 현재는 유지보수 중단
- 사용 권장하지 않음

### 2. git-flow-avh (AVH Edition) ⭐ **권장**
- Peter van der Does가 개발한 개선된 버전
- 활발한 유지보수
- 더 많은 기능과 안정성
- 현재 표준으로 사용

### 3. git-flow-completion
- bash/zsh 자동완성 지원
- git-flow-avh와 함께 설치 권장

## 운영체제별 설치 방법

### macOS

#### 1. Homebrew를 통한 설치 (권장)
```bash
# Homebrew 설치 확인
brew --version

# git-flow-avh 설치
brew install git-flow-avh

# 자동완성 기능 추가 설치 (선택사항)
brew install bash-completion
```

#### 2. MacPorts를 통한 설치
```bash
# MacPorts 설치 확인
port version

# git-flow 설치
sudo port install git-flow-devel
```

#### 3. 수동 설치
```bash
# 최신 버전 다운로드 및 설치
curl -OL https://raw.github.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh
chmod +x gitflow-installer.sh
sudo bash gitflow-installer.sh install stable
rm gitflow-installer.sh
```

### Linux

#### Ubuntu/Debian
```bash
# APT 저장소 업데이트
sudo apt update

# git-flow-avh 설치
sudo apt install git-flow

# 또는 최신 버전을 위한 PPA 추가
sudo add-apt-repository ppa:pdoes/gitflow-avh
sudo apt update
sudo apt install git-flow-avh

# bash 자동완성 설치
sudo apt install bash-completion
```

#### CentOS/RHEL/Fedora
```bash
# EPEL 저장소 활성화 (CentOS/RHEL)
sudo yum install epel-release
# 또는 Fedora
sudo dnf install epel-release

# git-flow 설치
sudo yum install gitflow
# 또는 Fedora
sudo dnf install gitflow
```

#### Arch Linux
```bash
# pacman을 통한 설치
sudo pacman -S gitflow-avh

# AUR을 통한 설치 (yay 사용)
yay -S gitflow-avh-git
```

#### openSUSE
```bash
# zypper를 통한 설치
sudo zypper install git-flow

# 또는 최신 버전
sudo zypper addrepo https://download.opensuse.org/repositories/devel:tools:scm/openSUSE_Tumbleweed/devel:tools:scm.repo
sudo zypper refresh
sudo zypper install git-flow-avh
```

### Windows

#### 1. Git for Windows (권장)
```bash
# Git for Windows 2.5.3 이상에 포함
# 설치 확인
git flow version

# 최신 Git for Windows 다운로드
# https://git-scm.com/download/win
```

#### 2. Chocolatey를 통한 설치
```powershell
# PowerShell 관리자 권한으로 실행
# Chocolatey 설치 확인
choco --version

# git-flow 설치
choco install gitflow-avh

# 또는
choco install git.install
```

#### 3. Scoop을 통한 설치
```powershell
# Scoop 설치 확인
scoop --version

# git-flow 설치
scoop install git-flow-avh
```

#### 4. WSL (Windows Subsystem for Linux)
```bash
# WSL에서 Ubuntu 방식과 동일
sudo apt update
sudo apt install git-flow
```

### 수동 설치 (모든 OS)

#### 스크립트를 통한 설치
```bash
# 설치 스크립트 다운로드 및 실행
wget -q -O - --no-check-certificate https://raw.github.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh install stable | bash

# 또는 curl 사용
curl -L -O https://raw.github.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh
chmod +x gitflow-installer.sh
sudo bash gitflow-installer.sh install stable
```

#### 소스에서 컴파일
```bash
# 의존성 설치 (Ubuntu 기준)
sudo apt install build-essential

# 소스 다운로드
git clone --recursive https://github.com/petervanderdoes/gitflow-avh.git
cd gitflow-avh

# 컴파일 및 설치
make
sudo make install

# 설치 경로 확인
make install PREFIX=/usr/local
```

## 설치 확인

### 기본 확인
```bash
# git-flow 버전 확인
git flow version

# 예상 출력: 1.12.3 (AVH Edition)

# git-flow 명령어 목록
git flow

# 도움말 확인
git flow help
```

### 상세 확인
```bash
# git-flow 설치 위치 확인
which git-flow
# 예상 출력: /usr/local/bin/git-flow

# Git 버전 확인 (2.0 이상 권장)
git --version

# PATH 환경변수에 git-flow 포함 확인
echo $PATH | grep -o '[^:]*bin[^:]*'
```

### 자동완성 확인
```bash
# bash 자동완성 테스트
git flow <TAB><TAB>
# 출력: feature, release, hotfix, support, version, help

# zsh 자동완성 설정 (필요시)
echo 'source /usr/local/share/zsh/site-functions/_git-flow' >> ~/.zshrc
source ~/.zshrc
```

## 문제 해결

### 일반적인 문제들

#### 1. "git: 'flow' is not a git command" 오류
```bash
# PATH 확인
echo $PATH

# git-flow 설치 위치 확인
find /usr -name "*git-flow*" 2>/dev/null

# 수동으로 PATH 추가 (임시)
export PATH=$PATH:/usr/local/bin

# 영구적으로 PATH 추가
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
source ~/.bashrc
```

#### 2. 권한 문제
```bash
# 설치 스크립트 권한 오류 시
chmod +x gitflow-installer.sh

# /usr/local/bin 쓰기 권한 문제 시
sudo mkdir -p /usr/local/bin
sudo chown $(whoami) /usr/local/bin
```

#### 3. 버전 충돌
```bash
# 기존 git-flow 제거 후 재설치
# macOS Homebrew
brew uninstall git-flow
brew install git-flow-avh

# Ubuntu
sudo apt remove git-flow
sudo apt install git-flow
```

#### 4. 자동완성 작동 안 함
```bash
# bash-completion 설치 확인
dpkg -l | grep bash-completion

# 자동완성 스크립트 위치 확인
find /usr -name "*git-flow*completion*" 2>/dev/null

# 수동으로 자동완성 활성화
source /usr/share/bash-completion/completions/git-flow
```

### 디버깅 명령어
```bash
# 상세 디버그 정보
git flow version -v

# Git 설정 확인
git config --list | grep flow

# 시스템 정보
uname -a
git --version
which git
```

## IDE 통합

### Visual Studio Code
```bash
# Git Flow 확장 설치
code --install-extension vector-of-bool.gitflow

# 또는 GUI에서 설치:
# Extensions > "Git Flow" 검색 > 설치
```

### IntelliJ IDEA / WebStorm
```
1. Settings/Preferences > Version Control > Git
2. "Use credential helper" 체크
3. GitFlow 플러그인 설치:
   - File > Settings > Plugins
   - "GitFlow" 검색 > 설치 > 재시작
```

### Eclipse
```
1. Help > Eclipse Marketplace
2. "EGit" 검색 > 설치
3. Git Flow 지원 포함
```

### Sublime Text
```bash
# Package Control을 통한 Git Flow 플러그인 설치
# Ctrl+Shift+P > "Package Control: Install Package"
# "Git Flow" 검색 > 설치
```

## 설치 스크립트 예제

### 자동화된 설치 스크립트 (install-gitflow.sh)
```bash
#!/bin/bash

echo "Git Flow 설치 스크립트"
echo "======================"

# OS 감지
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    if command -v brew &> /dev/null; then
        echo "Homebrew를 통한 git-flow-avh 설치..."
        brew install git-flow-avh
        brew install bash-completion
    else
        echo "Homebrew가 설치되지 않았습니다. 수동 설치를 진행합니다..."
        curl -L -O https://raw.github.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh
        chmod +x gitflow-installer.sh
        sudo bash gitflow-installer.sh install stable
        rm gitflow-installer.sh
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if command -v apt &> /dev/null; then
        # Ubuntu/Debian
        echo "APT를 통한 git-flow 설치..."
        sudo apt update
        sudo apt install -y git-flow bash-completion
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        echo "YUM을 통한 git-flow 설치..."
        sudo yum install -y epel-release
        sudo yum install -y gitflow bash-completion
    elif command -v dnf &> /dev/null; then
        # Fedora
        echo "DNF를 통한 git-flow 설치..."
        sudo dnf install -y gitflow bash-completion
    else
        echo "패키지 매니저를 찾을 수 없습니다. 수동 설치를 진행합니다..."
        wget -q -O - --no-check-certificate https://raw.github.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh install stable | bash
    fi
else
    echo "지원되지 않는 운영체제입니다."
    exit 1
fi

# 설치 확인
echo ""
echo "설치 확인 중..."
if command -v git-flow &> /dev/null; then
    echo "✅ git-flow 설치 성공!"
    echo "버전: $(git flow version)"
else
    echo "❌ git-flow 설치 실패"
    exit 1
fi

echo ""
echo "설치 완료! 다음 명령어로 Git Flow를 시작하세요:"
echo "git flow init"
```

### 사용법
```bash
# 스크립트 다운로드 및 실행
curl -L -O https://raw.githubusercontent.com/your-repo/install-gitflow.sh
chmod +x install-gitflow.sh
./install-gitflow.sh
```

이 가이드를 따라하면 어떤 운영체제에서든 git-flow 도구를 성공적으로 설치할 수 있습니다.
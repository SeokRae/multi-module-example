# Git Flow 도구 사용 가이드

이 문서는 git-flow 도구를 사용하여 Git Flow 워크플로우를 구현하는 방법을 설명합니다.

## 목차
1. [Git Flow 도구 설치](#git-flow-도구-설치)
2. [초기 설정](#초기-설정)
3. [기능 개발 워크플로우](#기능-개발-워크플로우)
4. [릴리스 워크플로우](#릴리스-워크플로우)
5. [핫픽스 워크플로우](#핫픽스-워크플로우)
6. [고급 설정](#고급-설정)

## Git Flow 도구 설치

### macOS
```bash
# Homebrew를 통한 설치 (AVH Edition 권장)
brew install git-flow-avh

# 설치 확인
git flow version
```

### Ubuntu/Debian
```bash
# apt를 통한 설치
sudo apt-get install git-flow

# 또는 AVH Edition 설치
sudo apt-get install git-flow-avh
```

### Windows
```bash
# Git for Windows에 포함되어 있음
# 또는 Chocolatey를 통한 설치
choco install gitflow-avh
```

### 수동 설치
```bash
# GitHub에서 직접 설치
wget -q -O - --no-check-certificate https://raw.github.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh install stable | bash
```

## 초기 설정

### 1. 저장소 초기화
```bash
# 기존 저장소에서 Git Flow 초기화
cd <repository-name>
git flow init

# 기본 브랜치 설정 (대화형)
# - Production releases: main (또는 master)
# - Next release: develop
# - Feature branches: feature/
# - Release branches: release/
# - Hotfix branches: hotfix/
# - Support branches: support/
# - Version tag prefix: v (선택사항)
```

### 2. 자동 초기화 (기본값 사용)
```bash
# 기본 설정으로 자동 초기화
git flow init -d
```

### 3. 초기화 확인
```bash
# 브랜치 구조 확인
git branch -a

# Git Flow 설정 확인
git config --list | grep gitflow
```

## 기능 개발 워크플로우

### 1. Feature 브랜치 생성 및 시작
```bash
# feature 브랜치 생성 (develop에서 자동 분기)
git flow feature start 기능명

# 예시
git flow feature start user-authentication
```

### 2. 기능 개발
```bash
# 현재 feature/user-authentication 브랜치에서 작업
# 코드 작성 후 커밋
git add .
git commit -m "feat: implement user authentication logic"

# 중간 푸시 (원격 저장소에 백업)
git flow feature publish user-authentication
```

### 3. 기능 완료
```bash
# feature 브랜치를 develop에 병합하고 삭제
git flow feature finish user-authentication

# 완료 후 자동으로 develop 브랜치로 전환됨
# feature 브랜치는 자동 삭제됨
```

### 4. 원격 저장소 동기화
```bash
# develop 브랜치 푸시
git push origin develop

# 원격 feature 브랜치가 있다면 삭제
git push origin --delete feature/user-authentication
```

## 릴리스 워크플로우

### 1. Release 브랜치 생성
```bash
# develop에서 release 브랜치 생성
git flow release start v1.0.0

# 버전 번호는 태그 prefix 설정에 따라 자동 적용
```

### 2. 릴리스 준비
```bash
# 현재 release/v1.0.0 브랜치에서 작업
# 버전 업데이트, 문서 수정, 마지막 버그 수정
git add .
git commit -m "chore: prepare release v1.0.0"

# 릴리스 브랜치 공유 (선택사항)
git flow release publish v1.0.0
```

### 3. 릴리스 완료
```bash
# release 브랜치를 main과 develop에 병합, 태그 생성, 브랜치 삭제
git flow release finish v1.0.0

# 릴리스 메시지 입력 (에디터가 열림)
# 태그 메시지 입력 (에디터가 열림)
```

### 4. 원격 저장소 동기화
```bash
# 모든 변경사항 푸시
git push origin main
git push origin develop
git push origin --tags

# 원격 release 브랜치 삭제 (있다면)
git push origin --delete release/v1.0.0
```

## 핫픽스 워크플로우

### 1. Hotfix 브랜치 생성
```bash
# main에서 hotfix 브랜치 생성
git flow hotfix start v1.0.1

# 현재 main의 최신 커밋에서 분기됨
```

### 2. 긴급 수정
```bash
# 현재 hotfix/v1.0.1 브랜치에서 작업
# 버그 수정
git add .
git commit -m "fix: resolve critical security vulnerability"

# 핫픽스 브랜치 공유 (선택사항)
git flow hotfix publish v1.0.1
```

### 3. 핫픽스 완료
```bash
# hotfix 브랜치를 main과 develop에 병합, 태그 생성, 브랜치 삭제
git flow hotfix finish v1.0.1

# 핫픽스 메시지 입력 (에디터가 열림)
# 태그 메시지 입력 (에디터가 열림)
```

### 4. 원격 저장소 동기화
```bash
# 모든 변경사항 푸시
git push origin main
git push origin develop
git push origin --tags

# 원격 hotfix 브랜치 삭제 (있다면)
git push origin --delete hotfix/v1.0.1
```

## 고급 설정

### 1. 사용자 정의 브랜치 접두사
```bash
# 초기화 시 사용자 정의 접두사 설정
git flow init
# Feature branches? [feature/] custom-feature/
# Release branches? [release/] rel/
# Hotfix branches? [hotfix/] fix/
```

### 2. Hook 스크립트 사용
```bash
# .git/hooks/ 디렉토리에 hook 스크립트 배치
# pre-flow-feature-start, post-flow-feature-start 등
```

### 3. 설정 확인 및 수정
```bash
# 현재 Git Flow 설정 확인
git config --get-regexp gitflow

# 설정 수정
git config gitflow.branch.master main
git config gitflow.branch.develop develop
git config gitflow.prefix.feature feature/
git config gitflow.prefix.release release/
git config gitflow.prefix.hotfix hotfix/
git config gitflow.prefix.support support/
git config gitflow.prefix.versiontag v
```

## 유용한 명령어

### 1. 상태 확인
```bash
# 현재 Git Flow 상태 확인
git flow feature list
git flow release list
git flow hotfix list

# 진행 중인 모든 브랜치 확인
git flow feature
git flow release
git flow hotfix
```

### 2. 브랜치 추적
```bash
# 원격 feature 브랜치 추적
git flow feature track user-authentication

# 원격에서 feature 브랜치 가져오기
git flow feature pull origin user-authentication
```

### 3. 브랜치 삭제 (수동)
```bash
# feature 브랜치 강제 삭제
git flow feature delete user-authentication

# 원격 브랜치도 함께 삭제
git push origin --delete feature/user-authentication
```

## 베스트 프랙티스

### 1. 팀 워크플로우
```bash
# 1. feature 시작 전 develop 동기화
git checkout develop
git pull origin develop
git flow feature start new-feature

# 2. 정기적인 백업
git flow feature publish new-feature

# 3. 완료 전 develop 동기화
git checkout develop
git pull origin develop
git checkout feature/new-feature
git merge develop  # 충돌 해결
git flow feature finish new-feature
```

### 2. CI/CD 통합
```bash
# .github/workflows/gitflow.yml 또는 .gitlab-ci.yml에서
# feature/, release/, hotfix/ 브랜치별 다른 파이프라인 실행
```

### 3. 자동화 스크립트
```bash
#!/bin/bash
# scripts/start-feature.sh
feature_name=$1
git checkout develop
git pull origin develop
git flow feature start $feature_name
git flow feature publish $feature_name
echo "Feature $feature_name started and published!"
```

## 문제 해결

### 1. 초기화 문제
```bash
# 이미 초기화된 저장소 재설정
git flow init -f
```

### 2. 브랜치 충돌
```bash
# finish 실행 시 충돌 발생하면
git status
# 충돌 해결 후
git add .
git commit
# 다시 finish 실행
git flow feature finish feature-name
```

### 3. 원격 브랜치 정리
```bash
# 삭제된 원격 브랜치 정리
git remote prune origin

# 로컬에서 삭제된 원격 브랜치 참조 제거
git fetch --prune
```

이 가이드를 따르면 git-flow 도구를 사용하여 효율적이고 일관된 Git Flow 워크플로우를 구현할 수 있습니다.
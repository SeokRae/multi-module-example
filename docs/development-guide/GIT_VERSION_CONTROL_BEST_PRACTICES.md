# Git 형상관리 베스트 프랙티스 가이드

## 📋 개요

이 문서는 프로젝트 초기 설계 단계에서 Git 형상관리를 설정할 때 AI 어시스턴트와 개발자가 따라야 할 지침입니다. 
깔끔하고 안전하며 협업하기 좋은 저장소를 만들기 위한 체계적인 가이드를 제공합니다.

## 🎯 핵심 원칙

### 1. **팀 공유 우선 (Team-First Approach)**
- 개인 설정보다 팀 공유 가능성을 우선 고려
- 프로젝트 재현성(Reproducibility) 보장
- 크로스 플랫폼 호환성 유지

### 2. **보안 우선 (Security-First)**
- 민감 정보 절대 커밋 금지
- 환경별 설정 분리
- 시크릿 관리 체계 구축

### 3. **최소 권한 원칙 (Least Privilege)**
- 필요한 파일만 포함
- 자동 생성 파일 제외
- 불필요한 메타데이터 제거

## ✅ 형상관리 포함 대상 (Must Include)

### 🔧 **소스 코드 및 설정**

#### 필수 포함 파일
```
# 소스 코드
src/
test/
*.java, *.kt, *.js, *.ts, *.py, *.go, *.rs
*Test.java, *Spec.ts, *.test.js

# 빌드 설정
build.gradle, build.gradle.kts
pom.xml
package.json, package-lock.json
requirements.txt, Pipfile
go.mod, go.sum
Cargo.toml, Cargo.lock

# 프로젝트 설정
settings.gradle
gradle.properties (민감정보 제외)
.editorconfig
.gitignore
.gitattributes

# 애플리케이션 설정 (템플릿)
application.yml
application-{profile}.yml.template
config/
```

#### 인프라스트럭처 코드
```
# 컨테이너화
Dockerfile
docker-compose.yml
docker-compose.override.yml.template

# 인프라 코드
terraform/
kubernetes/
helm/
ansible/

# CI/CD
.github/workflows/
.gitlab-ci.yml
Jenkinsfile
azure-pipelines.yml
```

#### 문서화
```
# 프로젝트 문서
README.md
CHANGELOG.md
CONTRIBUTING.md
LICENSE

# 개발 가이드
docs/
api/
architecture/
```

### 👥 **팀 공유 설정 (선택적)**

#### IDE 설정 (팀 합의 시)
```
# VS Code (팀 표준 설정)
.vscode/settings.json        # 코드 포맷팅, 린터 설정
.vscode/extensions.json      # 권장 확장 프로그램
.vscode/tasks.json          # 공통 작업 정의
.vscode/launch.json         # 디버깅 설정

# IntelliJ IDEA (매우 선택적)
.idea/codeStyles/           # 코드 스타일만
.idea/inspectionProfiles/   # 코드 검사 규칙만
```

#### 품질 도구 설정
```
# 코드 품질
.eslintrc.js, .eslintignore
.prettierrc, .prettierignore
checkstyle.xml
spotbugs-exclude.xml
sonar-project.properties

# 테스트 설정
jest.config.js
karma.conf.js
pytest.ini
```

## ❌ 형상관리 제외 대상 (Must Exclude)

### 🚫 **개인 개발환경**

#### IDE 개인 설정
```gitignore
# IntelliJ IDEA
.idea/
!.idea/codeStyles/
!.idea/inspectionProfiles/
*.iml
*.iws
*.ipr
out/
.idea_modules/

# VS Code
.vscode/
!.vscode/settings.json
!.vscode/tasks.json  
!.vscode/launch.json
!.vscode/extensions.json
*.code-workspace

# Eclipse
.project
.classpath
.settings/
.metadata/

# Sublime Text
*.sublime-project
*.sublime-workspace

# Vim
*.swp
*.swo
*~

# Emacs
*~
\#*\#
/.emacs.desktop
/.emacs.desktop.lock
```

#### 에디터 임시파일
```gitignore
# 임시 파일
*.tmp
*.temp
*.bak
*.backup
*~
.#*

# 로그 파일
*.log
logs/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
```

### 🔨 **빌드 결과물**

#### 컴파일 결과물
```gitignore
# Java
target/
build/
*.jar
*.war
*.ear
*.class

# Node.js
node_modules/
npm-debug.log
dist/
.npm

# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/

# Go
/vendor/
*.exe
*.exe~
*.dll
*.so
*.dylib

# Rust
target/
Cargo.lock (라이브러리인 경우)

# .NET
bin/
obj/
*.dll
*.exe
*.pdb
```

#### 빌드 캐시
```gitignore
# Gradle
.gradle/
gradle-app.setting
!gradle-wrapper.jar

# Maven
.m2/repository/

# npm/yarn
.npm
.yarn/cache
.yarn/unplugged
.yarn/build-state.yml
.yarn/install-state.gz

# 기타
.cache/
```

### 🔒 **민감 정보 및 환경 파일**

#### 환경 변수 및 시크릿
```gitignore
# 환경 설정
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# 인증 정보
*.pem
*.key
*.p12
*.jks
*.keystore
secrets.yml
credentials.json
service-account.json

# 설정 파일 (민감정보 포함)
application-local.yml
application-dev.yml (실제 DB 정보 포함시)
database.yml
```

#### 클라우드 및 배포 설정
```gitignore
# AWS
.aws/
*.pem

# Google Cloud
*.json (service account)
.gcloud/

# Azure
.azure/

# Docker
.docker/
docker-compose.override.yml (민감정보 포함시)
```

### 💾 **OS 및 시스템 파일**

#### 운영체제별 파일
```gitignore
# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon?
.Spotlight-V100
.Trashes

# Windows
Thumbs.db
ehthumbs.db
Desktop.ini
$RECYCLE.BIN/

# Linux
*~
.directory
.Trash-*
```

#### 시스템 도구
```gitignore
# Git
.git/
*.patch

# SVN
.svn/

# Mercurial
.hg/
```

## 🎯 AI 어시스턴트용 체크리스트

AI가 파일을 생성하거나 프로젝트를 설정할 때 다음 체크리스트를 따르세요:

### ✅ 파일 포함 결정 프로세스

1. **팀 공유 필요성 확인**
   ```
   Q: 이 파일이 없으면 다른 개발자가 프로젝트를 실행할 수 없는가?
   A: Yes → 포함 필요
   A: No → 다음 질문으로
   ```

2. **재현성 확인**
   ```
   Q: 이 파일이 빌드 과정이나 실행에 필수적인가?
   A: Yes → 포함 필요
   A: No → 다음 질문으로
   ```

3. **보안 위험 확인**
   ```
   Q: 이 파일에 민감한 정보(패스워드, API 키, 토큰)가 포함되어 있는가?
   A: Yes → 절대 포함 금지
   A: No → 다음 질문으로
   ```

4. **자동 생성 여부 확인**
   ```
   Q: 이 파일이 빌드나 실행 과정에서 자동으로 생성되는가?
   A: Yes → 포함 불필요
   A: No → 포함 고려
   ```

5. **개인 설정 여부 확인**
   ```
   Q: 이 파일이 개발자마다 다를 수 있는 개인 설정인가?
   A: Yes → 포함 불필요
   A: No → 포함 고려
   ```

### 📝 .gitignore 생성 가이드

#### 1. 프로젝트 타입별 템플릿 적용
```bash
# GitHub의 gitignore 템플릿 활용
# Java 프로젝트
curl -s https://raw.githubusercontent.com/github/gitignore/main/Java.gitignore > .gitignore

# Node.js 프로젝트  
curl -s https://raw.githubusercontent.com/github/gitignore/main/Node.gitignore > .gitignore

# Python 프로젝트
curl -s https://raw.githubusercontent.com/github/gitignore/main/Python.gitignore > .gitignore
```

#### 2. 프로젝트별 커스터마이징
```gitignore
# 기본 템플릿에 추가할 내용

# 프로젝트 특화 제외 파일
# 예: Spring Boot 프로젝트
application-local.yml
application-dev.yml

# AI 개발 관련
.claude/settings.local.json
mcp-servers/
*.ipynb_checkpoints/

# 문서 초안 (필요시)
drafts/
TODO.md
NOTES.md
```

#### 3. 보안 강화 패턴
```gitignore
# 민감정보 패턴
*secret*
*password*
*credential*
*token*
*.pem
*.key
*.p12

# 환경별 설정
.env*
!.env.example
!.env.template

# 클라우드 설정
.aws/
.gcloud/
.azure/
```

## 🏗️ 프로젝트 초기 설정 워크플로우

### 1. **저장소 초기화**
```bash
# 1. Git 저장소 초기화
git init

# 2. .gitignore 생성 (프로젝트 타입에 맞게)
# GitHub 템플릿 사용 또는 직접 작성

# 3. 초기 커밋
git add .gitignore
git commit -m "Initial commit: Add .gitignore"
```

### 2. **프로젝트 구조 설정**
```bash
# 4. 프로젝트 기본 구조 생성
mkdir -p src/main/java src/test/java
mkdir -p docs/{api,architecture,development-guide}

# 5. 기본 파일 생성
touch README.md
touch CHANGELOG.md
touch .editorconfig

# 6. 구조 커밋
git add .
git commit -m "feat: Initialize project structure"
```

### 3. **빌드 시스템 설정**
```bash
# 7. 빌드 설정 파일 추가
# build.gradle, pom.xml, package.json 등

# 8. CI/CD 워크플로우 추가
mkdir -p .github/workflows

# 9. 빌드 시스템 커밋
git add .
git commit -m "feat: Add build system and CI/CD configuration"
```

### 4. **개발 환경 설정 (선택적)**
```bash
# 10. 팀 공유 IDE 설정 (합의된 경우만)
mkdir -p .vscode
# settings.json, extensions.json 추가

# 11. 코드 품질 도구 설정
# .eslintrc.js, .prettierrc 등 추가

# 12. 개발 환경 커밋
git add .
git commit -m "feat: Add team development environment configuration"
```

## ⚠️ 주의사항 및 예외 상황

### 🔄 **레거시 프로젝트 정리**
```bash
# 이미 커밋된 민감 정보 제거
git filter-branch --force --index-filter \
'git rm --cached --ignore-unmatch path/to/sensitive/file' \
--prune-empty --tag-name-filter cat -- --all

# 또는 BFG Repo-Cleaner 사용
bfg --delete-files "*.key" --delete-files "secrets.yml"
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

### 📦 **대용량 파일 처리**
```bash
# Git LFS 설정
git lfs track "*.jar"
git lfs track "*.zip" 
git lfs track "*.pdf"
git add .gitattributes
```

### 🔧 **환경별 설정 관리**
```yaml
# application.yml (포함)
spring:
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:local}

---
# application-local.yml.template (포함)
spring:
  datasource:
    url: jdbc:h2:mem:testdb
    username: sa
    password: 
    
---
# application-prod.yml.template (포함)  
spring:
  datasource:
    url: ${DATABASE_URL}
    username: ${DATABASE_USERNAME}
    password: ${DATABASE_PASSWORD}
```

## 📚 참고 자료

### 🔗 **도구 및 리소스**
- [GitHub gitignore 템플릿](https://github.com/github/gitignore)
- [gitignore.io](https://www.toptal.com/developers/gitignore)
- [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/)
- [Git LFS](https://git-lfs.github.io/)

### 📖 **추가 가이드**
- [Git 브랜치 전략](./GIT_BRANCH_STRATEGY.md)
- [커밋 메시지 컨벤션](./COMMIT_MESSAGE_CONVENTION.md)
- [코드 리뷰 가이드](./CODE_REVIEW_GUIDE.md)

---

## 📝 체크리스트 요약

### ✅ AI가 프로젝트 생성 시 확인할 항목

- [ ] 프로젝트 타입에 맞는 .gitignore 생성
- [ ] 민감정보 제외 패턴 적용
- [ ] 빌드 결과물 제외 설정
- [ ] 개인 IDE 설정 제외
- [ ] 팀 공유 설정만 포함
- [ ] 환경별 설정 템플릿 제공
- [ ] 필수 문서 파일 생성
- [ ] CI/CD 워크플로우 설정
- [ ] 보안 검사 패턴 적용

### ⚡ 빠른 시작 명령어
```bash
# 새 프로젝트 시작
git init
curl -s https://raw.githubusercontent.com/github/gitignore/main/Java.gitignore > .gitignore
echo "# 프로젝트명" > README.md
git add .
git commit -m "Initial commit: Project setup"
```

**문서 버전**: v1.0  
**최종 업데이트**: 2025-01-12  
**작성자**: Claude Code Development Assistant
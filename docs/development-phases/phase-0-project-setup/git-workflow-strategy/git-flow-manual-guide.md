# Git Flow 수동 방식 가이드

이 문서는 Git Flow 워크플로우를 표준 Git 명령어만으로 구현하는 방법을 설명합니다.

## 목차
1. [브랜치 구조](#브랜치-구조)
2. [초기 설정](#초기-설정)
3. [기능 개발 워크플로우](#기능-개발-워크플로우)
4. [릴리스 워크플로우](#릴리스-워크플로우)
5. [핫픽스 워크플로우](#핫픽스-워크플로우)
6. [주의사항](#주의사항)

## 브랜치 구조

### 메인 브랜치
- **main/master**: 프로덕션 배포용 브랜치 (항상 배포 가능한 상태)
- **develop**: 개발 통합 브랜치 (다음 릴리스 준비용)

### 보조 브랜치
- **feature/***: 기능 개발 브랜치
- **release/***: 릴리스 준비 브랜치
- **hotfix/***: 긴급 수정 브랜치

## 초기 설정

### 1. 저장소 초기화
```bash
# 새 저장소 생성 또는 기존 저장소 클론
git clone <repository-url>
cd <repository-name>

# develop 브랜치 생성 (main에서 분기)
git checkout main
git pull origin main
git checkout -b develop
git push -u origin develop
```

### 2. 브랜치 상태 확인
```bash
git branch -a
```

## 기능 개발 워크플로우

### 1. Feature 브랜치 생성
```bash
# develop 브랜치로 전환하고 최신 상태로 업데이트
git checkout develop
git pull origin develop

# feature 브랜치 생성
git checkout -b feature/기능명
```

### 2. 기능 개발
```bash
# 코드 작성 후 커밋
git add .
git commit -m "feat: 기능 구현"

# 필요시 중간 푸시
git push -u origin feature/기능명
```

### 3. 기능 완료 후 병합
```bash
# develop 브랜치로 전환하고 최신 상태 확인
git checkout develop
git pull origin develop

# feature 브랜치 병합 (--no-ff로 merge commit 생성)
git merge --no-ff feature/기능명

# develop 브랜치 푸시
git push origin develop

# feature 브랜치 삭제
git branch -d feature/기능명
git push origin --delete feature/기능명
```

### 4. Pull Request 방식 (권장)
```bash
# feature 브랜치 푸시 후
git push -u origin feature/기능명

# GitHub/GitLab에서 Pull Request 생성
# 코드 리뷰 후 develop에 병합
# 병합 후 feature 브랜치 삭제
```

## 릴리스 워크플로우

### 1. Release 브랜치 생성
```bash
# develop에서 release 브랜치 생성
git checkout develop
git pull origin develop
git checkout -b release/v1.0.0
```

### 2. 릴리스 준비
```bash
# 버전 번호 업데이트, 문서 수정, 버그 수정 등
git add .
git commit -m "chore: bump version to 1.0.0"

# 릴리스 브랜치 푸시
git push -u origin release/v1.0.0
```

### 3. 릴리스 완료
```bash
# main 브랜치에 병합
git checkout main
git pull origin main
git merge --no-ff release/v1.0.0
git push origin main

# 릴리스 태그 생성
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# develop 브랜치에도 병합 (릴리스 변경사항 반영)
git checkout develop
git pull origin develop
git merge --no-ff release/v1.0.0
git push origin develop

# release 브랜치 삭제
git branch -d release/v1.0.0
git push origin --delete release/v1.0.0
```

## 핫픽스 워크플로우

### 1. Hotfix 브랜치 생성
```bash
# main에서 hotfix 브랜치 생성
git checkout main
git pull origin main
git checkout -b hotfix/v1.0.1
```

### 2. 긴급 수정
```bash
# 버그 수정
git add .
git commit -m "fix: critical bug in production"

# hotfix 브랜치 푸시
git push -u origin hotfix/v1.0.1
```

### 3. 핫픽스 완료
```bash
# main 브랜치에 병합
git checkout main
git pull origin main
git merge --no-ff hotfix/v1.0.1
git push origin main

# 핫픽스 태그 생성
git tag -a v1.0.1 -m "Hotfix version 1.0.1"
git push origin v1.0.1

# develop 브랜치에도 병합
git checkout develop
git pull origin develop
git merge --no-ff hotfix/v1.0.1
git push origin develop

# hotfix 브랜치 삭제
git branch -d hotfix/v1.0.1
git push origin --delete hotfix/v1.0.1
```

## 주의사항

### 1. 브랜치 명명 규칙
- Feature: `feature/기능명` (예: `feature/user-authentication`)
- Release: `release/버전` (예: `release/v1.0.0`)
- Hotfix: `hotfix/버전` (예: `hotfix/v1.0.1`)

### 2. 커밋 메시지 규칙
```
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅
refactor: 코드 리팩토링
test: 테스트 추가
chore: 빌드 작업, 패키지 매니저 설정
```

### 3. 병합 시 주의점
- **항상 `--no-ff` 옵션 사용**: merge commit을 생성하여 브랜치 히스토리 보존
- **브랜치 삭제 전 확인**: 병합이 완료되었는지 확인 후 삭제
- **충돌 해결**: 병합 시 충돌 발생하면 신중하게 해결

### 4. 베스트 프랙티스
- Pull Request/Merge Request를 통한 코드 리뷰
- CI/CD 파이프라인과 연동
- 정기적인 develop 브랜치 동기화
- 명확한 커밋 메시지 작성

## 예시 시나리오

### 완전한 기능 개발 예시
```bash
# 1. 기능 개발 시작
git checkout develop
git pull origin develop
git checkout -b feature/payment-integration

# 2. 개발 및 커밋
git add .
git commit -m "feat: add payment gateway integration"
git push -u origin feature/payment-integration

# 3. Pull Request 생성 및 병합 (웹 UI)
# 또는 직접 병합
git checkout develop
git pull origin develop
git merge --no-ff feature/payment-integration
git push origin develop
git branch -d feature/payment-integration
```

이 가이드를 따르면 Git Flow 도구 없이도 표준 Git 명령어만으로 완전한 Git Flow 워크플로우를 구현할 수 있습니다.
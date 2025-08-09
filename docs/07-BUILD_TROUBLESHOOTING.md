# 빌드 문제 해결 가이드

## 1. 개요

이 문서는 멀티모듈 Gradle 프로젝트에서 발생할 수 있는 빌드 문제들과 해결 방법을 정리합니다.

## 2. 발생했던 주요 문제들과 해결 과정

### 2.1 문제 1: Spring Boot 메인 클래스 없음

**에러 메시지:**
```
FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':application:bootJar'.
> Error while evaluating property 'mainClass' of task ':application:bootJar'.
   > Failed to calculate the value of task ':application:bootJar' property 'mainClass'.
      > Main class name has not been configured and it could not be resolved from classpath
```

**원인:**
- 모든 서브프로젝트에 Spring Boot 플러그인이 적용되어 있었음
- 실제 실행 가능한 애플리케이션이 아닌 컨테이너 모듈들(common, domain, infrastructure, application)에도 bootJar 태스크가 실행됨

**해결 과정:**

1. **초기 접근 (실패):**
```gradle
// 모든 서브프로젝트에 Spring Boot 플러그인 적용 (문제 코드)
subprojects {
    apply plugin: 'org.springframework.boot'
    apply plugin: 'io.spring.dependency-management'
}
```

2. **조건부 적용 시도 (부분적 성공):**
```gradle
// 실행 가능한 애플리케이션에만 Spring Boot 플러그인 적용
project.subprojects.findAll { 
    !it.name.contains('api') && !it.name.contains('app')
}.each { subproject ->
    subproject.tasks.named('bootJar') { enabled = false }
    subproject.tasks.named('jar') { enabled = true }
}
```

3. **최종 해결:**
```gradle
// Spring Boot 플러그인을 실행 가능한 애플리케이션에만 적용
configure(subprojects.findAll { it.name == 'user-api' || it.name == 'batch-app' }) {
    apply plugin: 'org.springframework.boot'
}

// 컨테이너 모듈들은 빌드 제외
configure(subprojects.findAll { 
    it.name == 'common' || it.name == 'domain' || 
    it.name == 'infrastructure' || it.name == 'application' 
}) {
    tasks.named('jar') { enabled = false }
}
```

### 2.2 문제 2: Spring Boot 의존성 버전 해결 실패

**에러 메시지:**
```
> Could not resolve all files for configuration ':common:common-core:compileClasspath'.
   > Could not find org.projectlombok:lombok:.
   > Could not find org.springframework.boot:spring-boot-starter:.
```

**원인:**
- Spring Boot BOM(Bill of Materials)이 적용되지 않아 의존성 버전을 찾을 수 없음
- 의존성 관리 플러그인이 올바르게 구성되지 않음

**해결 과정:**

1. **문제 상황:**
```gradle
// 의존성 관리 없이 의존성만 선언 (문제 코드)
dependencies {
    compileOnly 'org.projectlombok:lombok'  // 버전 정보 없음
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}
```

2. **해결책:**
```gradle
subprojects {
    apply plugin: 'java'
    apply plugin: 'io.spring.dependency-management'  // 모든 모듈에 적용
    
    dependencyManagement {
        imports {
            mavenBom 'org.springframework.boot:spring-boot-dependencies:3.2.2'
        }
    }
    
    dependencies {
        compileOnly 'org.projectlombok:lombok'  // BOM에서 버전 자동 해결
        annotationProcessor 'org.projectlombok:lombok'
        testImplementation 'org.springframework.boot:spring-boot-starter-test'
    }
}
```

### 2.3 문제 3: 모듈간 의존성 해결

**문제:**
- 각 모듈이 서로를 참조할 때 올바른 의존성 설정이 필요
- 컴파일 시점에 다른 모듈의 클래스를 찾을 수 없는 문제

**해결:**
```gradle
// application/user-api/build.gradle
dependencies {
    implementation project(':common:common-web')      // 웹 공통 기능
    implementation project(':domain:user-domain')     // 사용자 도메인
    implementation project(':infrastructure:data-access')  // 데이터 접근
    
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    // ... 기타 의존성
}
```

## 3. 일반적인 빌드 문제 해결법

### 3.1 Gradle 캐시 문제

**증상:**
- 의존성이 올바르게 설정되어 있는데 빌드 실패
- 이전에 성공했던 빌드가 갑자기 실패

**해결법:**
```bash
# Gradle 캐시 완전 정리
./gradlew clean --refresh-dependencies

# Gradle 데몬 재시작
./gradlew --stop
./gradlew clean build

# Gradle 캐시 디렉토리 수동 삭제 (극단적인 경우)
rm -rf ~/.gradle/caches/
rm -rf ~/.gradle/wrapper/
```

### 3.2 의존성 충돌 문제

**문제 진단:**
```bash
# 의존성 트리 확인
./gradlew :application:user-api:dependencies

# 특정 라이브러리 의존성 추적
./gradlew :application:user-api:dependencyInsight --dependency spring-boot-starter-web

# 의존성 충돌 리포트
./gradlew :application:user-api:dependencyInsight --dependency slf4j-api
```

**해결법:**
```gradle
dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    
    // 특정 버전 강제 지정
    implementation 'org.slf4j:slf4j-api:2.0.11'
    
    // 의존성 제외
    implementation('some-library') {
        exclude group: 'org.slf4j', module: 'slf4j-log4j12'
    }
}
```

### 3.3 Java 버전 호환성 문제

**증상:**
```
> Compilation failed; see the compiler error output for details.
> error: invalid source release: 17
```

**해결법:**
```gradle
// 프로젝트 Java 버전 명시
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(17)
    }
}

// 또는 컴파일러 설정
tasks.withType(JavaCompile) {
    options.release = 17
}
```

### 3.4 모듈 경로 문제

**증상:**
- 모듈을 찾을 수 없다는 에러
- settings.gradle 설정 오류

**해결법:**
```gradle
// settings.gradle에서 모듈 경로 확인
include 'common:common-core'
include 'common:common-web'
include 'domain:user-domain'
include 'application:user-api'

// 모듈 디렉토리 구조 확인
project(':common:common-core').projectDir = file('common/common-core')
```

## 4. 디버깅 도구 및 명령어

### 4.1 빌드 정보 확인

```bash
# Gradle 버전 확인
./gradlew --version

# 프로젝트 구조 확인
./gradlew projects

# 태스크 목록 확인
./gradlew tasks

# 특정 모듈의 태스크 확인
./gradlew :application:user-api:tasks
```

### 4.2 상세 빌드 로그

```bash
# 상세 로그로 빌드
./gradlew build --info

# 디버그 로그로 빌드
./gradlew build --debug

# 스택 트레이스 포함
./gradlew build --stacktrace

# 빌드 스캔 사용 (권장)
./gradlew build --scan
```

### 4.3 성능 분석

```bash
# 빌드 성능 프로파일
./gradlew build --profile

# 빌드 캐시 정보
./gradlew build --build-cache --info

# 병렬 빌드 활성화
./gradlew build --parallel
```

## 5. 프로젝트별 설정 최적화

### 5.1 gradle.properties 최적화

```properties
# gradle.properties
# JVM 메모리 설정
org.gradle.jvmargs=-Xmx2g -XX:MaxMetaspaceSize=512m

# 빌드 성능 최적화
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.daemon=true
org.gradle.configureondemand=true

# Kotlin DSL 사용 시
kotlin.code.style=official
```

### 5.2 빌드 스크립트 최적화

```gradle
// 공통 의존성을 subprojects에서 한번에 관리
subprojects {
    // 공통 리포지토리
    repositories {
        mavenCentral()
        gradlePluginPortal()
    }
    
    // 공통 플러그인
    apply plugin: 'java'
    apply plugin: 'io.spring.dependency-management'
    
    // 공통 의존성
    dependencies {
        compileOnly 'org.projectlombok:lombok'
        annotationProcessor 'org.projectlombok:lombok'
        testImplementation 'org.springframework.boot:spring-boot-starter-test'
    }
}
```

## 6. CI/CD 환경에서의 빌드 문제

### 6.1 GitHub Actions에서 자주 발생하는 문제

```yaml
# .github/workflows/ci.yml
- name: Cache Gradle packages
  uses: actions/cache@v3
  with:
    path: |
      ~/.gradle/caches
      ~/.gradle/wrapper
    key: ${{ runner.os }}-gradle-${{ hashFiles('**/*.gradle*') }}
    restore-keys: |
      ${{ runner.os }}-gradle-

- name: Grant execute permission
  run: chmod +x gradlew

- name: Build with Gradle
  run: ./gradlew clean build --no-daemon
```

### 6.2 Docker 환경에서의 빌드

```dockerfile
FROM openjdk:17-jdk-slim

WORKDIR /app
COPY . .

# Gradle 캐시를 위한 레이어 분리
COPY gradle gradle
COPY gradlew build.gradle settings.gradle ./
RUN ./gradlew dependencies --no-daemon

# 소스 코드 복사 및 빌드
COPY src src
RUN ./gradlew clean build --no-daemon -x test
```

## 7. 모니터링 및 알림

### 7.1 빌드 실패 알림 스크립트

```bash
#!/bin/bash
# scripts/build-with-notification.sh

echo "빌드 시작..."
./gradlew clean build

if [ $? -eq 0 ]; then
    echo "✅ 빌드 성공!"
    # 성공 알림 (예: Slack, 이메일 등)
else
    echo "❌ 빌드 실패!"
    echo "빌드 로그를 확인해주세요."
    # 실패 알림
    exit 1
fi
```

### 7.2 빌드 시간 측정

```bash
#!/bin/bash
# scripts/measure-build-time.sh

echo "빌드 시간 측정 시작..."
start_time=$(date +%s)

./gradlew clean build

end_time=$(date +%s)
duration=$((end_time - start_time))

echo "빌드 완료! 소요 시간: ${duration}초"
```

## 8. 문제 예방 체크리스트

### 8.1 새로운 모듈 추가 시

- [ ] `settings.gradle`에 모듈 추가
- [ ] 적절한 `build.gradle` 파일 생성
- [ ] 의존성 순환 참조 확인
- [ ] 패키지 구조 일관성 확인
- [ ] 테스트 코드 작성

### 8.2 의존성 변경 시

- [ ] 버전 충돌 확인
- [ ] 의존성 트리 검토
- [ ] 모든 모듈에서 빌드 테스트
- [ ] 실행 테스트 수행

### 8.3 정기적 유지보수

- [ ] Gradle 버전 업데이트
- [ ] Spring Boot 버전 업데이트
- [ ] 의존성 보안 취약점 점검
- [ ] 빌드 성능 모니터링

---

이 가이드를 참조하여 빌드 문제를 효율적으로 해결하고 예방할 수 있습니다.
문제 발생 시 단계별로 진단하여 근본 원인을 파악하는 것이 중요합니다.
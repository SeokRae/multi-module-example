# [Feature Name] 

> 이 문서는 [Feature Name] 기능에 대한 종합적인 개요를 제공합니다.

## 📝 개요

### 목적
- 이 기능이 해결하는 문제
- 비즈니스 가치

### 범위
- 포함되는 기능들
- 제외되는 기능들

## 🏗️ 아키텍처 개요

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Controller    │───▶│    Service      │───▶│   Repository    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      DTO        │    │     Domain      │    │    Database     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🧩 주요 구성요소

### Domain Layer
- **Entities**: `[Entity1]`, `[Entity2]`
- **Value Objects**: `[VO1]`, `[VO2]`
- **Domain Services**: `[Service1]`, `[Service2]`

### Application Layer  
- **Controllers**: `[Controller1]`, `[Controller2]`
- **Services**: `[AppService1]`, `[AppService2]`
- **DTOs**: `[Request/Response objects]`

### Infrastructure Layer
- **Repositories**: `[Repository1]`, `[Repository2]`
- **External Services**: `[ExternalService1]`

## 🔗 관련 문서

- [📋 요구사항](./requirements.md)
- [🎨 설계](./design.md) 
- [⚙️ 구현](./implementation.md)
- [🌐 API 명세](./api-specification.md)
- [🧪 테스트](./testing.md)
- [🚀 배포](./deployment.md)

## 📊 현재 상태

- **요구사항 분석**: ❌ / ⏳ / ✅
- **설계 완료**: ❌ / ⏳ / ✅  
- **구현 완료**: ❌ / ⏳ / ✅
- **테스트 완료**: ❌ / ⏳ / ✅
- **문서화 완료**: ❌ / ⏳ / ✅
- **배포 준비**: ❌ / ⏳ / ✅

## 🎯 주요 이정표

- [ ] 요구사항 분석 및 승인
- [ ] 기술적 설계 완료
- [ ] 프로토타입 개발
- [ ] 핵심 기능 구현
- [ ] 테스트 및 품질 보증
- [ ] 프로덕션 배포

## 👥 관련 팀/역할

- **Product Owner**: [이름]
- **Tech Lead**: [이름] 
- **Backend Developer**: [이름]
- **Frontend Developer**: [이름]
- **QA Engineer**: [이름]

## 📈 성공 지표

### 비즈니스 지표
- 지표 1: 목표값
- 지표 2: 목표값

### 기술적 지표  
- 응답시간: < 100ms
- 가용성: > 99.9%
- 처리량: > 1000 req/sec

---

**최종 수정**: [YYYY-MM-DD]  
**담당자**: [이름]
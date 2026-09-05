# 반복·조건과 환경별 모듈 사용

[전체 실습 목록](../../README.md) · [버전·호환성](../../docs/examples.md#버전과-호환성)

*Terraform: Up & Running* Chapter 5 예제를 바탕으로 `count`, `for_each`, `for` 표현식, 조건부 자원 생성과 stage/prod 구성을 실습합니다. 기존 예제의 출처 표기를 각 하위 README에 유지합니다.

## 코드 탐색

| 주제 | 디렉토리 | 동작 |
|---|---|---|
| 단일 사용자 | [one-iam-user](live/global/one-iam-user) | 입력 이름으로 IAM 사용자 생성 |
| 번호 기반 반복 | [three-iam-users-increment-name](live/global/three-iam-users-increment-name) | 접두사와 `count.index`로 이름 생성 |
| 리스트·조건부 정책 | [three-iam-users-unique-names](live/global/three-iam-users-unique-names) | 리스트 길이만큼 사용자 생성, 첫 사용자에 CloudWatch 읽기 또는 전체 접근 정책 연결 |
| 집합 기반 반복 | [three-iam-users-for-each](live/global/three-iam-users-for-each) | 사용자 이름 집합으로 자원 생성 |
| 모듈 반복 | [module-count](live/global/three-iam-users-module-count), [module-for-each](live/global/three-iam-users-module-for-each) | 동일 IAM 모듈을 여러 번 호출 |
| 기존 자원 가져오기 | [existing-iam-user](live/global/existing-iam-user) | `createuser`의 `for_each` 주소로 IAM 사용자 관리 |
| 값 변환 | [for-expressions](live/global/for-expressions), [string-directives](live/global/string-directives) | 문자열·리스트·맵 변환, 필터링과 템플릿 조건 |
| EC2 반복 | [multiple-ec2-instances](live/stage/services/multiple-ec2-instances) | 고정 3대와 조회한 AZ 개수만큼 EC2 생성 |
| 환경별 구성 | [stage](live/stage), [prod](live/prod) | DB state를 참조하는 공통 웹 클러스터 모듈 사용 |

## stage와 prod

| 항목 | stage | prod |
|---|---|---|
| 웹 인스턴스 | `t2.micro` | `m4.large` |
| ASG 범위 | 최소 2·최대 2 | 최소 2·최대 10 |
| 예약 확장 | 비활성 | 09:00 희망 10, 17:00 희망 2의 cron 설정 |
| DB | `db.t2.micro`, MySQL | `db.t2.micro`, MySQL |

예약 시간은 코드의 cron 값이며 시간대를 별도로 지정하지 않습니다. 웹 모듈에는 CPU 사용률·CPU credit 경보도 정의되어 있습니다. 경보와 별도로 `enable_autoscaling`이 예약 확장 자원 생성을 제어합니다.

웹 서버의 user data는 DB state에서 읽은 주소·포트를 페이지에 표시합니다. DB 루트의 S3 backend를 먼저 설정하고 DB를 생성한 뒤, 웹 루트에 같은 bucket·key를 입력합니다. 웹 모듈은 Launch Configuration을 사용하므로 [현재 AWS 제한](../../docs/examples.md#버전과-호환성)을 먼저 확인합니다.

## AWS 자원 없이 표현식 확인

저장소 루트에서 실행합니다.

```bash
terraform -chdir=05/loop-cond/live/global/for-expressions init
terraform -chdir=05/loop-cond/live/global/for-expressions validate
terraform -chdir=05/loop-cond/live/global/for-expressions plan
```

출력 계획에서 대문자 변환, 길이 조건에 따른 필터링, 맵 변환을 확인합니다. IAM·EC2·DB 실습은 각 하위 경로가 실행 단위이며, AWS 자원을 생성합니다.

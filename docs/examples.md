# 실습 경로와 실행 전제

[저장소 소개](../README.md)

## 실습 선택

각 경로를 독립된 Terraform 루트 모듈로 사용합니다. 같은 디렉토리의 `.tf` 파일은 함께 읽힙니다.

| 경로 | 실습 내용 | 실행 전제 |
|---|---|---|
| [02/one-server](../02/one-server/main.tf) | EC2 한 대 생성 | `us-east-2`, 고정 AMI와 기본 VPC |
| [02/one-webserver](../02/one-webserver/main.tf) | user data·보안 그룹으로 8080 웹 서버 구성 | AMI에 BusyBox 실행 환경 필요 |
| [02/one-webserver-ext](../02/one-webserver-ext/main.tf) | 보안 그룹 이름·포트 변수, public IP 출력 | 웹 프로세스 포트는 코드에 `8080`으로 고정 |
| [02/lab01](../02/lab01/main.tf) | Public·Private 서브넷, NAT Gateway, 웹 EC2 | 같은 폴더의 `main.tf`·`main2.tf`·`main3.tf`를 함께 사용, `/home/tf/.ssh/mykeypair.pub` 필요 |
| [02/lab02](../02/lab02/ec2.tf) | AMI data source와 키 페어·EC2 | 기본 VPC, `~/.ssh/mykeypair.pub` |
| [02/webserver-cluster](../02/webserver-cluster/main.tf) | ALB·Target Group·Launch Template·ASG | 기본 VPC·서브넷, 키 파일, AWS Provider 리전을 실행 환경에서 설정 |
| [03/convert](../03/convert/main.tf) | VPC·EC2 2대·EIP·ALB | 기존 키 페어 이름 입력, Amazon Linux 2 이미지 사용 |
| [03/global](../03/global) | S3 backend와 EC2 state | S3 버킷을 먼저 준비하고 각 루트의 리전·state key 확인 |
| [03/elb-web-db](../03/elb-web-db) | DB state와 웹 서버 state 분리 | S3 → DB → 웹 서버 순서, 동일한 DB state bucket·key 참조 |
| [04/vpc-create/dev](../04/vpc-create/dev/main.tf) | VPC·EC2 모듈 입출력 | `ap-northeast-2`, EC2의 고정 AMI 확인 |
| [05/loop-cond](../05/loop-cond/README.md) | 반복·조건·모듈 호출·환경 분리 | 예제별 입력값과 Provider 제약 확인 |
| [05/simple-condition](../05/simple-condition/main.tf) | 문자열 조건식 | AWS 인증 없이 `name` 변수로 실행 |
| [05/variable-loop-datasource](../05/variable-loop-datasource/main.tf) | 조회한 AZ 개수만큼 서브넷 생성 | 리전의 AZ 개수와 CIDR 목록 확인 |
| [minipro1](../minipro1/README.md) | EC2 Docker 실습 환경 | Linux 셸·SSH 키·AWS 프로필 |
| [minipro2](../minipro2/README.md) | 다섯 모듈의 웹·DB 구성 | 서울 리전, DB 자격증명 입력 |

`05/variable-loop-datasource`는 AZ의 **개수**를 서브넷 반복 생성에 사용합니다. 서브넷의 `availability_zone`은 지정하지 않으므로 AZ별 배치를 보려면 실제 생성 결과를 확인합니다.

## S3 상태 참조

`03/elb-web-db`의 DB 구성은 S3 backend에 state를 저장하고, 웹 서버 구성은 `terraform_remote_state`로 `dbIP`·`dbPort`를 읽습니다. 이 값을 웹 서버 user data에 넣어 페이지에 표시합니다.

S3 예제에는 고정 버킷 이름이 있으므로 실행할 계정의 버킷 이름으로 맞춰 사용합니다. `03/global/s3`와 `03/elb-web-db/global/s3`는 동일한 버킷 이름을 정의하므로 하나의 버킷을 두 state에서 중복 관리하지 않도록 실습을 분리합니다. S3 예제의 `force_destroy = true`는 삭제 시 버킷 객체도 함께 제거하는 설정입니다.

DB 입력값은 실행 환경에서 입력합니다. `db_credentials.sh`에는 고정 예시 값이 있으므로 실제 환경의 자격증명은 별도로 전달합니다. `sensitive`는 화면 표시를 가리는 설정이며 state의 비밀값 저장을 막지 않습니다. [HashiCorp 민감 데이터 안내](https://developer.hashicorp.com/terraform/language/manage-sensitive-data)

## 초기화 스크립트

`03/convert`의 인라인 user data와 `03/elb-web-db`의 `user_data.sh`는 첫 줄에 셸 식별자(`#!/bin/bash`)가 빠져 있습니다. EC2가 user data를 셸 스크립트로 실행하려면 이 식별자가 필요하므로, 해당 예제를 실행할 때 초기화 스크립트 첫 줄을 보완해야 합니다. `minipro1`·`minipro2`의 스크립트에는 식별자가 포함되어 있습니다. [AWS user data 안내](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)

## 버전과 호환성

아래는 코드에 남아 있는 방식과 현재 공식 안내의 관계입니다.

| 대상 | 코드의 방식 | 현재 사용·실행 시 참고 |
|---|---|---|
| `05/loop-cond` 웹 모듈 | `aws_launch_configuration` | AWS는 Launch Template 사용을 안내하며, 2024-10-01 이후 생성한 계정은 새 Launch Configuration을 만들 수 없음. 저장소의 `minipro2`는 `aws_launch_template` 사용 — [AWS 안내](https://docs.aws.amazon.com/autoscaling/ec2/userguide/launch-configurations.html) |
| `03/convert` | Amazon Linux 2의 SSM AMI 경로 | Amazon Linux 2는 2026-06-30 지원 종료. 저장소의 `minipro1`·`minipro2`는 Amazon Linux 2023 이미지 조회 — [AWS 안내](https://aws.amazon.com/amazon-linux-2/faqs/) |
| `03`의 S3 backend | `use_lockfile = true` | S3 native locking은 Terraform 1.10에서 추가됨 — [릴리스 기록](https://github.com/hashicorp/terraform/releases/tag/v1.10.0) |
| 기존 DB 예제 문서 | DynamoDB 잠금 안내 | 현재 S3 backend는 `use_lockfile` 지원, DynamoDB 기반 잠금은 deprecated — [HashiCorp 안내](https://developer.hashicorp.com/terraform/language/backend/s3) |
| `05/loop-cond`의 다수 예제 | Terraform `>= 1.0.0, < 2.0.0`, AWS Provider `~> 4.0` | 예제의 제약은 해당 실행 디렉토리와 자식 모듈에 적용 |
| `minipro1`·`minipro2` | AWS Provider 버전 제약 생략 | `init`에서 선택한 버전을 확인하고, 재실행 시 같은 lock 파일 사용 |

이 저장소는 `.terraform.lock.hcl`을 Git 제외 대상으로 두고 있습니다. 로컬에서 생성된 lock 파일은 Provider 선택 결과를 담으므로 실행 환경을 재현할 때 함께 관리합니다. 공식 권장 방식은 lock 파일을 버전 관리에 포함하는 것입니다. [Dependency Lock File](https://developer.hashicorp.com/terraform/language/files/dependency-lock)

고정 AMI ID와 `most_recent` 이미지 조회는 실습마다 다릅니다. 실제 리전의 이미지 제공 여부와 조회 결과는 해당 실습의 `plan`에서 확인합니다.

## 외부 학습 저장소 참조

다음 경로는 파일 본문 대신 Git 저장소의 커밋을 가리키는 gitlink로 저장되어 있습니다.

| 경로 | 기록된 커밋 |
|---|---|
| `02/data-output/learn-terraform-outputs` | `ef89e0b605b5c36475b794e17a864db87ae71bcd` |
| `02/data-source/learn-terraform-data-sources-app` | `bf30acbc5b5ec6819be830b00df2b7d7d133cdd1` |
| `02/data-source/learn-terraform-data-sources-vpc` | `5204ab4c44aba124541a1a0224c3f2b84c3539d5` |
| `02/one-web-server-with-vars/learn-terraform-variables` | `543b5e5d1332f0d7fb2c632dd6694ce5a8f998a9` |

`.gitmodules`의 원격 URL 매핑이 없어 일반 clone으로는 이 경로의 소스가 복원되지 않습니다. 해당 실습을 실행하려면 원본 저장소 URL과 기록된 커밋을 확보해야 합니다.

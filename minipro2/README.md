# 모듈 기반 AWS 웹·DB 구성

[전체 실습 목록](../README.md)

**VPC·보안 그룹·ALB·RDS·EC2를 다섯 모듈로 구성합니다.** [`dev/main.tf`](dev/main.tf)가 각 모듈을 조합하고, 네트워크 ID와 서비스 endpoint를 출력·입력으로 전달합니다.

## 구성과 연결

| 모듈 | 생성 자원 | 다음 모듈에 전달하는 값 |
|---|---|---|
| [vpc](modules/vpc/main.tf) | VPC, IGW, public 2개·private 2개 서브넷, 라우팅 테이블 | VPC ID → SG·ALB, public 서브넷 → ALB·EC2, private 서브넷 → RDS |
| [sg](modules/sg/main.tf) | ALB·EC2·DB 보안 그룹과 ingress/egress 규칙 | 각 계층의 보안 그룹 ID |
| [alb](modules/alb/main.tf) | ALB, HTTP 리스너·규칙, Target Group | Target Group ARN → EC2, ALB DNS → 루트 출력 |
| [rds](modules/rds/main.tf) | DB 서브넷 그룹, Aurora MySQL 클러스터·인스턴스 2개 | DB endpoint·port → EC2 user data |
| [ec2](modules/ec2/main.tf) | AMI 조회, Launch Template, Auto Scaling Group | ASG 이름 |

웹 요청은 **ALB 80 → Target Group 80 → EC2 Apache**로 전달됩니다. DB 보안 그룹은 EC2 보안 그룹에서 오는 TCP `3306`을 허용합니다. [user_data.sh](modules/ec2/user_data.sh)는 Apache·PHP를 설치하고 DB endpoint·port를 표시하는 페이지를 생성합니다. 이 페이지의 확인 대상은 Terraform 출력값이 서버 초기화에 전달되는 흐름입니다.

## 네트워크와 기본값

| 항목 | 기본 구성 |
|---|---|
| 리전 | `ap-northeast-2` |
| AZ | `ap-northeast-2a`, `ap-northeast-2c` |
| VPC | `10.0.0.0/16` |
| Public 서브넷 | `10.0.1.0/24`, `10.0.2.0/24` — ALB·웹 EC2 |
| Private 서브넷 | `10.0.3.0/24`, `10.0.4.0/24` — DB 서브넷 그룹 |
| Public 라우팅 | `0.0.0.0/0` → IGW, EC2 public IP 자동 할당 |
| Private 라우팅 | VPC 내부 통신 |
| 웹 인스턴스 | `t3.micro`, ASG 희망 2·최소 1·최대 4 |
| DB | Aurora MySQL, DB 이름 `mydb`, `db.r5.large` 2개 |
| AMI 조건 | Amazon 소유의 `al2023-ami-2023.*-kernel-6.18-x86_64` 중 최신 항목 |

ASG는 희망 인스턴스 수 2대를 유지하도록 구성하며, 최소·최대 수는 각각 1대·4대입니다. RDS는 클러스터를 만든 뒤 첫 번째·두 번째 인스턴스를 순서대로 생성하며, EC2 모듈은 ALB·RDS 모듈에 명시적으로 의존합니다.

## 초기화와 계획 확인

Terraform CLI, AWS CLI와 사용할 AWS 계정의 인증 구성이 필요합니다. AWS Provider 설치를 위한 네트워크 연결과 VPC·EC2·ELB·Auto Scaling·RDS 작업 권한을 준비합니다.

저장소 루트에서 실행합니다.

```bash
aws sts get-caller-identity
terraform -chdir=minipro2/dev init
terraform -chdir=minipro2/dev validate
terraform -chdir=minipro2/dev providers
terraform version
```

`minipro2`는 Provider 버전 제약을 지정하지 않습니다. `init`이 선택한 버전은 로컬 `.terraform.lock.hcl`에 기록됩니다. [버전과 호환성](../docs/examples.md#버전과-호환성)을 함께 확인합니다.

DB 계정은 현재 셸에서 입력합니다. 저장소의 `db_credentials.sh` 대신 실행할 환경의 값을 직접 제공합니다.

```bash
read -r -p 'DB 사용자 이름: ' TF_VAR_db_username
read -r -s -p 'DB 비밀번호: ' TF_VAR_db_password
printf '\n'
export TF_VAR_db_username TF_VAR_db_password
terraform -chdir=minipro2/dev plan
```

`plan`에서 서울 리전, AMI 조회 결과, ALB·ASG·Aurora 생성 계획을 확인합니다. AWS의 해당 리전에서 AMI 조건과 DB 인스턴스 클래스가 제공되어야 합니다. `myALB`, `myTG`, `myLT`, `mydbcluster` 등 고정 이름을 사용하므로 같은 계정·리전의 기존 자원 이름도 확인합니다.

## 생성과 확인

아래 명령은 **ALB·EC2·Aurora 등 비용이 발생하는 자원**을 생성합니다. 계획 내용을 확인한 뒤 대화형 승인으로 적용합니다.

```bash
terraform -chdir=minipro2/dev apply
terraform -chdir=minipro2/dev output
terraform -chdir=minipro2/dev state list
```

[dev/outputs.tf](dev/outputs.tf)에 정의된 ALB 출력으로 요청합니다.

```bash
ALB_DNS=$(terraform -chdir=minipro2/dev output -raw alb_dns_name)
curl -i "http://$ALB_DNS/"
```

| 확인 지점 | 확인할 내용 |
|---|---|
| Terraform 출력 | ALB DNS 이름과 DB endpoint |
| ASG | 희망 수 2와 실행 인스턴스 상태 |
| Target Group | 웹 서버 초기화 후 대상이 `healthy`로 표시되는지 |
| HTTP 응답 | `My Web Server`, DB Endpoint, DB Port가 표시되는지 |
| 네트워크 | ALB→EC2 80, EC2→DB 3306의 SG 참조 |

ALB 생성 직후에는 EC2의 패키지 설치와 웹 서버 시작에 시간이 필요합니다. Target Group이 정상 상태가 된 후 HTTP 응답을 확인합니다.

## 정리

같은 디렉토리의 state와 DB 입력값을 유지한 상태로 삭제 계획을 확인합니다.

```bash
terraform -chdir=minipro2/dev plan -destroy
terraform -chdir=minipro2/dev destroy
unset TF_VAR_db_username TF_VAR_db_password
```

RDS의 `skip_final_snapshot = true` 설정에 따라 클러스터 삭제 시 최종 스냅샷을 생성하지 않습니다. 보관할 데이터가 있다면 삭제 전에 백업합니다. DB 입력 변수는 `sensitive`로 출력이 가려지지만, state에는 자격증명이 저장될 수 있으므로 state 접근 권한을 관리합니다.

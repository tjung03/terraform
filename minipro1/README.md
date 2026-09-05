# EC2 Docker 실습 환경

[전체 실습 목록](../README.md)

**VPC·인터넷 게이트웨이·Public 서브넷·EC2를 생성하고, user data로 Docker를 설치하는 구성입니다.** `local-exec`는 실행한 컴퓨터의 `~/.ssh/config`에 인스턴스 접속 항목을 추가합니다.

## 구성

| 파일 | 역할 |
|---|---|
| [main.tf](main.tf) | VPC·라우팅·보안 그룹·키 페어·EC2, 로컬 SSH 설정 실행 |
| [proviers.tf](proviers.tf) | `us-east-2`, AWS `default` 프로필 설정 |
| [user_data.sh](user_data.sh) | Docker 설치·서비스 시작 |
| [linux-ssh-config.tpl](linux-ssh-config.tpl) | 호스트 IP·사용자·키 경로를 SSH 설정에 추가 |
| [variables.tf](variables.tf) | 자원 이름과 태그 |
| [outputs.tf](outputs.tf) | SSH 접속 명령 출력 |

네트워크는 `10.0.0.0/16`, Public 서브넷은 `10.0.1.0/24`입니다. EC2는 Amazon Linux 2023의 kernel 6.18 이미지 조건을 조회하고 `t3.micro`를 사용합니다.

## 실행 전제

Bash·OpenSSH·Terraform·AWS CLI가 있는 Linux 환경을 사용합니다. AWS `default` 프로필과 `~/.ssh/mykeypair.pub` 공개 키, 대응하는 `~/.ssh/mykeypair` 개인 키를 준비합니다. EC2에 등록할 키 페어 이름은 `mykeypair`입니다.

현재 보안 그룹은 모든 IPv4 주소에서 모든 프로토콜의 인바운드를 허용합니다. 적용할 환경의 접근 범위에 맞게 보안 그룹을 먼저 검토합니다. `local-exec`는 로컬 `~/.ssh/config`에 항목을 덧붙입니다.

## 초기화·계획·생성

저장소 루트에서 실행합니다.

```bash
aws sts get-caller-identity --profile default
terraform -chdir=minipro1 init
terraform -chdir=minipro1 validate
terraform -chdir=minipro1 plan
```

계획 확인 후 EC2와 public IPv4 등 유료 자원을 생성합니다.

```bash
terraform -chdir=minipro1 apply
terraform -chdir=minipro1 output ec2_connection
```

출력된 SSH 명령으로 접속하고 Docker 설치 상태를 확인합니다.

```bash
sudo systemctl is-active docker
sudo docker version
```

## 정리

```bash
terraform -chdir=minipro1 plan -destroy
terraform -chdir=minipro1 destroy
```

삭제한 인스턴스의 로컬 SSH 설정 항목은 `~/.ssh/config`에서 직접 정리합니다.

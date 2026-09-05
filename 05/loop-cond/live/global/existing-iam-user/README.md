# IAM 사용자 생성과 기존 자원 가져오기

[반복·조건 실습](../../../README.md)

[main.tf](main.tf)는 `for_each = toset(var.user_names)`로 IAM 사용자를 관리합니다. 기본 이름은 `red`, `blue`, `green`이며 자원 주소는 `aws_iam_user.createuser["이름"]`입니다.

## 계획 확인

AWS 인증을 구성한 뒤 이 디렉토리에서 실행합니다.

```bash
terraform init
terraform validate
terraform plan
```

계획에는 state에서 관리하지 않는 사용자 생성이 표시됩니다. 동일한 이름의 사용자가 AWS 계정에 이미 있다면 해당 자원을 먼저 가져옵니다. 예를 들어 `red`가 이미 존재하는 경우:

```bash
terraform import 'aws_iam_user.createuser["red"]' red
terraform plan
```

`blue`·`green`도 기존에 존재한다면 각각 같은 형식으로 가져옵니다. `apply`는 최종 계획에 따라 사용자를 생성·변경합니다. 가져온 사용자는 Terraform 관리 대상이 되므로 이후 삭제 계획에도 포함됩니다.

## 출력

[outputs.tf](outputs.tf)의 `arns`는 관리하는 사용자의 ARN 목록입니다.

```bash
terraform output arns
```

하위 [for/](for/main.tf)는 이름·역할 값을 변환하는 별도 표현식 실습입니다.

학습 출처: *Terraform: Up & Running*, Chapter 5. 기존 예제의 import 개념을 현재 `for_each` 자원 주소에 맞춰 설명합니다.

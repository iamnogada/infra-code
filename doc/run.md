# how to run

> terraform 은 실행되는 디렉토리 하위의 *.tf 파일을 병합하여 처리함.
> 다수의 *.tf 파일은 하나로 취급됨

## 구성요소
- *.tf : 자원 관리/정의
- terraform.tfvars, terraform.auto.tfvars : 변수 값을 로딩하기 위하 자동으로 로딩됨
- 기타.tfvars: 사용자에 의해 명시적으로 지정되는 변수 파일

## 프로젝트 초기화
- terraform init : *.tf 파일 중에 provider 블럭 내용을 기준으로 필요함 라이브러리 다운로드

## variable
- *.tf 내 variable을 선언 필수 
  ```js
  variable name { type = string }
  variable rg { type = string }
  variable vnet { type = string }
  variable cidr { type = list(string) }
  variable vrd_dmz_subnet{
    type = list(object({
        name = string
        cidr = list(string)
    }))
    default = []
  }
  resource "azurerm_subnet" "subnet" {
    name                 = "${var.name}-001-subnet"
    resource_group_name  = var.rg
    virtual_network_name = var.vnet
    address_prefixes     = var.cidr
  }
  ``` 
- *.tfvars에 변수 저장
  ```js
  default_route_id="/subscriptions/2dbedacf-40ac-4b61-8bdc-a3025e767aee/..."
  vrd_dmz_subnet = [
    {
        name = "skgc-vrd-prod-koce-dmz-001-subnet" 
        cidr = ["10.242.18.0/26"]
    },
    {
        name = "skgc-vrd-dev-koce-dmz-001-subnet" 
        cidr = ["10.242.22.0/26"]
    },
    {
        name = "skgc-vrd-dev-koce-dmz-002-subnet" 
        cidr = ["10.242.16.64/26"]
    }
  ]
  ```

- env에 값 설정 : export TF_VAR_[변수명]=[value]
- argument로 변수 값 전달 : terraform apply/plan -var 'region=us-west-2'

## run

- plan : terraform plan  
  dry run으로서 현재 저장된 상태를 기준으로 자원의 변화를 확인
- apply : terraform apply  [-auto-approve]
  실행을 통해 변경 상태를 state에 저장하고, approve를 통해 실행 함
- destroy : terraform destroy  [-auto-approve]
  관리되는 자원을 삭제

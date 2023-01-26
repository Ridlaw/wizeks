variable "awsvar" {
  type = map(string)
  default = {
    region       = "us-east-1"
    vpc          = "wizvpc-001"
    cidr         = "10.0.0.0/16"
    pubsubnet    = "10.0.1.0/24"
    prisubnet    = "10.0.2.0/24"
    ami          = "ami-0b0ea68c435eb488d" #xenial	16.04 LTS	amd64	hvm:ebs-ssd	20210928
    itype        = "t2.micro"
    subnet       = "wizprivsubnet-001"
    publicip     = true
    keyname      = "wizdemokeypair"
    secgroupname = "WIZSecGroup"
  }
}
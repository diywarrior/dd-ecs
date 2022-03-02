locals {
  cpu = 1024
  memory = 2048
  desired_count = 10
  whitelisted_cidrs = [
    "192.168.0.1/32"
  ]
}
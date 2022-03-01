locals {
  cpu = 256
  memory = 512
  desired_count = 1
  whitelisted_cidrs = [
    "192.168.0.1/32"
  ]
}
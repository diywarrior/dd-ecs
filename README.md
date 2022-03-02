# dd-ecs


## Prerequisities

 - configured awscli
 - terraform >= 1.1
 - python3 with pip
 - docker


## Set-up ECS
1. Rename locals_example.tf to locals.tf
2. Update locals with your settings
   1. CPU and Memory should be set according to :
     ![img.png](img.png) 
   2. desired count means a number of containers running simultaniously
   3. you can add your public IP to whitelist, if required
3. Setup ECS environmment (VPC, subnets, ECR and so on)
```shell
    terraform init
    terraform apply
```
2. Install required python packages
```shell
    pip3 install -r requirements.txt
```
3. Build and deploy image
```shell
    python3 build.py
```


## Set-up docker compose (ubuntu example)
1. install docker
```shell
    sudo apt install docker.io
```

2. install docker-compose
```shell
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
```

3. Start compose
```shell
    cd code
    sh attack.sh 
    #or sh attack.sh 5 (number of containers to run simultaniously)
```

4. To check logs
```shell
    docker-compose logs --tail=0 --follow
```

5. To stop container
```shell
    sh stop.sh
```
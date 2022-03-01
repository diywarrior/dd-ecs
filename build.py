import boto3, docker, base64

LOCAL_REPOSITORY = 'repo'
ECS_CLUSTER = 'dd'
ECS_SERVICE = 'dd'


if __name__ == "__main__":
    client_id = boto3.client('sts').get_caller_identity().get('Account')

    docker_client = docker.from_env()
    image, build_log = docker_client.images.build(
        path='./code', tag=LOCAL_REPOSITORY, rm=True)
    ecr_client = boto3.client('ecr')
    ecr_credentials = (
        ecr_client
            .get_authorization_token()
        ['authorizationData'][0])
    ecr_username = 'AWS'
    ecr_password = (
        base64.b64decode(ecr_credentials['authorizationToken'])
        .replace(b'AWS:', b'')
            .decode('utf-8'))
    ecr_url = ecr_credentials['proxyEndpoint']
    docker_client.login(
        username=ecr_username, password=ecr_password, registry=ecr_url)
    ecr_repo_name = '{}/{}'.format(
        ecr_url.replace('https://', ''), LOCAL_REPOSITORY)
    image.tag(ecr_repo_name, tag='latest')
    push_log = docker_client.images.push(ecr_repo_name, tag='latest')
    ecs_client = boto3.client(
        'ecs')
    ecs_client.update_service(
        cluster=ECS_CLUSTER, service=ECS_SERVICE, forceNewDeployment=True)
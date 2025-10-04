import boto3
region = 'us-east-1'
instances = ['i-09a24de680d4b2a5b', 'i-0ac493277d7a2f87b']
ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    ec2.start_instances(InstanceIds=instances)
    print('started your instances: ' + str(instances))
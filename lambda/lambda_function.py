import boto3
import datetime

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    try:
        # Get all instances with the tag Backup=True
        instances = ec2.describe_instances(
            Filters=[{
                'Name': 'tag:Backup',
                'Values': ['True']
            }]
        )

        timestamp = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H-%M-%SZ')
        snapshot_ids = []

        for reservation in instances['Reservations']:
            for instance in reservation['Instances']:
                instance_id = instance['InstanceId']
                for dev in instance.get('BlockDeviceMappings', []):
                    if 'Ebs' in dev:
                        volume_id = dev['Ebs']['VolumeId']
                        description = f"Backup from {instance_id} on {timestamp}"
                        print(f"Creating snapshot for volume {volume_id} - {description}")
                        snapshot = ec2.create_snapshot(
                            VolumeId=volume_id,
                            Description=description,
                            TagSpecifications=[{
                                'ResourceType': 'snapshot',
                                'Tags': [
                                    {'Key': 'Name', 'Value': f"{instance_id}-{timestamp}"},
                                    {'Key': 'CreatedBy', 'Value': 'SmartVaultLambda'}
                                ]
                            }]
                        )
                        snapshot_ids.append(snapshot['SnapshotId'])

        return {
            'statusCode': 200,
            'body': f"Snapshots created: {snapshot_ids}"
        }

    except Exception as e:
        print(f"Error creating snapshots: {e}")
        return {
            'statusCode': 500,
            'body': str(e)
        }


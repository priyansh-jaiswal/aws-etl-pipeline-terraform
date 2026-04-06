import boto3
import json
import os

SFN_ARN = os.environ.get("SFN_ARN", "")

def lambda_handler(event, context):
    # Get the file that was uploaded to S3
    bucket = event['Records'][0]['s3']['bucket']['name']
    key    = event['Records'][0]['s3']['object']['key']

    print(f"New file detected: s3://{bucket}/{key}")

    # Only trigger for CSV files
    if not key.endswith('.csv'):
        print("Not a CSV file, skipping.")
        return {'statusCode': 200, 'body': 'Skipped non-CSV file'}

    # Start Step Functions execution
    sfn      = boto3.client('stepfunctions', region_name='ap-south-1')
    response = sfn.start_execution(
        stateMachineArn=SFN_ARN,
        input=json.dumps({
            'bucket': bucket,
            'key':    key
        })
    )

    execution_arn = response['executionArn']
    print(f"Step Functions started! Execution ARN: {execution_arn}")

    return {
        'statusCode': 200,
        'body': json.dumps(f'Step Functions execution started: {execution_arn}')
    }

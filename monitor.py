import urllib3
import os
import boto3

sns = boto3.client('sns')
TOPIC_ARN = os.environ['SNS_TOPIC_ARN']
SITE_URL = os.environ['SITE_URL']

def lambda_handler(event, context):
    http = urllib3.PoolManager()
    try:
        response = http.request('GET', SITE_URL, timeout=5.0)
        if response.status == 200:
            print(f"{SITE_URL} is up and running.")
        else:
            message = f"{SITE_URL} is down. Status code: {response.status}"
            sns.publish(TopicArn=TOPIC_ARN, Message=message, Subject='Website Down Alert')
        
    except Exception as e:
        error_message = f"Error, unreachable! {SITE_URL}: {str(e)}"
        sns.publish(TopicArn=TOPIC_ARN, Message=error_message, Subject='Website Unreachable Alert')
        print(error_message)

import boto3
import json

from botocore.exceptions import ClientError

def lambda_handler(event, context):
    try:
        print('event: ')
        print(event)
    except ClientError as e:
        print(e)
        return {
            'statusCode': 500,
            'body': json.dumps({
                message: 'Error occurred!'
            }),
            'headers' : {
                'Access-Control-Allow-Origin' : '*'
            }
        }
    else:
        return {
            'statusCode': 200,
            'body': json.dumps({
                message:'Hello World! from api.ameyrupji.com'
            }),
            'headers' : {
                'Access-Control-Allow-Origin' : '*'
            }
        }
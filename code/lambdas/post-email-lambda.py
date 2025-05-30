import boto3
import json

from botocore.exceptions import ClientError

def lambda_handler(event, context):
    try:
        print('event: ')
        print(event)

        post_data = event["body"]

        SENDER = "Contact Form <ameyrupji@gmail.com>"
        RECIPIENT = "ameyrupji@gmail.com"
        # CONFIGURATION_SET = "ConfigSet"
        AWS_REGION = "us-east-1"
        SUBJECT = "Contact Form Submitted"
        BODY_TEXT = (json.dumps(post_data))
        BODY_HTML = """<html>
        <head></head>
        <body>
        <h1>Contact form submitted.</h1>
        <p>Details:</p>
        <p>{form_content}</p>
        </body>
        </html>""".format(form_content=json.dumps(post_data))        
        CHARSET = "UTF-8"

        client = boto3.client('ses',region_name=AWS_REGION)
    
        response = client.send_email(
            Destination={
                'ToAddresses': [
                    RECIPIENT,
                ],
            },
            Message={
                'Body': {
                    'Html': {
                        'Charset': CHARSET,
                        'Data': BODY_HTML,
                    },
                    'Text': {
                        'Charset': CHARSET,
                        'Data': BODY_TEXT,
                    },
                },
                'Subject': {
                    'Charset': CHARSET,
                    'Data': SUBJECT,
                },
            },
            Source=SENDER
        )
        print('Email sent! Message ID:' + response['MessageId']);
    except ClientError as e:
        print(e)
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error occurred in sending email!'
            }),
            'headers' : {
                'Access-Control-Allow-Origin' : '*'
            }
        }
    else:
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Email successfully sent!'
            }),
            'headers' : {
                'Access-Control-Allow-Origin' : '*'
            }
        }
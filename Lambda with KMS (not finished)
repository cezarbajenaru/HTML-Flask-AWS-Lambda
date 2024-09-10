import boto3
import json
import logging
import os
from base64 import b64decode
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError
from time import time

# Initialize boto3 clients
kms_client = boto3.client('kms')
logs_client = boto3.client('logs')

# Get environment variables
ENCRYPTED_HOOK_URL = os.environ['ENCRYPTED_HOOK_URL']  # Base64-encoded encrypted Slack webhook URL
SLACK_CHANNEL = os.environ['SLACK_CHANNEL']  # Slack channel where the message will be posted
LOG_GROUP_NAME = os.environ['AWS_LAMBDA_LOG_GROUP_NAME']  # Default log group for the Lambda function
LOG_STREAM_NAME = f"custom-log-stream-{int(time())}"  # Custom log stream name based on timestamp

# Setup logging
logger = logging.getLogger()
logger.setLevel(logging.DEBUG)  # Capture all log levels



def get_decrypted_hook_url(encrypted_url):
    """Decrypt the Slack webhook URL."""
    
def fix_padding(encoded_string):
    return encoded_string + '=' * (-len(encoded_string) % 4)    

    try:
        encrypted_url = fix_padding(encrypted_url)
        decrypted = kms_client.decrypt(
            CiphertextBlob=b64decode(encrypted_url),
            EncryptionContext={'LambdaFunctionName': os.environ['AWS_LAMBDA_FUNCTION_NAME']}
        )['Plaintext'].decode('utf-8')
        return decrypted
    except Exception as e:
        logger.critical("Failed to decrypt Slack Webhook URL: %s", e)
        raise

def create_log_stream():
    """Create a log stream in the specified log group."""
    try:
        logs_client.create_log_stream(
            logGroupName=LOG_GROUP_NAME,
            logStreamName=LOG_STREAM_NAME
        )
        logger.info(f"Created log stream: {LOG_STREAM_NAME} in log group: {LOG_GROUP_NAME}")
    except logs_client.exceptions.ResourceAlreadyExistsException:
        logger.info(f"Log stream {LOG_STREAM_NAME} already exists in log group: {LOG_GROUP_NAME}")
    except Exception as e:
        logger.error(f"Failed to create log stream: {e}")

def log_to_custom_stream(message):
    """Log message to custom log stream."""
    try:
        timestamp = int(time() * 1000)
        logs_client.put_log_events(
            logGroupName=LOG_GROUP_NAME,
            logStreamName=LOG_STREAM_NAME,
            logEvents=[{
                'timestamp': timestamp,
                'message': message
            }]
        )
        logger.info("Successfully logged to custom log stream")
    except Exception as e:
        logger.error(f"Failed to log to custom log stream: {e}")

def lambda_handler(event, context):
    # Create custom log stream
    create_log_stream()

    logger.debug("Event received: %s", json.dumps(event))
    
    # Extract message from the event
    try:
        message = json.loads(event['Records'][0]['Sns']['Message'])
        logger.debug("Extracted message: %s", json.dumps(message))
        log_to_custom_stream(f"Extracted message: {json.dumps(message)}")
    except KeyError as e:
        logger.error("Failed to extract message from event: %s", e)
        log_to_custom_stream(f"Error: Failed to extract message - {e}")
        return {
            'statusCode': 500,
            'body': json.dumps('Error processing SNS event')
        }

    alarm_name = message.get('AlarmName', 'Unknown Alarm')
    new_state = message.get('NewStateValue', 'UNKNOWN')
    reason = message.get('NewStateReason', 'No reason provided')

    logger.info("Processing alarm: %s, New State: %s", alarm_name, new_state)
    log_to_custom_stream(f"Processing alarm: {alarm_name}, New State: {new_state}")

    # Decrypt the webhook URL
    try:
        decrypted_hook_url = get_decrypted_hook_url(ENCRYPTED_HOOK_URL)
        logger.debug("Decrypted Hook URL: %s", decrypted_hook_url)
        log_to_custom_stream("Decrypted Slack Webhook URL")
    except Exception as e:
        logger.critical("Unable to decrypt the webhook URL, cannot proceed: %s", e)
        log_to_custom_stream(f"Critical Error: Unable to decrypt the webhook URL - {e}")
        return {
            'statusCode': 500,
            'body': json.dumps('Unable to decrypt the webhook URL')
        }

    # Determine the message based on the alarm state and type
    if 'CPU' in alarm_name:
        if new_state == "ALARM":
            slack_message = {
                'channel': SLACK_CHANNEL,
                'text': ":red_circle: *CPU ALARM*: %s state is now %s: %s" % (alarm_name, new_state, reason)
            }
            logger.warning("CPU Alarm triggered: %s", slack_message['text'])
            log_to_custom_stream(f"CPU Alarm triggered: {slack_message['text']}")
        elif new_state == "OK":
            slack_message = {
                'channel': SLACK_CHANNEL,
                'text': ":white_check_mark: *CPU OK*: %s state is now %s: %s" % (alarm_name, new_state, reason)
            }
            logger.info("CPU Alarm resolved: %s", slack_message['text'])
            log_to_custom_stream(f"CPU Alarm resolved: {slack_message['text']}")
        else:
            slack_message = {
                'channel': SLACK_CHANNEL,
                'text': ":warning: *CPU INSUFFICIENT DATA*: %s state is now %s: %s" % (alarm_name, new_state, reason)
            }
            logger.warning("CPU Alarm has insufficient data: %s", slack_message['text'])
            log_to_custom_stream(f"CPU Alarm has insufficient data: {slack_message['text']}")
    elif 'RAM' in alarm_name:
        if new_state == "ALARM":
            slack_message = {
                'channel': SLACK_CHANNEL,
                'text': ":red_circle: *RAM ALARM*: %s state is now %s: %s" % (alarm_name, new_state, reason)
            }
            logger.warning("RAM Alarm triggered: %s", slack_message['text'])
            log_to_custom_stream(f"RAM Alarm triggered: {slack_message['text']}")
        elif new_state == "OK":
            slack_message = {
                'channel': SLACK_CHANNEL,
                'text': ":white_check_mark: *RAM OK*: %s state is now %s: %s" % (alarm_name, new_state, reason)
            }
            logger.info("RAM Alarm resolved: %s", slack_message['text'])
            log_to_custom_stream(f"RAM Alarm resolved: {slack_message['text']}")
        else:
            slack_message = {
                'channel': SLACK_CHANNEL,
                'text': ":warning: *RAM INSUFFICIENT DATA*: %s state is now %s: %s" % (alarm_name, new_state, reason)
            }
            logger.warning("RAM Alarm has insufficient data: %s", slack_message['text'])
            log_to_custom_stream(f"RAM Alarm has insufficient data: {slack_message['text']}")
    else:
        slack_message = {
            'channel': SLACK_CHANNEL,
            'text': ":information_source: *UNKNOWN ALARM*: %s state is now %s: %s" % (alarm_name, new_state, reason)
        }
        logger.error("Unknown alarm type: %s", slack_message['text'])
        log_to_custom_stream(f"Unknown alarm type: {slack_message['text']}")

    # Send the message to Slack
    try:
        req = Request(decrypted_hook_url, json.dumps(slack_message).encode('utf-8'))
        req.add_header('Content-Type', 'application/json')
        response = urlopen(req)
        response.read()
        logger.info("Message posted to %s", SLACK_CHANNEL)
        log_to_custom_stream(f"Message posted to Slack: {SLACK_CHANNEL}")
    except HTTPError as e:
        logger.error("Request failed: %d %s", e.code, e.reason)
        log_to_custom_stream(f"Slack post request failed: {e.code} {e.reason}")
    except URLError as e:
        logger.error("Server connection failed: %s", e.reason)
        log_to_custom_stream(f"Slack post connection failed: {e.reason}")

    return {
        'statusCode': 200,
        'body': json.dumps('Notification sent to Slack')
    }

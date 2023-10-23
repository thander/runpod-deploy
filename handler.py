import time
import requests
import runpod
from runpod.serverless.utils.rp_validator import validate
from runpod.serverless.modules.rp_logger import RunPodLogger
from requests.adapters import HTTPAdapter, Retry
from schemas.api import API_SCHEMA
from schemas.img2img import IMG2IMG_SCHEMA
from schemas.txt2img import TXT2IMG_SCHEMA
from schemas.options import OPTIONS_SCHEMA

BASE_URL = 'http://127.0.0.1:3000'
TIMEOUT = 600

session = requests.Session()
retries = Retry(total=10, backoff_factor=0.1, status_forcelist=[502, 503, 504])
session.mount('http://', HTTPAdapter(max_retries=retries))
session.headers.update({"Content-Type": "application/json", 'Accept': 'application/json'})
logger = RunPodLogger()


# ---------------------------------------------------------------------------- #
#                              Automatic Functions                             #
# ---------------------------------------------------------------------------- #

def wait_for_service(url):
    retries = 0

    while True:
        try:
            requests.get(url)
            return
        except requests.exceptions.RequestException:
            retries += 1

            # Only log every 15 retries so the logs don't get spammed
            if retries % 15 == 0:
                logger.info('Service not ready yet. Retrying...')
        except Exception as err:
            logger.error(f'Error: {err}')

        time.sleep(0.2)


def send_get_request(endpoint):
    return session.get(
        url=f'{BASE_URL}/{endpoint}',
        timeout=TIMEOUT
    )


def send_post_request(endpoint, payload):
    return session.post(
        url=f'{BASE_URL}/{endpoint}',
        json=payload,
        timeout=TIMEOUT
    )


def validate_api(event):
    if 'api' not in event['input']:
        return {
            'errors': '"api" is a required field in the "input" payload'
        }

    api = event['input']['api']

    if type(api) is not dict:
        return {
            'errors': '"api" must be a dictionary containing "method" and "endpoint"'
        }

    api['endpoint'] = api['endpoint'].lstrip('/')

    return validate(api, API_SCHEMA)


def validate_payload(event):
    method = event['input']['api']['method']
    endpoint = event['input']['api']['endpoint']
    payload = event['input']['payload']
    validated_input = payload

    if endpoint == 'txt2img':
        validated_input = validate(payload, TXT2IMG_SCHEMA)
    elif endpoint == 'img2img':
        validated_input = validate(payload, IMG2IMG_SCHEMA)
    elif endpoint == 'options' and method == 'POST':
        validated_input = validate(payload, OPTIONS_SCHEMA)

    return endpoint, event['input']['api']['method'], validated_input



def pic_replace(payload):
  # make auto sam by prompt
  sam_options = payload[0]
  response = send_post_request('sam/sam-predict', sam_options)
  result = response.json()
  mask_string = result['masks'][2]

  # draw in mask
  input_image = payload[0]['input_image']
  img2img_inpaint_options = payload[1]  
  img2img_inpaint_options['mask'] = mask_string
  img2img_inpaint_options['init_images'] = [input_image]
  response2 = send_post_request('sdapi/v1/img2img', img2img_inpaint_options)

  return response2


# ---------------------------------------------------------------------------- #
#                                RunPod Handler                                #
# ---------------------------------------------------------------------------- #
def handler(event):
    validated_api = validate_api(event)

    if 'errors' in validated_api:
        return {
            'error': validated_api['errors']
        }

    endpoint, method, validated_input = validate_payload(event)

    if 'errors' in validated_input:
        return {
            'error': validated_input['errors']
        }

    if 'validated_input' in validated_input:
        payload = validated_input['validated_input']
    else:
        payload = validated_input

    try:
        logger.log(f'Sending {method} request to: /{endpoint}')

        if method == 'GET':
            response = send_get_request(endpoint)
        elif method == 'POST':
            response = send_post_request(endpoint, payload)
        elif method == 'pic_replace':
            response = pic_replace(payload)

    except Exception as e:
        logger.log(e, 'INFO')
        return {
            'error': str(e)
        }

    return response.json()


if __name__ == "__main__":
    wait_for_service(url='http://127.0.0.1:3000/sdapi/v1/sd-models')
    logger.log('Automatic1111 API is ready', 'INFO')
    logger.log('Starting RunPod Serverless...', 'INFO')
    runpod.serverless.start(
        {
            'handler': handler
        }
    )
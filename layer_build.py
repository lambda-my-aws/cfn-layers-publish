#!/usr/bin/env python
"""
Script to generate the CFN template for the library into a Lambda Layer from within the CodeBuild of the Layer Build.
"""
import re
import boto3
from datetime import datetime as dt
from os import environ
from json import dumps
from argparse import ArgumentParser
from ozone.templates.awslambdalayer import template

def get_artifact_location():
    """
    Retrieves the Destination bucket and path of the Layer from CodeBuild within the job
    """
    job_id = environ['CODEBUILD_BUILD_ID']
    client = boto3.client('codebuild')
    build_info = client.batch_get_builds(
        ids=[job_id]
    )['builds'][0]
    pattern = re.compile(r'arn:aws:s3:::')
    location = pattern.sub('', build_info['artifacts']['location'])
    bucket = location.split('/')[0]
    key = location.split('/', 1)[-1]
    return (bucket, key)


if __name__ == '__main__':
    PARSER = ArgumentParser('Codebuild CFN template and params build')
    PARSER.add_argument(
        '--path', help='Path where CFN files are created', required=True
    )
    ARGS = PARSER.parse_args()
    BUILD_DEST = get_artifact_location()
    LAYER_NAME = environ['LAYER_NAME']
    PACKAGE_NAME = environ['PACKAGE_NAME']
    PY_VERSION = environ['PY_VERSION']
    DATE = dt.utcnow().isoformat()
    TPL = template(make_public=True, Runtimes=[PY_VERSION], Bucket=BUILD_DEST[0], Key=BUILD_DEST[1])
    TPL.set_metadata({
        'Version': DATE,
        'BuildBy': 'CodePipeline/CodeBuild',
        'LayerName': LAYER_NAME,
        'PackageName': PACKAGE_NAME
    })
    TPL.set_description(f'Template for {LAYER_NAME} - {DATE}')
    with open(f'{ARGS.path}/layer_template.yml', 'w') as fd:
        fd.write(TPL.to_yaml())
    template_config = {
        'Parameters':
        {
            'LayerName': LAYER_NAME
        },
        'Tags': {
            'Name': LAYER_NAME
        }
    }
    with open(f'{ARGS.path}/layer_config.json', 'w') as fd:
        fd.write(dumps(template_config))

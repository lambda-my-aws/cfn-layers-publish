#!/usr/bin/env python

import json
from argparse import ArgumentParser

PARSER = ArgumentParser('Create CFN Stack parameters file')
PARSER.add_argument('--owner', required=True)
PARSER.add_argument('--repo', required=True)
PARSER.add_argument('--branch', required=True)
PARSER.add_argument('--token', required=True)
PARSER.add_argument('--layer-name', required=True)


ARGS = PARSER.parse_args()

PARAMS = [
    {
        "ParameterKey": "LayerName",
        "ParameterValue": ARGS.layer_name
    },
    {
        "ParameterKey": "GitHubOwner",
        "ParameterValue": ARGS.owner
    },
    {
        "ParameterKey": "BranchName",
        "ParameterValue": ARGS.branch
    },
    {
        "ParameterKey": "ArtifactsBucketName",
        "ParameterValue": ARGS.layer_name.lower()
    },
    {
        "ParameterKey": "GitHubRepo",
        "ParameterValue": ARGS.repo
    },
    {
        "ParameterKey": "GitHubOAuthToken",
        "ParameterValue": ARGS.token
    }
]

with open('layer_params.json', 'w') as fd:
    fd.write(json.dumps(PARAMS, indent=4))

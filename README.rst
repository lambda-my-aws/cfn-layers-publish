cfn-layers-publish
==================

Very simple pieces of code that can be reused for any python library in pip to generate an AWS Lambda Layer


How-to use
----------

Simply copy the files `buildspec.yml`, `layer_build.py` into your repository. You can simply run

.. code-block:: bash

   make install


Which will prompt for the path to your repository. You will have to version these files in your repository for codebuild to work.

.. code-block:: bash

   make help

   venv: Creates venv
   venv-install: Force venv install
   parmeters: Create stack parameters
   create-parameters: Force creation of parameters for CFN
   clean-parameters: Delete parameters
   install: Copies files to your repository
   create: create CFN stack
   delete: Delete the CFN stack
   validate: Validate the CFN template
   events: describe events for the stack
   watch: watch describe-events


.. code-block:: bash

   make validate

   {
       "Parameters": [
	   {
	       "ParameterKey": "LayerName",
	       "NoEcho": false
	   },
	   {
	       "ParameterKey": "GitHubOwner",
	       "NoEcho": false
	   },
	   {
	       "ParameterKey": "BranchName",
	       "DefaultValue": "master",
	       "NoEcho": false
	   },
	   {
	       "ParameterKey": "ArtifactsBucketName",
	       "NoEcho": false
	   },
	   {
	       "ParameterKey": "GitHubRepo",
	       "NoEcho": false
	   },
	   {
	       "ParameterKey": "GitHubOAuthToken",
	       "NoEcho": true
	   }
       ],
       "Description": "Pipeline to release Lambda layers publicly when new release is created",
       "Capabilities": [
	   "CAPABILITY_IAM"
       ],
       "CapabilitiesReason": "The following resource(s) require capabilities: [AWS::IAM::Role]"
   }


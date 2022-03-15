# aws_mfa
Automate MFA Token access to the AWS CLI

# Author: Mark Bixler, modified by Mitchell Ciupak

# Date: 20211102

## Usage:
    user@pc:~/.aws$ chmod u+x awscli_mfa.sh
    user@pc:~/.aws$ ./awscli_mfa.sh

## Source: 
* https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/
* https://bixlerm.medium.com/aws-mfa-bash-script-f59e2b33093c
* https://levelup.gitconnected.com/aws-cli-automation-for-temporary-mfa-credentials-31853b1a8692

## Details:
* all files are stored at ~/.aws/
* I reccomend creating an alias in your bashrc file to be able to run this script globally
* DOES NOT support multiple aws account user profiles

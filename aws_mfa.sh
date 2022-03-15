set -e
########################################################################################
## Name: aws_mfa.sh
## Author: Mark Bixler, modified by Mitchell Ciupak
## Date: 20211102
## Usage:
##  user@pc:~/.aws$ chmod u+x awscli_mfa.sh
##  user@pc:~/.aws$ ./awscli_mfa.sh
## Source: 
## * https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/
## * https://bixlerm.medium.com/aws-mfa-bash-script-f59e2b33093c
## * https://levelup.gitconnected.com/aws-cli-automation-for-temporary-mfa-credentials-31853b1a8692
## Details:
## * all files are stored at ~/.aws/
## * I reccomend creating an alias in your bashrc file to be able to run this script globally
## * DOES NOT support multiple aws account user profiles
########################################################################################

# RESET ENV
reset_env() {
    ## Define Path
    INIT_AWS_DIR=~/.aws
    AWS_DIR_FILE=$INIT_AWS_DIR/awsdir
    if [ ! -f "$AWS_DIR_FILE" ]; then
        read -p "Enter the path to your .aws dir (no ending /): " AWS_DIR
        echo $AWS_DIR>$AWS_DIR_FILE
    fi
    AWS_DIR=$(<$AWS_DIR_FILE)

    ## Create Filename Variables
    MFA_DEVICE_FILE=$AWS_DIR/mfadevice

	# Unset ENV Vars
	unset AWS_ACCESS_KEY_ID
	unset AWS_SECRET_ACCESS_KEY
	unset AWS_SESSION_TOKEN
}
reset_env

# MFA DEVICE ARN
get_mfa_device_arn () {

    if [ -f $MFA_DEVICE_FILE ] && [ -s $MFA_DEVICE_FILE ]; then
        mfaarn=$(<$MFA_DEVICE_FILE)
        echo "Your MFA Device ARN is $mfaarn" 
    else
        read -p "Enter MFA Device ARN: " mfaarn

        # Test String
        if [[ $mfaarn != *"arn"* ]]; then
            echo -e '\033[1m-- MFA DEVICE ARN: INPUT ERROR --\033[0m'
            echo "This is not a full arn. Please input your MFA Device ARN like arn:aws-[ACCOUNT_TYPE]:iam::123456789876:mfa/[USERNAME]"
            echo -e '\033[1m-- MFA DEVICE ARN: DESCRIPTION --\033[0m'
            echo 'ARN can be found in the AWS Console by navigating to IAM->Users->[YOUR USERNAME]->Security credentials->Sign-in credentials->Assigned MFA device or by following a link like (https://console.amazonaws.com/iam/home?#/users/[YOUR USERNAME]?section=security_credentials).'
            get_mfa_device_arn
        fi

        ## Input ARN into File
        echo $mfaarn>$MFA_DEVICE_FILE
    fi
}
get_mfa_device_arn

# MFA TOKEN CODE
get_mfa_token () {
    ## Prompt for MFA
    read -p "Enter MFA Token Code: " mfacode
}
get_mfa_token

# MFA AWS TOKENS
get_session_token () {

    value=$(aws sts get-session-token --serial-number $mfaarn --token-code $mfacode)

    ## Input Error Catch
    if [[ $value == *"An error occurred (InvalidClientTokenId) when calling the GetSessionToken operation: The security token included in the request is invalid."* ]]; then
        echo -e '\033[1m-- MFA AWS TOKENS: AWS CONFIGURE LIST --\033[0m'
        aws configure list
        echo -e '\033[1m-- MFA AWS TOKENS: AWS CONFIGURE --\033[0m'
        echo "If credentials are not present, please run 'aws configure' to set the aws account you wish to create a connection with."
        echo "Note: please ensure that the 'Default output format' is [json]."
        echo "Note: profiles are not supported in this script at this time. Add a --profile [Your Profile Name] to line 79 of this script if needed."
        get_session_token
    fi
    ## Input Error Catch
    if [[ $value == *"command not found"* ]]; then
        echo -e '\033[1m-- MFA AWS TOKENS: AWS CLI --\033[0m'
        echo "If the command 'which aws' does not return a binary file, please ensure the aws cli is installed on your device."
        get_session_token
    fi

}
get_session_token

# PREPARE CREDS
prep_credentials () {

    access_key_id=$(echo $value | awk '{print $5}' | tr -d '"' | tr -d ',')
    secret_access_key=$(echo $value | awk '{print $7}' | tr -d '"' | tr -d ',')
    session_token=$(echo $value | awk '{print $9}' | tr -d '"' | tr -d ',')

    echo
	echo 'Please paste the commands below into your terminal to establish you connection to aws!'
	echo
	echo -e '\033[1m-- ENV COMMANDS FOR MFA AWS  --\033[0m'
    echo "unset AWS_ACCESS_KEY_ID"
    echo "unset AWS_SECRET_ACCESS_KEY"
    echo "unset AWS_SESSION_TOKEN"
    echo "export AWS_ACCESS_KEY_ID=${access_key_id}"
    echo "export AWS_SECRET_ACCESS_KEY=$secret_access_key"
    echo "export AWS_SESSION_TOKEN=$session_token"

}
prep_credentials

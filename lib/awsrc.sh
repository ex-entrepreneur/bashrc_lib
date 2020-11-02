function get_imdsv2_session_token()
{
    curl -m 5 -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 3600"
}

function set_imdsv2_session_token()
{
    #    export IMDSV2_SESSION_TOKEN=${IMDSV2_SESSION_TOKEN}:`get_session_token`
    if [ -z "${IMDSV2_SESSION_TOKEN}" ]; then
	export IMDSV2_SESSION_TOKEN=`get_session_token`
    fi
}

function clear_aws_creds()
{
    export AWS_ACCESS_KEY_ID=
    export AWS_SECRET_ACCESS_KEY=
    export AWS_SESSION_TOKEN=    
}

function set_aws_creds_from_instance_role()
{
    set_imdsv2_session_token
    
    json_res=`curl -m 5 -H "X-aws-ec2-metadata-token: $IMDSV2_SESSION_TOKEN" http://169.254.169.254/latest/meta-data/iam/info`
    role_name=`echo $json_res | jq -r .InstanceProfileArn | cut -d"/" -f2`
    json_res=`curl -H "X-aws-ec2-metadata-token: $IMDSV2_SESSION_TOKEN" "http://169.254.169.254/latest/meta-data/iam/security-credentials/${role_name}"`
    export AWS_ACCESS_KEY_ID=`jq -nr --argjson foo "$json_res" '$foo.AccessKeyId'`
    export AWS_SECRET_ACCESS_KEY=`jq -nr --argjson foo "$json_res" '$foo.SecretAccessKey'`
    export AWS_SESSION_TOKEN=`jq -nr --argjson foo "$json_res" '$foo.Token'`    
}

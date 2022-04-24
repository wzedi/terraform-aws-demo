#!/bin/bash

sudo yum update -y
sudo amazon-linux-extras install nginx1 -y 
sudo systemctl enable nginx
sudo systemctl start nginx

INSTANCE_ID=$(TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` && curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
cat << EOF > /tmp/cloudwatch-egent-config.json
{
    "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/messages",
                "log_group_name": "messages",
                "log_stream_name": "$${INSTANCE_ID}",
                "timezone": "UTC"
              }
            ]
          }
        },
        "log_stream_name": "$${INSTANCE_ID}",
        "force_flush_interval" : 15
      }
}
EOF

sudo yum install -y amazon-cloudwatch-agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/tmp/cloudwatch-egent-config.json

sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
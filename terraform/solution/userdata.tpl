#!/bin/bash

sudo yum update -y
sudo amazon-linux-extras install nginx1 -y 
sudo systemctl enable nginx
sudo systemctl start nginx


cat << EOF > /tmp/cloudwatch-egent-config.json
{
    "logs": {
        "logs_collected": {
          "files": {
            "collect_list": [
              {
                "file_path": "/var/log/messages",
                "log_group_name": "messages",
                "log_stream_name": "$${aws:InstanceId}",
                "timezone": "UTC"
              }
            ]
          }
        },
        "log_stream_name": "$${aws:InstanceId}",
        "force_flush_interval" : 15
      }
}
EOF

sudo yum install -y amazon-cloudwatch-agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/tmp/cloudwatch-egent-config.json

sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
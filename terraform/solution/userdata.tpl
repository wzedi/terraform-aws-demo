#!/bin/bash

sudo yum update -y
sudo amazon-linux-extras install nginx1 -y 

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
              },
              {
                "file_path": "/var/log/nginx/error.log",
                "log_group_name": "nginx/error.log",
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

cat << EOF > /etc/nginx/default.d/php-mysql.conf
location ~ \.php$ {
        try_files \$uri =404;

        include fastcgi_params;
        fastcgi_param  SCRIPT_FILENAME    \$document_root\$fastcgi_script_name;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_index index.php;
        # fastcgi_intercept_errors on;
        # fastcgi_keep_conn on;
        # fastcgi_read_timeout 300;

        # fastcgi_pass   127.0.0.1:9000;
        fastcgi_pass  unix:/var/run/php-fpm/www.sock;
        #for ubuntu unix:/var/run/php/php8.0-fpm.sock;

        ##
        # FastCGI cache config
        ##

        # fastcgi_cache_path /var/cache/nginx levels=1:2 keys_zone=WORDPRESS:10m max_size=1000m inactive=60m;
        # fastcgi_cache_key \$scheme\$host\$request_uri\$request_method;
        # fastcgi_cache_use_stale updating error timeout invalid_header http_500;

        fastcgi_cache_valid any 30m;
}
EOF

cat << EOF > /usr/share/nginx/html/mysql-test.php
<?php
\$servername = "${RDS_ENDPOINT}";
\$username = "${DB_USERNAME}";
// Get the db secret using AWS CLI - better to use SDK but for emo purposes I think this suffices
\$password = shell_exec('aws secretsmanager get-secret-value --region ${AWS_REGION} --secret-id ${SECRET_ID} --query "SecretString" | tr -d \'"\'');

// Create connection
\$conn = new mysqli(\$servername, \$username, \$password);

// Check connection
if (\$conn->connect_error) {
  die("Connection failed: " . \$conn->connect_error);
}
echo "Connected successfully";
?>
EOF

sudo yum install -y amazon-cloudwatch-agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/tmp/cloudwatch-egent-config.json

sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

sudo amazon-linux-extras enable php8.0
sudo yum clean metadata
sudo yum install -y php-cli php-pdo php-fpm php-mysqlnd
sudo systemctl enable php-fpm
sudo systemctl start php-fpm

sudo systemctl enable nginx
sudo systemctl start nginx

sudo apt update -y

status="$(dpkg-query -W --showformat='${db:Status-Status}' "apache2" 2>&1)"
if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
  sudo apt install apache2
fi
/etc/init.d/apache2 start
systemctl enable apache2



timestamp=$(date '+%d%m%Y-%H%M%S')
name=chinmay
bucketName=upgrad-chinmay
tar -zcvf "/tmp/${name}-httpd-logs-${timestamp}.tar" /var/log/apache2/
aws s3 \
cp /tmp/${name}-httpd-logs-${timestamp}.tar \
s3://${bucketName}/${name}-httpd-logs-${timestamp}.tar

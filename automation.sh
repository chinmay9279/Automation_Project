sudo apt update -y

status="$(dpkg-query -W --showformat='${db:Status-Status}' "apache2" 2>&1)"
if [ ! $? = 0 ] || [ ! "$status" = installed ]; then
  sudo apt install apache2
fi
/etc/init.d/apache2 start
systemctl enable apache2

if [[ ! -e /etc/cron.d/automation ]]; then
        echo "0 10 * * * /root/Automation_Project/automation.sh > /dev/null" > /etc/cron.d/automation
fi

timestamp=$(date '+%d%m%Y-%H%M%S')
name=chinmay
bucketName=upgrad-chinmay
tar -zcvf "/tmp/${name}-httpd-logs-${timestamp}.tar" /var/log/apache2/
aws s3 \
cp /tmp/${name}-httpd-logs-${timestamp}.tar \
s3://${bucketName}/${name}-httpd-logs-${timestamp}.tar

fileName=$(ls -l /tmp/${name}-httpd-logs-${timestamp}* | awk '{print $NF}')
fileType=$(echo "${fileName#*.}")
fileSize=$(ls -l /tmp/${name}-httpd-logs-${timestamp}.tar --block-size=K | awk '{print $5}')

if [[ ! -e /var/www/html/inventory.html ]]; then
        echo "Log Type          Time Created            Type            Size" >> /var/www/html/inventory.html
fi
echo "httpd-logs                ${timestamp}            ${fileType}             ${fileSize}" >> /var/www/html/inventory.html

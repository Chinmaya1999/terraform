#!/bin/bash
yum update -y
yum install -y httpd

# Get the instance ID using the instance metadata
echo "Attempting to get instance ID..."
# Wait for metadata service to be available and retry
for i in {1..10}; do
  INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null)
  if [ $? -eq 0 ] && [ -n "$INSTANCE_ID" ]; then
    echo "Instance ID retrieved: $INSTANCE_ID"
    break
  else
    echo "Attempt $i: Failed to get instance ID, retrying in 5 seconds..."
    sleep 5
  fi
done

# Fallback if still not available
if [ -z "$INSTANCE_ID" ]; then
  INSTANCE_ID="Unknown"
  echo "Failed to get instance ID after retries, using fallback: $INSTANCE_ID"
fi

# Install the AWS CLI
yum install -y awscli

# Download the images from S3 bucket
#aws s3 cp s3://myterraformprojectbucket2023/project.webp /var/www/html/project.png --acl public-read

# Create a simple HTML file with the portfolio content and display the images
echo "<!DOCTYPE html>" > /var/www/html/index.html
echo "<html>" >> /var/www/html/index.html
echo "<head>" >> /var/www/html/index.html
echo "  <title>My Portfolio</title>" >> /var/www/html/index.html
echo "  <style>" >> /var/www/html/index.html
echo "    @keyframes colorChange {" >> /var/www/html/index.html
echo "      0% { color: red; }" >> /var/www/html/index.html
echo "      50% { color: green; }" >> /var/www/html/index.html
echo "      100% { color: blue; }" >> /var/www/html/index.html
echo "    }" >> /var/www/html/index.html
echo "    h1 {" >> /var/www/html/index.html
echo "      animation: colorChange 2s infinite;" >> /var/www/html/index.html
echo "    }" >> /var/www/html/index.html
echo "  </style>" >> /var/www/html/index.html
echo "</head>" >> /var/www/html/index.html
echo "<body>" >> /var/www/html/index.html
echo "  <h1>Terraform Project Server 1</h1>" >> /var/www/html/index.html
echo "  <h2>Instance ID: <span style=\"color:green\">$INSTANCE_ID</span></h2>" >> /var/www/html/index.html
echo "  <p>Welcome to Reyaz DnA Course</p>" >> /var/www/html/index.html
echo "</body>" >> /var/www/html/index.html
echo "</html>" >> /var/www/html/index.html

# Start Apache and enable it on boot
systemctl start httpd
systemctl enable httpd

# Ensure Apache is running
systemctl status httpd
netstat -tlnp | grep :80
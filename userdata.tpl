        #!/bin/bash
        yum update -y
        yum install httpd -y
        systemctl start httpd
        systemctl enable httpd
        echo "<html><body><h1>Level Up Red Team!</h1></body></html>" > /var/www/html/index.html
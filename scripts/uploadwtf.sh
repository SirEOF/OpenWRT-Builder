lftp -e 'set ftp:passive-mode false; set net:timeout 10; mirror -R '/home/ubuntu/Sources/stable'/bin/ /home/tiagoperalta/domains/ec2-openwrt.tiagoperalta.pt/public_html/12.09.1-EC2/' -u tiagoperalta,Maverick1! ec2-openwrt.tiagoperalta.pt
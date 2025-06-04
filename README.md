# 🐧 OpenSUSE XFCE + xrdp through Windows Instance Setup on AWS Lightsail (FREE TIER ELIGIBLE)

This tutorial is meant as a solution to use OPENSUSE on a AWS Lightsale instance while keeping everything contained in the AWS environment.
Steps to set it up manually or via automation.

## Manual Setup

1. Create a Lightsail Instance

   - Choose Linux/Unix
   - Select Operating System (OS) only
   - Select OpenSUSE
   - Chose desired plan
   - Create
  
2. Update System

![image](https://github.com/user-attachments/assets/2dfb1a5e-4ece-44d7-818a-558d19ae4e23)

sudo zypper refresh

Fetching latest packages information from configured repositories

![image](https://github.com/user-attachments/assets/907174a5-a4ed-4d67-a345-632f8e420a09)

sudo zypper update -y

Upgrading preinstalled packages to their latest version

3. Installing GUI and RDP

![image](https://github.com/user-attachments/assets/66ed1a43-790e-4d2f-a8ab-1c326dfeb673)

sudo zypper install -t pattern xfce -y

XFCE is a lightweight OpenSUSE GUI. Recommended for using with low ram instances. The one in the tutorial is a Free Tier 2gb ram one.

![image](https://github.com/user-attachments/assets/989af673-3d19-4e8d-92bd-5dccbbcb8e9e)

sudo zypper install xrdp tigervnc-x11vnc -y

We are going to install both apps. XRDP being used to connect through RDP to Windows. This is not a desktop environment and not a display server. So running this alone won't give us a GUI.
That's why we also install tigervnc.

4. Session and certificate

![image](https://github.com/user-attachments/assets/0c629066-9838-4bce-b9bc-ea74e60a4e42)

echo "exec startxfce4" > ~/.xsession
chmod +x ~/.xsession
chmod 755 ~
chmod 644 ~/.xsession

Next we are configuring the session file so XRDP knows which desktop environment to launch. Also setting correct permissions to avoid sessions errors.

![image](https://github.com/user-attachments/assets/02b2c55a-aaa0-46d9-8ebc-1a78fee01d6c)

(Optional) Adding certificate to enhance security especially over shared or public networks. 

sudo openssl req -x509 -nodes -newkey rsa:2048 \
  -keyout /etc/xrdp/key.pem \
  -out /etc/xrdp/cert.pem \
  -days 365

5. Set up Fallback

![image](https://github.com/user-attachments/assets/17032413-e4e6-4372-bab4-b638a21202c8)

sudo bash -c 'cat > /etc/xrdp/startwm.sh <<EOF
#!/bin/sh
if [ -r ~/.xsession ]; then
  . ~/.xsession
else
  exec startxfce4
fi
EOF'
sudo chmod +x /etc/xrdp/startwm.sh

7. Enable and start xrdp

![image](https://github.com/user-attachments/assets/746e48e5-d9fa-4adf-a446-949809762261)

sudo systemctl enable xrdp

Enable XRDP then run:

![image](https://github.com/user-attachments/assets/7980459d-a5b2-4aee-92dd-d6641b25c950)

sudo systemctl start xrdp

Now we can check the session status (CTRL+C to exit).

![image](https://github.com/user-attachments/assets/fca5c558-aca3-461e-8bce-4c47b6ed032d)

sudo systemctl status xrdp 

8. Set a password for your user

![image](https://github.com/user-attachments/assets/dd438eb6-01c2-4555-a205-c27763abbb8d)

sudo passwd $USER

9. Assign a Static IP to your OPENSUSE Instance

![image](https://github.com/user-attachments/assets/c409602d-ca0a-42e6-9276-74847977f1c5)


Go in the Networking Tab, click on Create static IP then assign it to your linux Instance. 
Assigning a static IP is mandatory so it stays consistent each time you want to use your VM and doesnt restart each time.
!! BE CAREFUL. If you want to use AWS for FREE make sure you dettach the static ip once you stop your instance. Leaveing it dettached can lead to unexpected charges.

11. Add Port in Lightsail

Opening port 3389 is necessary to allow RDP connections. Even if XRDP is installed and running, Lightsail firewall blocks RDP until this port is open.

![image](https://github.com/user-attachments/assets/4b785de0-c30c-4498-b0f8-297e1e50e290)

Click on your Linux instance in Lightsail, look for Networking -> IPv6 firewall
Click on Add rule -> Custom -> TCP -> 3389 (In port or range text field)
Create

This will open the port for both IPv6 and IPv4





# 🐧 OpenSUSE XFCE + xrdp through Windows Instance Setup on AWS Lightsail (FREE TIER ELIGIBLE)

This tutorial is meant as a solution to use OPENSUSE on an AWS Lightsail instance while keeping everything contained within the AWS environment.

It will help you quickly set up a lightweight **OpenSUSE XFCE desktop environment** on an AWS Lightsail instance — accessible remotely via **RDP (Remote Desktop Protocol)** from your Windows machine. Perfect for Linux enthusiasts, developers, or anyone wanting a full Linux GUI in the cloud without a complex setup being necessary.

## Why Use This?

- **Simple & Cost-Effective:** Utilizes AWS Lightsail which is cost effective and affordable.
- **Remote Desktop Ready:** Access your OpenSUSE Linux desktop easily from a Windows instance using RDP.
- **Automation Included:** Scripts automate installing XFCE, xrdp, and configuring your instance for a quick set-up.
- **AWS-Contained:** Everything can be done on the AWS platform, without needing access to any third-party software.
- **Great for Learning, Development, and Testing:** Spin up a Linux desktop quickly without dedicated hardware.

## Requirements

- AWS Account with Lightsail access
- Basic familiarity with AWS Lightsail console
- Basic Linux familiarity

## Manual Setup

1. Create a Lightsail Instance

![image](https://github.com/user-attachments/assets/cc81a404-12a9-4c31-b904-9d1a7c624678)

   - Choose Linux/Unix  
   - Select Operating System (OS) only  
   - Select OpenSUSE  
   - Choose desired plan  
   - Create
  
3. Update System

![image](https://github.com/user-attachments/assets/2dfb1a5e-4ece-44d7-818a-558d19ae4e23)

```bash
sudo zypper refresh
```

Fetching the latest package information from configured repositories.

![image](https://github.com/user-attachments/assets/907174a5-a4ed-4d67-a345-632f8e420a09)

```bash
sudo zypper update -y
```

Upgrading preinstalled packages to their latest versions.

3. Installing GUI and RDP

![image](https://github.com/user-attachments/assets/66ed1a43-790e-4d2f-a8ab-1c326dfeb673)

```bash
sudo zypper install -t pattern xfce -y
```

XFCE is a lightweight OpenSUSE GUI, recommended for low RAM instances. The instance in the tutorial is a Free Tier 2GB RAM one.

![image](https://github.com/user-attachments/assets/989af673-3d19-4e8d-92bd-5dccbbcb8e9e)

```bash
sudo zypper install xrdp tigervnc-x11vnc -y
```

We are installing both apps. XRDP is used to connect through RDP from Windows. XRDP alone is not a desktop environment nor a display server. It acts as a bridge to a desktop session. That’s why we also install tigervnc-x11vnc, which provides the actual VNC backend desktop session that XRDP connects to.

4. Session and certificate

![image](https://github.com/user-attachments/assets/0c629066-9838-4bce-b9bc-ea74e60a4e42)

```bash
echo "exec startxfce4" > ~/.xsession
chmod +x ~/.xsession
chmod 755 ~
chmod 644 ~/.xsession
```

We configure the session file so XRDP knows which desktop environment to launch. Also, set the correct permissions to avoid session errors.

![image](https://github.com/user-attachments/assets/02b2c55a-aaa0-46d9-8ebc-1a78fee01d6c)

(Optional) Add a certificate to enhance security, especially over shared or public networks.

```bash
sudo openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/xrdp/key.pem -out /etc/xrdp/cert.pem -days 365
```

5. Set up Fallback

![image](https://github.com/user-attachments/assets/17032413-e4e6-4372-bab4-b638a21202c8)

```bash
sudo bash -c 'cat > /etc/xrdp/startwm.sh <<EOF
#!/bin/sh
if [ -r ~/.xsession ]; then
  . ~/.xsession
else
  exec startxfce4
fi
EOF'
sudo chmod +x /etc/xrdp/startwm.sh
```

6. Enable and start xrdp

![image](https://github.com/user-attachments/assets/746e48e5-d9fa-4adf-a446-949809762261)

```bash
sudo systemctl enable xrdp
```

Enable XRDP, then run:

![image](https://github.com/user-attachments/assets/7980459d-a5b2-4aee-92dd-d6641b25c950)

```bash
sudo systemctl start xrdp
```

Now, check the session status (CTRL+C to exit).

![image](https://github.com/user-attachments/assets/fca5c558-aca3-461e-8bce-4c47b6ed032d)

```bash
sudo systemctl status xrdp 
```

7. Set a password for your user

![image](https://github.com/user-attachments/assets/dd438eb6-01c2-4555-a205-c27763abbb8d)

```bash
sudo passwd $USER
```

8. Assign a Static IP to your OPENSUSE Instance

![image](https://github.com/user-attachments/assets/c409602d-ca0a-42e6-9276-74847977f1c5)

Go to the Networking tab, click **Create static IP**, then assign it to your Linux instance.  
Assigning a static IP is mandatory so the IP stays consistent each time you want to use your VM and doesn't change after restarts.  
‼️ BE CAREFUL: To avoid unexpected charges, do NOT leave static IPs detached and unused.

9. Add Port in Lightsail

Opening port **3389** is necessary to allow RDP connections. Even if XRDP is installed and running, Lightsail's firewall blocks RDP until this port is opened.

![image](https://github.com/user-attachments/assets/4b785de0-c30c-4498-b0f8-297e1e50e290)

Click on your Linux instance in Lightsail, look for **Networking → IPv6 firewall**.  
Click **Add rule → Custom → TCP → 3389** (In the port or range text field).  
Create the rule.

This will open the port for both IPv6 and IPv4.

10. Debugging

```bash
sudo tail -f /var/log/xrdp.log
sudo tail -f /var/log/xrdp-sesman.log
```

- These commands display connection attempts, session creation or rejection messages, and errors if the session fails to launch.  
- They also show whether the desktop environment actually launched and help diagnose VNC backend issues.

11. Creating the Windows Instance

![image](https://github.com/user-attachments/assets/bd6e2050-3dfb-4ac1-a789-4dd5f4376652)

In Lightsail, go to **Create Instance**, select it, then choose **Microsoft Windows**.  
Select the desired plan (the one used here was the free tier with 2GB RAM).  
Leave all options as default and give it your desired name.  
Press **Create**.  
Now you can start it and press **Connect**.

12. RDP from Windows to OpenSUSE

Once inside the Windows instance, press **Windows + R**, type:

```
mstsc
```

and hit enter.  
This opens the RDP client.

![image](https://github.com/user-attachments/assets/209ece69-4094-4c12-8ff3-7aa76d48dc28)

Next, copy the static IP from your Linux instance (**Networking** tab), and paste it into your remote clipboard in the Windows instance.  
Then paste it again into your RDP client and press **Connect**.

![image](https://github.com/user-attachments/assets/57d9ed26-fd6b-4736-a70c-635742b10b8f)

Press **Yes**.

Enter the username and password you set on your Linux instance.  

You should now see your XFCE desktop running inside OpenSUSE 🎉

![image](https://github.com/user-attachments/assets/d48e4cd7-08fb-42cf-9d4d-8e42f9c486d0)

---

I have provided a script to automate this entire process here:  
📜 [View setup-xrdp.sh on GitHub](https://github.com/asawpCode/opensuse-cloud-gui-aws-only/blob/main/setup-xrdp.sh)

All you have to do is run this in your Linux terminal. You will be prompted for a few things.

```bash
curl -O https://raw.githubusercontent.com/asawpCode/opensuse-cloud-gui-aws-only/refs/heads/main/setup-xrdp.sh
chmod +x setup-xrdp.sh
./setup-xrdp.sh
```

‼️ When You’re Done:

Stop your instances
Detach (or release) static IPs
Delete unused firewall rules
Remove unneeded snapshots

## Contributing

Contributions, suggestions, and feedback are welcome! Please open issues or pull requests.

## Connect & Support

If you find this project useful or have questions, feel free to reach out!

#!/bin/bash
echo "🛠 Updating system..."
sudo zypper refresh
sudo zypper update -y

echo "Installing XFCE desktop and TigerVNC..."
sudo zypper install -t pattern xfce 
sudo zypper install xrdp -y
sudo zypper install xrdp tigervnc-x11vnc -y
echo "Configuring .xsession for XFCE..."
echo "exec startxfce4" > ~/.xsession 
chmod +x ~/.xsession
echo "Setting permissions..."
chmod 755 ~
chmod 644 ~/.xsession
echo "Setting user password for RDP login..."
sudo passwd $USER
echo "Enabling and starting xrdp service..."
sudo systemctl enable xrdp
sudo systemctl start xrdp
echo "✅ Done. You can now connect via RDP using:"
hostname -I | awk '{print $1}'
 

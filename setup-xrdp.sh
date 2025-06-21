#!/bin/bash

echo "🛠 Updating system..."
sudo zypper refresh
sudo zypper update -y

echo "Installing XFCE desktop, xrdp, and TigerVNC..."
sudo zypper install -t pattern xfce -y
sudo zypper install xrdp tigervnc -y

echo "Configuring .xsession for XFCE..."
echo "exec startxfce4" > ~/.xsession
chmod +x ~/.xsession

echo "Setting file permissions..."
chmod 755 ~
chmod 644 ~/.xsession

echo "Setting up startwm.sh fallback..."
sudo bash -c 'cat > /etc/xrdp/startwm.sh <<EOF
#!/bin/sh
if [ -r ~/.xsession ]; then
  . ~/.xsession
else
  exec startxfce4
fi
EOF'
sudo chmod +x /etc/xrdp/startwm.sh

echo "Set a password for the current user to enable RDP login:"
sudo passwd "$USER"

echo "Enabling and starting xrdp service..."
sudo systemctl enable xrdp
sudo systemctl start xrdp

PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)
echo "Setup complete. You can now connect via RDP to:"
echo "Static Public IP: $PUBLIC_IP"

#!/bin/bash
echo "🛠 Updating system..."
sudo zypper refresh
sudo zypper update

echo "Installing XFCE desktop and TigerVNC..."
sudo zypper install -t pattern xfce 
sudo zypper install xrdp 
sudo zypper install xrdp tigervnc-x11vnc 
echo "Configuring .xsession for XFCE..."
echo "exec startxfce4" > ~/.xsession 
chmod +x ~/.xsession
echo "Setting permissions..."
chmod 755 ~
chmod 644 ~/.xsession
echo "🛡️ Setting up startwm.sh fallback..."
sudo bash -c 'cat > /etc/xrdp/startwm.sh <<EOF
#!/bin/sh
if [ -r ~/.xsession ]; then
  . ~/.xsession
else
  exec startxfce4
fi
EOF'
sudo chmod +x /etc/xrdp/startwm.sh
echo "Setting user password for RDP login..."
sudo passwd $USER
echo "Enabling and starting xrdp service..."
sudo systemctl enable xrdp
sudo systemctl start xrdp
echo "Done. Connect using Static IP."

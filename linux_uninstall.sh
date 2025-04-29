# Alienvault Off-boarding Script
# Written by Rob Emmerson

# Root user detection
if [ $(echo "$UID") = "0" ]; then
    sudo_cmd=''
else
    sudo_cmd='sudo'
fi

export ARCH=$(uname -m)
if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
    echo "This system is running on an ARM64 architecture, exiting..."
    exit
fi

if [ -f "/usr/bin/alienvault-agent.sh" ]; then
    echo "Perform an uninstall using the Alienvault script..."
    $sudo_cmd alienvault-agent.sh uninstall

    echo "[OS SPECIFIC] Purge Alienvault as it doesn't cleanly uninstall..."
    $sudo_cmd apt-get remove --purge -y alienvault-agent

    echo "Attempting to stop and disable osqueryd incase the script didn't..."
    $sudo_cmd systemctl stop osqueryd
    $sudo_cmd systemctl disable osqueryd

    if [ -f "/lib/systemd/system/osqueryd.service" ]; then
        echo "Removing /lib/systemd/system/osqueryd.service..."
        $sudo_cmd rm -f /lib/systemd/system/osqueryd.service
    fi

    if [ -f "/usr/lib/systemd/system/osqueryd.service" ]; then
        echo "Removing /usr/lib/systemd/system/osqueryd.service..."
        $sudo_cmd rm -f /usr/lib/systemd/system/osqueryd.service
    fi

    if [ -f "/etc/init.d/osqueryd" ]; then
        echo "Removing /etc/init.d/osqueryd..."
        $sudo_cmd rm -f /etc/init.d/osqueryd
    fi

    echo "Running 'systemctl daemon-reload'..."
    $sudo_cmd systemctl daemon-reload
    
    echo "Running 'systemctl reset-failed'..."
    $sudo_cmd systemctl reset-failed

    echo "Tidying up osqueryd files..."
    $sudo_cmd rm -rf /etc/osquery /var/osquery
fi

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
    $sudo_cmd alienvault-agent.sh uninstall

    $sudo_cmd systemctl stop osqueryd
    $sudo_cmd systemctl disable osqueryd

    if [ -f "/lib/systemd/system/osqueryd.service" ]; then
        $sudo_cmd rm -f "/lib/systemd/system/osqueryd.service"
    fi

    if [ -f "/usr/lib/systemd/system/osqueryd.service" ]; then
        $sudo_cmd rm -f "/usr/lib/systemd/system/osqueryd.service"
    fi

    if [ -f "/etc/init.d/osqueryd" ]; then
        $sudo_cmd rm -f "/etc/init.d/osqueryd"
    fi

    $sudo_cmd systemctl daemon-reload
    $sudo_cmd systemctl reset-failed

    $sudo_cmd rm -rf "/etc/osquery"
fi

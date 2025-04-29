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

export FLAGCHECK="/etc/osquery/osquery.flags"
export FLAGDEFAULTCHECK="/etc/osquery/osquery.flags.default"

if [ -f "$FLAGCHECK" ]; then
    $sudo_cmd alienvault-agent.sh uninstall
    $sudo_cmd rm -f "$FLAGDEFAULTCHECK"
    if [ -f "$FLAGCHECK" ]; then
        rm -f "$FLAGCHECK"
    fi
fi

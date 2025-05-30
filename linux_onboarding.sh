# Alienvault On-boarding Script
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
    # Extract HOST_ID from the specified_identifier line
    HOST_ID=$(grep specified_identifier "$FLAGCHECK" | sed 's/--specified_identifier=//')
    echo "Host ID found: $HOST_ID"

    # Check if HOST_ID matches any of the known duplicated IDs
    case "$HOST_ID" in
        00000000-0c8f-4f3d-ba95-86a0afb9d9df|00000000-1261-4734-ba88-6e761309a0c7|00000000-0a70-48d5-baff-7ccbbecbe0f9)
            echo ""
            echo "Re-install required, tidying up..."
            $sudo_cmd alienvault-agent.sh uninstall
            $sudo_cmd rm -f "$FLAGDEFAULTCHECK"
            if [ -f "$FLAGCHECK" ]; then
                rm -f "$FLAGCHECK"
            fi
            ;;
        *)
            echo "Good news - this agent appears to be configured correctly, so no install is required! Please check with Rob Emmerson to confirm!"
            exit
            ;;
    esac
fi

INSTALLTYPE="$( (grep -q '^ID_LIKE=.*fedora' /etc/os-release 2>/dev/null || command -v yum >/dev/null 2>&1 || command -v dnf >/dev/null 2>&1) && echo rpm || echo deb )"
bash -c "$(curl -s 'https://api.agent.alienvault.cloud/osquery-api/eu-west-2/bootstrap?flavor='$INSTALLTYPE)"

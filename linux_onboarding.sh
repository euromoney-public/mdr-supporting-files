#!/bin/bash
# Alienvault On-boarding Script
# Written by Rob Emmerson

# Root user detection
if [ $(echo "$UID") = "0" ]; then
    sudo_cmd=''
else
    sudo_cmd='sudo'
fi

export FLAGCHECK="/etc/osquery/osquery.flags"
export FLAGDEFAULTCHECK="/etc/osquery/osquery.flags.default"

if [ -f "$FLAGCHECK" ]; then
    # Extract HOST_ID from the specified_identifier line
    HOST_ID=$(grep specified_identifier "$FLAGCHECK" | sed 's/--specified_identifier=//')
    echo "Host ID found: $HOST_ID"

    # Check if HOST_ID matches one of the two desired values
    case "$HOST_ID" in
        00000000-0c8f-4f3d-ba95-86a0afb9d9df|00000000-1261-4734-ba88-6e761309a0c7)
            echo ""
            echo "Re-install required, tidying up..."
            $sudo_cmd alienvault-agent.sh uninstall
            $sudo_cmd rm -f "$FLAGDEFAULTCHECK"
            ;;
        *)
            echo "No duplicate ID found, exiting..."
            exit
            ;;
    esac
fi

INSTALLTYPE="$( (grep -q '^ID_LIKE=.*fedora' /etc/os-release 2>/dev/null || command -v yum >/dev/null 2>&1 || command -v dnf >/dev/null 2>&1) && echo rpm || echo deb )"
bash -c "$(curl -s 'https://api.agent.alienvault.cloud/osquery-api/eu-west-2/bootstrap?flavor='$INSTALLTYPE)"

#!/bin/bash
# Free disk space on a GitHub-hosted runner by deleting pre-installed software.
#
# Deleting it is pure disk I/O and, on a runner that already has enough free
# space, only makes the job slower. So nothing is touched unless less than
# MIN_FREE_GB is available.
set -e
shopt -s nullglob

MIN_FREE_GB="${MIN_FREE_GB:-80}"

df -h /

AVAIL_GB="$(df --output=avail -BG / | tail -n1 | tr -dc '0-9')"
if [[ "$AVAIL_GB" -ge "$MIN_FREE_GB" ]]; then
    echo "${AVAIL_GB} GB free, no cleanup needed."
    exit 0
fi
echo "${AVAIL_GB} GB free, removing pre-installed software..."

CANDIDATES=(
    /usr/local/lib/android
    /usr/local/.ghcup /opt/ghc
    /opt/hostedtoolcache
    /usr/share/dotnet /usr/lib/dotnet /home/runner/.dotnet
    /usr/share/swift
    /usr/lib/jvm
    /usr/lib/llvm-*
    /usr/lib/mono
    /usr/local/share/powershell /opt/microsoft
    /usr/local/share/chromium /usr/local/share/chromedriver-linux64 /usr/local/share/edge_driver /usr/local/share/gecko_driver
    /opt/google /usr/lib/firefox
    /opt/az /usr/share/az_*
    /usr/lib/google-cloud-sdk /opt/google-cloud-sdk
    /usr/local/aws-cli /usr/local/aws-sam-cli
    /usr/share/rust /home/runner/.rustup /home/runner/.cargo /home/packer /etc/skel/.rustup /etc/skel/.cargo
    /opt/pipx /opt/pipelinesagent-cache /home/linuxbrew
    /usr/local/n /usr/local/lib/node_modules
    /usr/share/miniconda /usr/local/julia*
    /usr/local/share/vcpkg
    /usr/share/kotlinc /usr/share/gradle* /usr/share/apache-maven* /usr/share/sbt /usr/lib/heroku
    /usr/local/lib/lein /usr/local/graalvm
    /usr/local/bin/minikube /usr/local/bin/kubectl /usr/local/bin/oc /usr/local/bin/helm
    /usr/local/bin/packer /usr/local/bin/terraform /usr/local/bin/pulumi* /usr/local/bin/kustomize
)

# The disk is the bottleneck, but independent trees still delete faster in
# parallel than one after the other.
printf '%s\0' "${CANDIDATES[@]}" | xargs -0 -r -P 8 -n 4 sudo rm -rf &
docker system prune -a -f >/dev/null &

wait
df -h /

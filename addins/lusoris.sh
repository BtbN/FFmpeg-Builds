#!/bin/bash
ARCH=$(uname -m | grep -q "x86" && echo "x86_64" || echo "sbsa")

ffbuild_dockeraddin() {
    if [ "${ARCH}" == "x86_64" ]; then
        to_df 'RUN wget -qO- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | gpg --dearmor -o /tmp/oneapi-archive-keyring.gpg && \
        echo "deb [signed-by=/tmp/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list && \
        apt-get -y update && \
        apt-get -y install --no-install-recommends quilt intel-oneapi-compiler-dpcpp-cpp && \
        apt-get -y clean autoclean && \
        rm -rf /var/lib/apt/lists/*'
        to_df 'ENV PATH="${PATH}:/opt/intel/oneapi/compiler/latest/bin"'
    fi
}

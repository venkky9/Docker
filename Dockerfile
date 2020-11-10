FROM meshuaib/fastlane:latest
ADD file:435d9776fdd3a1834f344fb82e459dbbb67cd50c71ab5e29b719273888d5bb7c in /
RUN /bin/sh -c set -xe          \
    && echo '#!/bin/sh' > /usr/sbin/policy-rc.d         \
    && echo 'exit 101' >> /usr/sbin/policy-rc.d         \
    && chmod +x /usr/sbin/policy-rc.d           \
    && dpkg-divert --local --rename --add /sbin/initctl         \
    && cp -a /usr/sbin/policy-rc.d /sbin/initctl        \
    && sed -i 's/^exit.*/exit 0/' /sbin/initctl                 \
    && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup                 \
    && echo 'DPkg::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' > /etc/apt/apt.conf.d/docker-clean       \
    && echo 'APT::Update::Post-Invoke { "rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true"; };' >> /etc/apt/apt.conf.d/docker-clean       \
    && echo 'Dir::Cache::pkgcache ""; Dir::Cache::srcpkgcache "";' >> /etc/apt/apt.conf.d/docker-clean          \
    && echo 'Acquire::Languages "none";' > /etc/apt/apt.conf.d/docker-no-languages              \
    && echo 'Acquire::GzipIndexes "true"; Acquire::CompressionTypes::Order:: "gz";' > /etc/apt/apt.conf.d/docker-gzip-indexes           \
    && echo 'Apt::AutoRemove::SuggestsImportant "false";' > /etc/apt/apt.conf.d/docker-autoremove-suggests
RUN /bin/sh -c [ -z "$(apt-get indextargets)" ]
RUN /bin/sh -c mkdir -p /run/systemd \
    && echo 'docker' > /run/systemd/container
CMD ["/bin/bash"]
ENV DEBIAN_FRONTEND=noninteractive
RUN /bin/sh -c apt-get update \
    && apt-get upgrade -y
RUN /bin/sh -c apt-get install gcc -y
RUN /bin/sh -c apt-get install make -y
RUN /bin/sh -c apt-get install g++ -y
RUN /bin/sh -c apt-get install build-essential  -y
RUN /bin/sh -c apt-get install ruby ruby-dev gem -y
RUN /bin/sh -c apt-get install libglu1-mesa -y
RUN /bin/sh -c apt-get install openjdk-8-jdk -y
RUN /bin/sh -c apt-get install git -y
RUN /bin/sh -c gem install bundler -NV
RUN /bin/sh -c gem install fastlane -NV
COPY dir:129368cf46ce48d421525a588bff7171af5631726f9a2ab3d0b8395ebf86710f in /downloads
COPY dir:71d610baf7215b40fce26a8907eaac9af9978e75df70c74c23ddd654dc87634d in /flutter-sdk
RUN /bin/sh -c cd /flutter-sdk/android-sdk;       unzip /downloads/android-sdk.zip;       rm /downloads/android-sdk.zip;       mkdir tmp;       mv cmdline-tools tmp/latest;       mv tmp cmdline-tools
RUN /bin/sh -c cd /flutter-sdk;       tar -xvf /downloads/flutter-sdk.tar.xz;       rm /downloads/flutter-sdk.tar.xz
ENV FLUTTER_HOME=/flutter-sdk/flutter
ENV ANDROID_SDK_ROOT=/flutter-sdk/android-sdk
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/flutter-sdk/flutter/bin:/tools:/flutter-sdk/android-sdk/cmdline-tools/latest/bin
RUN /bin/sh -c yes | sdkmanager --licenses
RUN /bin/sh -c sdkmanager 'platforms;android-29' 'build-tools;29.0.3'
RUN /bin/sh -c sdkmanager --update

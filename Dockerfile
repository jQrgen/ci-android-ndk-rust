FROM openjdk:17 


SHELL ["/bin/bash", "-c"]
ENV ANDROID_COMPILE_SDK "30"
ENV ANDROID_BUILD_TOOLS "30.0.2"
ENV ANDROID_SDK_TOOLS "7583922"
ENV ANDROID_HOME /android-sdk-linux
ENV ANDROID_NDK_VERSION r21b
ENV ANDROID_NDK_FOLDER /android-ndk-linux
ENV ANDROID_NDK_ROOT="${ANDROID_NDK_FOLDER}/android-ndk-${ANDROID_NDK_VERSION}"
ENV SDKMANAGER="${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager"
ENV PATH="${PATH}:${ANDROID_HOME}/platform-tools/:/root/.cargo/bin"
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

RUN \
    # disable installation of suggested and recommended packages \
    echo 'APT::Install-Suggests "false";' >> /etc/apt/apt.conf && \
    echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf && \
    apt-get --quiet update --yes && \
    apt-get --quiet install --yes wget tar unzip lib32stdc++6 lib32z1 cmake python3 build-essential libtool automake ninja-build curl xxd ruby ruby-dev && \
    apt-get clean && \
\
    # Android SDK \
    wget --output-document=android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip && \
    unzip -d $ANDROID_HOME android-sdk.zip && \
    rm android-sdk.zip && \
\
    # Android SDK licenses. \
    wget -N --output-document=android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip && \
    unzip -x android-sdk.zip && \
    mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    mv cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    echo y | $SDKMANAGER "platforms;android-${ANDROID_COMPILE_SDK}" >/dev/null && \
    echo y | $SDKMANAGER "platform-tools" >/dev/null && \
    echo y | $SDKMANAGER "build-tools;${ANDROID_BUILD_TOOLS}" >/dev/null && \
\
    # Android NDK \
    wget --quiet -N --output-document=android-ndk.zip https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
    mkdir $ANDROID_NDK_FOLDER && \
    unzip -d $ANDROID_NDK_FOLDER android-ndk.zip && \
    rm android-ndk.zip && \
\
    # Fastlane \
    gem install rake && \
    gem install fastlane -NV && \
    gem install fastlane-plugin-firebase_app_distribution -NV && \
    gem sources -c && \
\
    # Rust + cross-compiler targets. \
    # This is used for ring-signature support in libbitcoincashkotlin \
    curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    cargo install cbindgen && \
    cargo install cargo-cache && \
    rustup target add \
         aarch64-linux-android \
         armv7-linux-androideabi \
         i686-linux-android \
         x86_64-linux-android && \
    cargo cache -a


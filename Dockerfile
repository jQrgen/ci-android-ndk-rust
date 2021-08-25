FROM openjdk:16-jdk-buster

SHELL ["/bin/bash", "-c"]
ENV ANDROID_COMPILE_SDK "30"
ENV ANDROID_BUILD_TOOLS "30.0.2"
ENV ANDROID_SDK_TOOLS "7583922"
ENV ANDROID_HOME /android-sdk-linux
ENV ANDROID_NDK_ROOT /android-ndk-linux
ENV SDKMANAGER="${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager"
ENV PATH="${PATH}:${ANDROID_HOME}/platform-tools/:/root/.cargo/bin"

RUN apt-get clean
RUN apt-get --quiet update --yes
RUN apt-get --quiet install --yes wget tar unzip lib32stdc++6 lib32z1 cmake python3 build-essential libtool automake ninja-build curl xxd

# Install Android SDK
RUN wget --output-document=android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip
RUN unzip -d $ANDROID_HOME android-sdk.zip

# Accept android SDK lisences.
RUN wget -N --output-document=android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip
RUN unzip -x android-sdk.zip
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools
RUN mv cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest
RUN echo y | $SDKMANAGER "platforms;android-${ANDROID_COMPILE_SDK}" >/dev/null
RUN echo y | $SDKMANAGER "platform-tools" >/dev/null
RUN echo y | $SDKMANAGER "build-tools;${ANDROID_BUILD_TOOLS}" >/dev/null

# Download NDK
RUN wget --quiet -N --output-document=android-ndk.zip https://dl.google.com/android/repository/android-ndk-r21b-linux-x86_64.zip
RUN unzip -d $ANDROID_NDK_ROOT android-ndk.zip

# Install Rust + cross-compiler targets. This is used for
# ring signature support in libbitcoincashkotlin
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
RUN cargo install cbindgen
RUN rustup target add \
     aarch64-linux-android \
     armv7-linux-androideabi \
     i686-linux-android \
     x86_64-linux-android

# Clean
RUN rm android-ndk.zip
RUN rm android-sdk.zip
RUN apt-get clean

FROM openjdk:8-jdk

MAINTAINER Tuan Anh <tuananh.exp@gmail.com>

# nodejs, zip, to unzip things
ENV NODE_VERSION 8.x
RUN apt-get update && \
    apt-get -y install zip expect && \
    curl -sL https://deb.nodesource.com/setup_${NODE_VERSION} | bash - && \
    apt-get install -y nodejs

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

# Install 32bit support for Android SDK
RUN dpkg --add-architecture i386 && \
    apt-get update -q && \
    apt-get install -qy --no-install-recommends libc6:i386 libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386 lib32z1 build-essential \
    python-dev autoconf dtach vim tmux && \
    apt-get clean

# Install react-native cli
RUN npm install -g react-native-cli

# Install watchman
ENV WATCHMAN_VERSION v4.9.0
RUN cd /tmp && git clone https://github.com/facebook/watchman.git
RUN cd /tmp/watchman && git checkout v4.7.0 && sh ./autogen.sh && ./configure && make && make install && rm -rf /tmp/watchman

# Install and setting gradle
ENV GRADLE_VERSION 4.3
ENV GRADLE_SDK_URL https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
RUN curl -sSL "${GRADLE_SDK_URL}" -o gradle-${GRADLE_VERSION}-bin.zip  \
    && unzip gradle-${GRADLE_VERSION}-bin.zip -d /usr/local  \
    && rm -rf gradle-${GRADLE_VERSION}-bin.zip
ENV GRADLE_HOME /usr/local/gradle-${GRADLE_VERSION}
ENV PATH ${GRADLE_HOME}/bin:${PATH}

RUN mkdir /root/.gradle && touch /root/.gradle/gradle.properties && echo "org.gradle.daemon=true" >> /root/.gradle/gradle.properties

# copy tools folder
COPY tools /opt/tools
ENV PATH ${PATH}:/opt/tools

# Setup environment
ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_SDK_HOME ${ANDROID_HOME}
ENV PATH ${PATH}:${ANDROID_SDK_HOME}/tools:${ANDROID_SDK_HOME}/platform-tools

# Android sdk tools
RUN cd /opt \
    && wget -q https://dl.google.com/android/repository/tools_r25.2.3-linux.zip -O tools.zip \
    && mkdir -p ${ANDROID_SDK_HOME} \
    && unzip tools.zip -d ${ANDROID_SDK_HOME} \
    && rm -f tools.zip

RUN echo "y" | android update sdk --no-ui --force -a --filter extra-android-m2repository,extra-android-support,extra-google-m2repository,platform-tools,android-23,build-tools-23.0.1,android-25,build-tools-25

RUN echo "export PATH=${PATH}" > /root/.profile

# Android licenses
RUN mkdir $ANDROID_SDK_HOME/licenses
RUN echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > $ANDROID_SDK_HOME/licenses/android-sdk-license
RUN echo 84831b9409646a918e30573bab4c9c91346d8abd > $ANDROID_SDK_HOME/licenses/android-sdk-preview-license

# sdk
RUN opt/tools/android-accept-licenses.sh "$ANDROID_SDK_HOME/tools/bin/sdkmanager \
    tools \
    \"platform-tools\" \
    \"build-tools;23.0.1\" \
    \"build-tools;23.0.3\" \
    \"build-tools;25.0.1\" \
    \"build-tools;25.0.2\" \
    \"platforms;android-23\" \
    \"platforms;android-25\" \
    \"extras;android;m2repository\" \
    \"extras;google;m2repository\" \
    \"extras;google;google_play_services\"" \
    && $ANDROID_SDK_HOME/tools/bin/sdkmanager --update

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

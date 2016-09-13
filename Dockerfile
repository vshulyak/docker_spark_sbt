FROM alpine:3.4
MAINTAINER Vladimir Shulyak "vladimir@shulyak.net"

# Java
ARG JAVA_MAJOR_VERSION=8
ARG JAVA_UPDATE_VERSION=92
ARG JAVA_BUILD_NUMBER=14
ENV JAVA_HOME /usr/jdk1.${JAVA_MAJOR_VERSION}.0_${JAVA_UPDATE_VERSION}
ENV PATH $PATH:$JAVA_HOME/bin

# Scala
ARG SCALA_VERSION=2.11.8
ARG SBT_VERSION=0.13.12

# Glibc
ARG GLIBC_VERSION=2.23-r3

COPY sbt /usr/bin/sbt

# Install Scala & SBT
RUN \
  apk upgrade --update && \
  apk add --update libstdc++ ca-certificates curl bash && \
  for pkg in glibc-${GLIBC_VERSION} glibc-bin-${GLIBC_VERSION} glibc-i18n-${GLIBC_VERSION}; do curl -sSL https://github.com/andyshinn/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/${pkg}.apk -o /tmp/${pkg}.apk; done && \
  apk add --allow-untrusted /tmp/*.apk && \
  rm -v /tmp/*.apk && \
  ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true ) && \
  echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
  /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
  curl -sL --retry 3 --insecure \
   --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
   "http://download.oracle.com/otn-pub/java/jdk/${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-b${JAVA_BUILD_NUMBER}/server-jre-${JAVA_MAJOR_VERSION}u${JAVA_UPDATE_VERSION}-linux-x64.tar.gz" \
   | gunzip \
   | tar x -C /usr/ && \
   ln -s $JAVA_HOME /usr/java && \
   rm -rf $JAVA_HOME/man && \
  curl -fsL http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz | tar xfz - -C /root/ && \
  mv /root/scala-$SCALA_VERSION /root/scala && \
  echo >> /root/.bashrc && \
  echo 'export PATH=~/scala/bin:$PATH' >> /root/.bashrc && \
  curl -L -o /usr/bin/sbt-launch.jar https://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/$SBT_VERSION/sbt-launch.jar && \
  chmod +x /usr/bin/sbt && \
  sbt sbtVersion

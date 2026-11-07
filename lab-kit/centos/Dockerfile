FROM centos:7

ENV container docker
MAINTAINER The CentOS Project <cloud-ops@centos.org>

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ "$i" = systemd-tmpfiles-setup.service ] || rm -f "$i"; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*; \
rm -f /etc/systemd/system/*.wants/*; \
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*; \
rm -f /lib/systemd/system/anaconda.target.wants/*

RUN printf '[Unit]\nDescription=Remove /run/nologin on startup\nAfter=local-fs.target\nBefore=sshd.service\n\n[Service]\nType=oneshot\nExecStart=/bin/rm -f /run/nologin\nRemainAfterExit=yes\n\n[Install]\nWantedBy=multi-user.target\n' \
    > /etc/systemd/system/remove-nologin.service \
    && mkdir -p /etc/systemd/system/multi-user.target.wants \
    && ln -s /etc/systemd/system/remove-nologin.service \
             /etc/systemd/system/multi-user.target.wants/remove-nologin.service

RUN cd /etc/yum.repos.d/ && sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN yum install -y ca-certificates curl wget unzip openssh-server openssh-clients net-tools which initscripts lsof openssl && \
    yum clean all

RUN groupadd -g 54321 oinstall && \
    groupadd -g 54322 dba && \
    groupadd -g 54323 oper && \
    useradd -u 54321 -g oinstall -G dba,oper oracle

RUN rm -rf /run/nologin && \
    printf '#!/bin/sh\nrm -rf /run/nologin\n' > /rmlogin.sh && \
    chmod +x /rmlogin.sh

RUN mkdir -p /home/oracle/pkg /home/oracle/conf /u01 && \
    chown -R oracle:oinstall /home/oracle /u01

ARG ZOOKEEPER_VERSION=3.7.2
ARG ZOOKEEPER_SHA512=6afbfc1afc8b9370281bd9862f37dbb1cb95ec54bb2ed4371831aa5c0f08cfee775050bd57ce5fc0836e61af27eed9f0076f54b98997dd0e15159196056e52ea
ARG KAFKA_VERSION=3.9.0
ARG KAFKA_SCALA_VERSION=2.13
ARG KAFKA_SHA512=5324c1f44d4c84ea469712c2cc3d2d15545c3716edbb5353722df9c661fcc78b031fcf07d1c4f0309c5fdb32686665dfb0cffe55210cd3a1fe2a370538cb4e6d
ARG SPARK_VERSION=4.0.1
ARG SPARK_SHA512=9198602c6b931b46686f32a25793b3bb58b522cd98a5b6a94d2484bae32e3e7b520d60f4bffe72ba29ff5c9ecd862443841ee47dde0f2f9e1bf52539f7baef41

RUN set -eux; \
    zookeeper_file="apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz"; \
    kafka_file="kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz"; \
    spark_file="spark-${SPARK_VERSION}-bin-hadoop3.tgz"; \
    curl -fL --retry 3 --retry-delay 5 --connect-timeout 15 \
      -o "/tmp/${zookeeper_file}.part" \
      "https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/${zookeeper_file}"; \
    echo "${ZOOKEEPER_SHA512}  /tmp/${zookeeper_file}.part" | sha512sum -c -; \
    curl -fL --retry 3 --retry-delay 5 --connect-timeout 15 \
      -o "/tmp/${kafka_file}.part" \
      "https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/${kafka_file}"; \
    echo "${KAFKA_SHA512}  /tmp/${kafka_file}.part" | sha512sum -c -; \
    curl -fL --retry 3 --retry-delay 5 --connect-timeout 15 \
      -o "/tmp/${spark_file}.part" \
      "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${spark_file}"; \
    echo "${SPARK_SHA512}  /tmp/${spark_file}.part" | sha512sum -c -; \
    tar -xzf "/tmp/${zookeeper_file}.part" -C /usr/local; \
    tar -xzf "/tmp/${kafka_file}.part" -C /usr/local; \
    tar -xzf "/tmp/${spark_file}.part" -C /home/oracle; \
    ln -s "apache-zookeeper-${ZOOKEEPER_VERSION}-bin" /usr/local/zookeeper; \
    ln -s "kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}" /usr/local/kafka; \
    ln -s "spark-${SPARK_VERSION}-bin-hadoop3" /home/oracle/spark; \
    mkdir -p /usr/local/zookeeper/data /usr/local/kafka/config /usr/local/kafka/logs; \
    echo 1 > /usr/local/zookeeper/data/myid; \
    chown -R root:root "/usr/local/apache-zookeeper-${ZOOKEEPER_VERSION}-bin" "/usr/local/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}"; \
    chown -R oracle:oinstall "/home/oracle/spark-${SPARK_VERSION}-bin-hadoop3" /home/oracle/spark; \
    rm -f "/tmp/${zookeeper_file}.part" "/tmp/${kafka_file}.part" "/tmp/${spark_file}.part"

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

COPY script /u01/
COPY conf /home/oracle/conf
COPY initSSH.sh /home/oracle/initSSH.sh
COPY zookeeper.service /etc/systemd/system/
COPY kafka.service /etc/systemd/system/
COPY setOggBD.sh /u01/setOggBD.sh
COPY server.properties /home/oracle/conf/server.properties

RUN chmod 755 /home/oracle/initSSH.sh /u01/*.sh 2>/dev/null || true

RUN printf '%s\n' \
    'export JAVA_HOME=/usr/java/jdk-21' \
    'export SPARK_HOME=/home/oracle/spark' \
    'export OSA_HOME=/home/oracle/osa' \
    'export KAFKA_HOME=/usr/local/kafka' \
    'export KAFKA_HEAP_OPTS="-Xms500m -Xmx500m"' \
    'export LD_LIBRARY_PATH=$JAVA_HOME/lib/server:$LD_LIBRARY_PATH' \
    'export PATH=$JAVA_HOME/bin:$SPARK_HOME/bin:$KAFKA_HOME/bin:/usr/local/zookeeper/bin:$PATH' \
    'set -o vi' >> /home/oracle/.bashrc && \
    cat /home/oracle/.bashrc >> /root/.bashrc

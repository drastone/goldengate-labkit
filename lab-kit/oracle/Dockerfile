FROM oracle/database:19.3.0-ee

#RUN yum install -y wget
#RUN yum install -y vi

# by cys 20241228
#RUN yum install -y kde-l10n-ko

#RUN mkdir -p ~/pkg && cd ~/pkg && wget https://download.oracle.com/java/17/archive/jdk-17.0.6_linux-x64_bin.rpm
#RUN cd ~/pkg &&  wget https://download.oracle.com/otn_software/java/ords/ords-latest.zip && mkdir -p /home/oracle/ords/conf && unzip ./ords-latest.zip -d /home/oracle/ords
#RUN mkdir -p ~/msa/source && mkdir -p ~/msa/target

RUN echo "export NLS_LANG=AMERICAN_KOREA.AL32UTF8" >> /home/oracle/.bashrc && echo "export OGG_ETC_HOME=/home/oracle/oggmsa/oggSM/etc" >> /home/oracle/.bashrc && echo "export OGG_VAR_HOME=/home/oracle/oggmsa/oggSM/var" >>  /home/oracle/.bashrc && echo "export JAVA_HOME=/usr/java/jdk1.8.0_211-amd64" >> /home/oracle/.bashrc && echo "export LD_LIBRARY_PATH=$ORACLE_HOME/lib:\$JAVA_HOME/jre/lib/amd64/server:$/lib:/usr/lib:\$LD_LIBRARY_PATH" >> /home/oracle/.bashrc && echo "export SPARK_HOME=/home/oracle/spark" >> /home/oracle/.bashrc && echo "export OSA_HOME=/home/oracle/osa"  >> /home/oracle/.bashrc && echo "export ORDS_HOME=/home/oracle/ords"  >> /home/oracle/.bashrc && echo "export LANG=en_US.UTF-8" >> /home/oracle/.bashrc && echo "set -o vi" >> /home/oracle/.bashrc && echo "alias ll='ls -ltr'" >> /home/oracle/.bashrc && echo "export PATH=\$JAVA_HOME/bin:\$ORDS_HOME/bin:\$PATH" >> /home/oracle/.bashrc

COPY .bash_profile /home/oracle/.bash_profile
COPY setMSAEnv.sh /home/oracle/setMSAEnv.sh
COPY msa /home/oracle/msa
COPY script /home/oracle/script
COPY pkg /home/oracle/pkg

#RUN chown -R oracle:oinstall /home/oracle/msa
#RUN chown -R oracle:oinstall /home/oracle/script
#RUN chown -R oracle:oinstall /home/oracle/pkg

VOLUME [ "/sys/fs/cgroup" ]
#ENTRYPOINT ["/usr/sbin/init"]

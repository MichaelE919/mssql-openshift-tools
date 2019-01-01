FROM openshift/base-centos7
LABEL maintainer="Michael Eichenberger mikeetpt@gmail.com"

RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    curl -o /etc/yum.repos.d/mssql-release.repo https://packages.microsoft.com/config/rhel/7/prod.repo && \
    ACCEPT_EULA=Y yum install -y msodbcsql mssql-tools unixODBC-devel && yum clean all -y

ADD ./init.sh ./
ADD ./uid_entrypoint.sh ./
RUN chown 1001:0 *.sh && chmod +wx *.sh

RUN chmod g=u /etc/passwd
ENV PATH $PATH:/opt/mssql-tools/bin

# Add the krb5.conf file
COPY ./krb5.conf /etc

# Add odbcadd.txt file
COPY ./odbcadd.txt /opt/app-root/src

# Register the SQL Server database DSN information in /etc/odbc.ini
RUN odbcinst -i -s -f /opt/app-root/src/odbcadd.txt -l && \
    rm /opt/app-root/src/odbcadd.txt

# Add keytab file
RUN mkdir /krb5 && \
    chown -R 1001:0 /krb5 && chmod -R og+rwx /krb5

USER 1001
EXPOSE 8080
# ENTRYPOINT [ "./uid_entrypoint.sh" ]
# CMD ["./init.sh"]
CMD ["/bin/bash"]
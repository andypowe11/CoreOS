# Set the base image to Ubuntu
FROM    centos

# File Author / Maintainer
MAINTAINER Andy Powell

# Install dependencies
RUN yum -y update && \
    yum -y install epel-release && \
    yum -y install python python-devel python-pip gcc cc1plus gcc-c++ libffi-devel openssl-devel && \
    pip install --upgrade pip

# Install locustio pyzmq
#RUN pip install pyopenssl ndg-httpsclient pyasn1
RUN pip install requests[security]
RUN pip install locustio
RUN pip install pyzmq

# Install locustfile.py
RUN mkdir /locust
ADD . /locust

# Define working directory
WORKDIR /locust

# Expose port
EXPOSE  8089

# Run locust
#ENTRYPOINT [ "locust" ]
ENTRYPOINT [ "/usr/bin/locust" ]

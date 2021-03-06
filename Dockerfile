FROM debian:jessie
MAINTAINER Nick Roth "nlr06886@gmail.com"

# Link in our build files to the docker image
ADD src/ /tmp

# Run all ubuntu updates and apt-get installs
RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y git \
		wget \
		bzip2 \
		build-essential \
		python-dev \
		gfortran \
		libglib2.0-0 \
		python-qt4 \
	&& apt-get clean

# Create conda user, get anaconda by web or locally
RUN useradd --create-home --home-dir /home/condauser --shell /bin/bash condauser
RUN /tmp/get_anaconda.sh

# Run all python installs
# Perform any cleanup of the install as needed
USER condauser
RUN /tmp/install.sh 

# Copy notebook config into ipython directory
# Make sure our user owns the directory
USER root
RUN  apt-get --purge -y autoremove wget && \
	cp /tmp/jupyter_notebook_config.py /home/condauser/.jupyter/jupyter_notebook_config.py && \
	chown condauser:condauser /home/condauser -R

# Set persistent environment variables for python3 and python2
#ENV PY2PATH=/home/condauser/anaconda3/envs/python2/bin
ENV PY3PATH=/home/condauser/anaconda3/bin

# Install the python2 ipython kernel
#RUN $PY2PATH/python $PY2PATH/ipython kernelspec install-self

# Setup our environment for running the ipython notebook
# Setting user here makes sure ipython notebook is run as user, not root
EXPOSE 8888
USER condauser
ENV HOME=/home/condauser
ENV SHELL=/bin/bash
ENV USER=condauser
WORKDIR /home/condauser/notebooks

CMD $PY3PATH/jupyter-notebook

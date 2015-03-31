FROM ubuntu:14.04

MAINTAINER Lindsay Magnus <lindsay@ska.ac.za>


# Install system packages
RUN apt-get -y update && apt-get -y install \
    csh \
    build-essential \
    gfortran \
    tk \
    tk-dev \
    libpng-dev \
    libgd2-xpm-dev \
    cvs \
    autoconf \
    automake \
    libtool \
    m4 \
    git \
    gsl-bin\ 
    libgsl0-dev \
    flex \
    bison \
    fort77 \
    libglib2.0-dev \
    gnuplot \
    gnuplot-x11 \
    python-dev \
    python-numpy \
    python-scipy \ 
    python-matplotlib \
    ipython \
    ipython-notebook \
    python-pandas \
    python-sympy \
    python-nose \
    swig \
    python python-pip git-core wget \
    python-h5py \ 
    subversion \
    nfs-common nfs-client \
    openssh-server

RUN mkdir /var/run/sshd

RUN adduser --disabled-password --gecos 'unprivileged user' kat \
    && (echo kat; echo kat) | passwd kat \
    && adduser kat sudo \
    && mkdir -p /home/kat/pulsar_software

# Path to the pulsar software installation directory eg:
ENV SOFTWARE_DIR /home/kat/pulsar_software

# OSTYPE
ENV OSTYPE linux

# PSRCAT
ENV PSRCAT_FILE $SOFTWARE_DIR/psrcat_tar/psrcat.db

# Tempo
ENV TEMPO $SOFTWARE_DIR/tempo

# Tempo2
export TEMPO2 $SOFTWARE_DIR/tempo2/T2runtime

# PGPLOT
ENV PGPLOT_DIR $SOFTWARE_DIR/pgplot_build
ENV PGPLOT_DEV /xwindow

# PRESTO
ENV PRESTO $SOFTWARE_DIR/presto

# LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:$SOFTWARE_DIR/lib:\
    $SOFTWARE_DIR/pgplot_build:$SOFTWARE_DIR/presto/lib

# PATH
# Some Presto executables match sigproc executables so keep separate -
# all other executables are found in $SOFTWARE_DIR/bin
ENV PATH $PATH:$SOFTWARE_DIR/bin:$SOFTWARE_DIR/presto/bin

# PYTHON PATH eg.
ENV PYTHONPATH $PRESTO/lib/python:$SOFTWARE_DIR/lib/python2.7/site-packages

# Set up access to github private repositories
COPY id_rsa /root/.ssh/
RUN echo "Host *\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config
RUN chmod -R go-rwx ~/.ssh

WORKDIR /home/kat

RUN wget http://www.fftw.org/fftw-3.3.4.tar.gz

RUN mkdir -p /usr/src/fftw3 \
    && tar -xvf fftw-3.3.4.tar.gz -C /usr/src/fftw3 \
    && cd /usr/src/fftw3 \
    && cd fftw-3.3.4 \
    && ./configure --prefix=$SOFTWARE_DIR --enable-float --enable-threads --enable-shared \
    && make \
    && make check \
    && make install \
    && make clean 
    
WORKDIR /home/kat

RUN wget ftp://heasarc.gsfc.nasa.gov/software/fitsio/c/cfitsio_latest.tar.gz

RUN tar -xvf cfitsio_latest.tar.gz -C /usr/src/ \
    && cd /usr/src/cfitsio \
    && ./configure --prefix=$SOFTWARE_DIR \
    && make shared\
    && make install \
    && make clean
                                
WORKDIR /home/kat

RUN wget http://www.atnf.csiro.au/people/pulsar/psrcat/downloads/psrcat_pkg.tar.gz

RUN tar -xvf psrcat_pkg.tar.gz -C $SOFTWARE_DIR/ \ 
    && cd $SOFTWARE_DIR/psrcat_tar \
    && /bin/bash makeit \
    && cp psrcat $SOFTWARE_DIR/bin

CMD ["/usr/sbin/sshd", "-D"]

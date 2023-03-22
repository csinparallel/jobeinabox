# Jobe-in-a-box: a Dockerised Jobe server (see https://github.com/trampgeek/jobe)
# With thanks to David Bowes (d.h.bowes@lancaster.ac.uk) who did all the hard work
# on this originally.

FROM docker.io/ubuntu:22.04

RUN ln -snf /usr/share/zoneinfo/"$TZ" /etc/localtime && \
    echo "$TZ" > /etc/timezone && \
    apt-get update && \
    apt-get --no-install-recommends install -yq \
        apache2 \
        tzdata 

ADD https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.5.tar.gz /var/local/
RUN apt-get update && \
    apt-get install -yq \
        autoconf \
        automake \
        build-essential \
        openssh-client && \
    cd /var/local && \
    tar xfz openmpi-4.1.5.tar.gz && \
    cd openmpi-4.1.5 && \
    ./configure --prefix=/usr/lib/openmpi-4.1.5 && \
    make all install && \
    cd /usr/lib && \
    ln -s openmpi-4.1.5/ openmpi && \
    for prog in `ls openmpi-4.1.5/bin` ; \
    do  update-alternatives --install "/usr/bin/$prog" "$prog" "/usr/lib/openmpi-4.1.5/bin/$prog" 1 ; \
    done

# Expose apache
EXPOSE 80

# Start apache
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

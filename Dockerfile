FROM ubuntu:12.04

# ghc 7.6.3, cabal, happy
ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive
WORKDIR /root
RUN apt-get update

RUN mkdir -p ${HOME}/.ssh/
RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN apt-get install -y wget libgmp3c2 build-essential
RUN wget http://www.haskell.org/ghc/dist/7.6.3/ghc-7.6.3-x86_64-unknown-linux.tar.bz2
RUN tar -xvf ghc-7.6.3-x86_64-unknown-linux.tar.bz2
RUN rm ghc-7.6.3-x86_64-unknown-linux.tar.bz2

WORKDIR /root/ghc-7.6.3/
RUN ./configure
RUN make install
RUN rm -rf ghc-7.6.3
WORKDIR /root

RUN apt-get install -y cabal-install zlib1g-dev
RUN cabal update
RUN cabal install cabal cabal-install

ENV PATH $HOME/.cabal/bin:$PATH
RUN echo "export PATH=~/.cabal/bin:$PATH" >> /root/.profile

RUN locale-gen en_US.UTF-8
RUN export LC_ALL='en_US.UTF-8'
ENV LC_ALL en_US.UTF-8
RUN cabal install -j random happy


# install some dependencies
RUN apt-get install -y libpq-dev

# copy code to container
RUN mkdir -p ${HOME}/postgresql-user-manager
COPY src ${HOME}/postgresql-user-manager/src
COPY Postgresql-User-Manager.cabal ${HOME}/postgresql-user-manager/
COPY Setup.hs ${HOME}/postgresql-user-manager/
COPY LICENSE ${HOME}/postgresql-user-manager/
WORKDIR ${HOME}/postgresql-user-manager
RUN cabal sandbox init
RUN cabal install

EXPOSE 22
CMD /usr/sbin/sshd -D


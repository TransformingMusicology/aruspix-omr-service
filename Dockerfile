FROM node:18-bullseye

RUN apt-get update \
    && apt-get install -y \
      cmake \
      gawk \
      imagemagick \
      jq \
      libxml2-dev \
      python3-pip \
      uuid-dev \
      vim \
      xsltproc \
    && rm -rf /var/lib/apt/lists/*

# Aruspix
# setup instructions from https://github.com/DDMAL/aruspix/wiki/03-%E2%80%93-Aruspix-Command-line

RUN mkdir -p /tmp/aruspix

WORKDIR /tmp/aruspix
RUN wget -q https://netcologne.dl.sourceforge.net/project/wxwindows/3.0.2/wxWidgets-3.0.2.tar.bz2
RUN tar xfj wxWidgets-3.0.2.tar.bz2
WORKDIR /tmp/aruspix/wxWidgets-3.0.2
RUN ./configure --disable-unicode --disable-shared --disable-gui && make && make install && ldconfig

WORKDIR /tmp/aruspix
RUN git clone https://github.com/alastair/aruspix.git

RUN mkdir -p /tmp/aruspix/im
WORKDIR /tmp/aruspix/im
RUN wget -q https://master.dl.sourceforge.net/project/imtoolkit/3.6.3/Linux%20Libraries/im-3.6.3_Linux26g4_64_lib.tar.gz
RUN tar xfz im-3.6.3_Linux26g4_64_lib.tar.gz
RUN mkdir lib && mv lib*.a lib*.so lib
RUN cp lib/* /usr/local/lib
RUN ldconfig

WORKDIR /tmp/aruspix

RUN tar xfj /tmp/aruspix/aruspix/doc/torch/Torch3.tar.gz
WORKDIR /tmp/aruspix/Torch3
RUN find . -name "._*" | xargs rm
RUN cp /tmp/aruspix/aruspix/doc/torch/Makefile_options_SAMPLE Makefile_options_Linux
RUN make depend && make

WORKDIR /tmp/aruspix/aruspix/cmd-line
RUN cmake . -DimDir=../../im -DtorchDir=../../Torch3
RUN make
RUN make install

RUN mkdir /app
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm install

COPY . ./

EXPOSE 3000

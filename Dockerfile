FROM hypriot/rpi-alpine
ENV \
  NUMPY_VERSION="1.12.0" \
  PYNQ_VERSION="1.4"
RUN apk add --no-cache --update --virtual=build-dependencies \
    curl \
    g++ \
    gcc \
    make \
    musl-dev \
    python3-dev \
  && apk add --no-cache --update --virtual=pynq-dependencies \
    libjpeg-turbo-dev \
    python3 \
  && apk add --no-cache --update --virtual=pynq-install-dependencies \
    expat \
    gcc \
    libffi-dev \
    musl-dev \
    python3-dev \
    zlib-dev \
  && curl -sL -o pynq.tar.gz https://github.com/Xilinx/PYNQ/archive/v${PYNQ_VERSION}.tar.gz \
  && tar -xf pynq.tar.gz \
  && (cd PYNQ-${PYNQ_VERSION}/scripts/xlnkutils && make && make install) \
  && (cd /usr/bin \
    && ln -s gcc arm-linux-gnueabihf-gcc \
    && ln -s g++ arm-linux-gnueabihf-g++ \
    ) \
  && (cd PYNQ-${PYNQ_VERSION}/python \
    && (cd pynq/_pynq/_apf && make) \
    && (cd pynq/_pynq/_audio && make) \
    && cp -r ../Pynq-Z1/bitstream pynq \
    && python3 -m pip --no-cache-dir install wheel \
    && python3 setup.py bdist_wheel \
    && python3 setup.py clean \
    && rm -rf \
      build \
      pynq.egg-info \
    ) \
  && python3 -m pip install \
    PYNQ-${PYNQ_VERSION}/python/dist/pynq-${PYNQ_VERSION}-cp35-cp35m-linux_armv7l.whl \
    Pillow \
    cffi \
    https://github.com/go-zynq/numpy-linux_arm.whl/releases/download/${NUMPY_VERSION}/numpy-${NUMPY_VERSION}-cp35-cp35m-linux_armv7l.whl \
    ipython \
  && apk del --purge build-dependencies \
  && apk del --purge pynq-install-dependencies \
  && rm \
    /usr/bin/arm-linux-gnueabihf-g++ \
    /usr/bin/arm-linux-gnueabihf-gcc \
    pynq.tar.gz \
  ;

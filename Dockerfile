FROM ubuntu:latest

RUN mkdir -p /test/workspace
WORKDIR /test/workspace
COPY . .

RUN apt-get update && apt-get install --assume-yes git curl

RUN bash -c "git clone https://github.com/opencv/opencv.git && cd opencv && git checkout 4.6.0"
RUN mkdir -p opencv/build
RUN apt-get install --assume-yes cmake
RUN apt-get install --assume-yes gcc g++
RUN cd opencv/build && cmake -DBUILD_SHARED_LIBS=off -DOPENCV_FORCE_3RDPARTY_BUILD=on -DBUILD_LIST=core,dnn,imgcodecs -DCMAKE_INSTALL_PREFIX=install -DCMAKE_BUILD_TYPE=RELEASE ..  && cmake --build . --target install -j 8
#      - uses: actions-rust-lang/setup-rust-toolchain@v1
RUN curl --proto '=https' --tlsv1.2 --retry 10 --retry-connrefused -fsSL "https://sh.rustup.rs" | sh -s -- --default-toolchain none -y
ENV PATH=$PATH:/root/.cargo/bin
RUN rustup toolchain install stable --profile minimal --no-self-update
RUN rustup default stable

RUN OPENCV_DISABLE_PROBES=1 OPENCV_LINK_PATHS="$(pwd)/opencv/build/install/lib/opencv4/3rdparty,$(pwd)/opencv/build/install/lib" OPENCV_LINK_LIBS=opencv_core,opencv_imgproc,opencv_imgcodecs,opencv_dnn OPENCV_INCLUDE_PATHS="$(pwd)/opencv/build/install/include/opencv4" cargo run

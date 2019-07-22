FROM crcrpar/swift-jupyter:cv_test_base

# Install OpenCV
WORKDIR /opencv
ADD docker/third_party/opencv /opencv/opencv
ADD docker/third_party/opencv_contrib /opencv/opencv_contrib
RUN ls -g /opencv
RUN cd /opencv/opencv && mkdir build && cd build \
    && cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local .. \
    && make -j7 \
    && make install

# Run jupyter on startup
EXPOSE 8888
RUN mkdir /notebooks
WORKDIR /notebooks
CMD ["/swift-jupyter/docker/run_jupyter.sh", "--allow-root", "--no-browser", "--ip=0.0.0.0", "--port=8888", "--NotebookApp.custom_display_url=http://127.0.0.1:8888"]

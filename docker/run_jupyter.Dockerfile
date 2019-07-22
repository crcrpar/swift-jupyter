FROM crcrpar/swift-jupyter:tf0.4-opencv

# Run jupyter on startup
EXPOSE 8888
RUN mkdir /notebooks
WORKDIR /notebooks
CMD ["/swift-jupyter/docker/run_jupyter.sh", "--allow-root", "--no-browser", "--ip=0.0.0.0", "--port=8888", "--NotebookApp.custom_display_url=http://127.0.0.1:8888"]

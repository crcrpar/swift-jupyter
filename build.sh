#!/usr/bin/env bash
# from inside the directory of this repository
docker build -f docker/Dockerfile -t crcrpar/swift-jupyter:tf0.4 .
docker push crcrpar/swift-jupyter:tf0.4
# Install OpenCV to swift-jupyter
docker build -f docker/opencv.Dockerfile -t crcrpar/swift-jupyter:tf0.4-opencv .
docker push crcrpar/swift-jupyter:tf0.4-opencv
# Add `run_jupyter.sh`
docker build -f docker/opencv.Dockerfile -t crcrpar/swift-jupyter:tf0.4-opencv-jupyter .
docker push crcrpar/swift-jupyter:tf0.4-opencv-jupyter

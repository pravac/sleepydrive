#!/bin/bash
pip install -q tf2onnx tensorflow
python -m tf2onnx.convert --tflite /models/face_detector.tflite --output /models/face_detector.onnx
python -m tf2onnx.convert --tflite /models/face_landmarks_detector.tflite --output /models/face_landmarks_detector.onnx

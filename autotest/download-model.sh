#!/bin/bash
model_path=$1

mkdir -p ~/weights/$model_path

huggingface-cli download $model_path --local-dir ~/weights/$model_path --force-download
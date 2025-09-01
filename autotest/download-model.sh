#!/bin/bash
model_path="$1"

# (optional: $2 is gguf_name, maybe empty (not gguf))
gguf_name="$2"

mkdir -p ~/weights/$model_path
if [[ -n "$gguf_name" ]]; then
    huggingface-cli download $model_path $gguf_name --local-dir  ~/weights/$model_path --force-download
else
    huggingface-cli download $model_path --local-dir ~/weights/$model_path --force-download
fi



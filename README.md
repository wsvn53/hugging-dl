# hugging-dl

Simple script to download model files on HuggingFace. The only dependencies are curl.

## Background

Downloading models from Huggingface can be frustrating. Git clone relies on `git-lfs` and takes up more storage space after completion (due to git commit history). Models downloaded using the transformers API are stored as `soft links` in the cache directory, which is not conducive to sharing. Therefore, this small tool was developed that analyzes the download address of the model on the Huggingface page, downloads all its files separately, and supports breakpoint resumption and retrying downloads to avoid wasting network bandwidth and time due to unexpected disconnections during model downloading.

## Features

1. Download model/dataset files from Huggingface without git lfs for saving your storage space.
2. Supports downloading your private models from Huggingface with an access token.
3. Continuously resume download progress of the model files after connection aborted.
4. Supports downloading models from a Huggingface mirror site URL.

## Usage

```sh
./hugging-dl.sh -h

Usage: hugging-dl.sh [model_path|model_url] [output_dir]

Options:
  -h, --help: Print help message and exit.
  -v, --version: Print version and exit.
  -t, --token: Set Huggingface access token for authentication, which can be created from [https://huggingface.co/settings/tokens]

Example:
  hugging-dl.sh meta-llama/Llama-2-70b-chat-hf /path/to/save/model
  hugging-dl.sh https://huggingface.co/meta-llama/Llama-2-70b-chat-hf /path/to/save/model

1. You can directly copy the [model_path] from the model card page, such as [meta-llama/Llama-2-70b-chat-hf].
2. The [model_url] is full URL of the model such as [https://huggingface.co/meta-llama/Llama-2-70b-chat-hf].
3. The [output_dir] is the path to save the files of model, if not specified the default path will be the name of the [model_path].

For more information, please visit: https://github.com/wsvn53/hugging-dl
```

## Examples:

```sh
hugging-dl.sh gpt2
hugging-dl.sh https://huggingface.co/mosaicml/mpt-7b-chat
hugging-dl.sh https://huggingface.co/mosaicml/mpt-7b-chat mpt-7b-chat
hugging-dl.sh -t hf_sctiSbZiVL..... https://huggingface.co/meta-llama/Llama-2-70b-chat-hf
```

## License

Apache License 2.0
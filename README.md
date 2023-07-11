# hugging-dl

Simple script to download model files on HuggingFace. The only dependencies are curl/awk.

## Background

Downloading models from Huggingface can be frustrating. Git clone relies on `git-lfs` and takes up more storage space after completion (due to git commit history). Models downloaded using the transformers API are stored as `soft links` in the cache directory, which is not conducive to sharing. Therefore, this small tool was developed that analyzes the download address of the model on the Huggingface page, downloads all its files separately, and supports breakpoint resumption and retrying downloads to avoid wasting network bandwidth and time due to unexpected disconnections during model downloading.

## Usage

This tool required `jq` for parsing json data, so please install via:

```sh
# Ubuntu or Debian
sudo apt install jq

# For macOS
brew install jq
```

```sh
./hugging-dl.sh -h

usage: hugging-dl.sh [model_path|model_url] [output_dir]

1. You can directly copy the [model_path] from the model card page, such as [mosaicml/mpt-30b-instruct].
2. The [model_url] is full URL of the model such as [https://huggingface.co/mosaicml/mpt-30b-instruct].
3. The [output_dir] is the path to save the files of model, if not specificed the default path will be the name of the [model_path].

For more information, please visit: https://github.com/wsvn53/hugging-dl
```

Examples:

```sh
hugging-dl.sh gpt2
hugging-dl.sh https://huggingface.co/mosaicml/mpt-7b-chat
hugging-dl.sh https://huggingface.co/mosaicml/mpt-7b-chat mpt-7b-chat
```

## License

Apache License 2.0
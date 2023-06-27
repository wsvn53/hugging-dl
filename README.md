# hugging-dl

Simple script to download model files on HuggingFace. The only dependencies are curl/awk.

## Usage

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
#!/bin/bash

[[ $1 == '-h' ]] && {
	echo "usage: hugging-dl.sh [model_path|model_url] [output_dir]";
	echo "";
	echo "1. You can directly copy the [model_path] from the model card page, such as [mosaicml/mpt-30b-instruct]."
	echo "2. The [model_url] is full URL of the model such as [https://huggingface.co/mosaicml/mpt-30b-instruct]."
	echo "3. The [output_dir] is the path to save the files of model, if not specificed the default path will be the name of the [model_path]."
	echo "";
	echo "For more information, please visit: https://github.com/wsvn53/hugging-dl"
	exit 0;
}

# Required jq
which jq > /dev/null || {
	echo "🚫 No 'jq' command found, please install jq first!";
	exit 1002;
}

hugging_url=$1;
[[ -z "$hugging_url" ]] && echo "🚫 No huggingface model url specificed!" && exit 1000;
[[ "$hugging_url" != http* ]] && hugging_url="https://huggingface.co/$hugging_url";

hugging_host="$(echo "$hugging_url" | cut -d/ -f1 -f2 -f3)";
echo "ℹ️ Huggingface host: $hugging_host";

# Auto download HuggineFace files with curl
hugging_api_prefix="$hugging_host/api/models";
hugging_api_suffix="tree/main";

output_dir=$2;
[[ -z "$output_dir" ]] && output_dir=$(basename $hugging_url);

[[ -d "$output_dir" ]] || mkdir -pv "$output_dir";
cd "$output_dir";

hugging_path="$(echo "$hugging_url" | sed "s#$hugging_host/##g")";
hugging_url="$(echo "$hugging_url" | sed "s#$hugging_host#$hugging_api_prefix#g")/$hugging_api_suffix";

echo "ℹ️ Huggingface API URL: [$hugging_url]";
echo "ℹ️ Huggingface Model Path: [$hugging_path]";

curl "$hugging_url" | jq '.[].path' --raw-output | while read filename; do
	echo "⬇️ Downloading [$filename] ..";
	down_url="$hugging_host/$hugging_path/resolve/main/$filename";
	echo "- URL: $down_url";
	max_retry=20;
	ret_code=1;
	while [[ $ret_code != 0 ]]; do 
		echo "curl -C - -L -O \"$down_url\""; 
		curl -C - -L -O "$down_url"; 
		ret_code=$?;
		[[ $ret_code == 0 ]] && echo "✅ Download Completed [$filename]" && break;

		max_retry=$((max_retry-1));
		[[ $max_retry == 0 ]] && echo "🚫 Download still FAILED: $down_url" && break;
		echo "⚠️ Download failed. Retrying with continuous download(retry $max_retry remains)."
	done
done

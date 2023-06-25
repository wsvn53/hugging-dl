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

# Auto download HuggineFace files with curl
hugging_prefix="https://huggingface.co";

hugging_url=$1;
[[ -z "$hugging_url" ]] && echo "";

output_dir=$2;
[[ -z "$output_dir" ]] && output_dir=$(basename $hugging_url);

[[ -d "$output_dir" ]] || mkdir -pv "$output_dir";
cd "$output_dir";

[[ "$hugging_url" == https://* ]] || {
	hugging_url="$hugging_prefix/$hugging_url";
}

echo "🍺 Starting download $hugging_url to $output_dir";

curl -s "$hugging_url/tree/main" | grep download= | awk -F'href=' '{print $2}' | cut -d'"' -f2 | while read url; do
	echo "🌎 Found URL: $hugging_prefix$url";
	max_retry=10;
	ret_code=1;
	while [[ $ret_code != 0 ]]; do 
		set -x;
		curl -C - -L -O "$hugging_prefix$url"; 
		ret_code=$?;
		set +x;
		[[ $ret_code == 0 ]] && echo "✅ Download Completed: $(basename $url)" && break;

		max_retry=$((max_retry-1));
		[[ $max_retry == 0 ]] && echo "🚫 Download still FAILED: $url" && break;
		echo "⚠️ Download failed. Retrying with continuous download(retry $max_retry remains)."
	done
done
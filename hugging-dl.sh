#!/bin/bash

# Auto download HuggineFace files with curl
hugging_prefix="https://huggingface.co";

hugging_url=$1;
output_dir=$2;
[[ -z "$output_dir" ]] && output_dir='.';

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
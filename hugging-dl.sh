#!/bin/bash

VERSION=0.1

# Read all options from command line, supported options:
# 1. -h, --help: Print help message and exit.
# 2. -v, --version: Print version and exit.
# r. -t, --token: Set Huggingface access token for authentication, which can be created from [https://huggingface.co/settings/tokens].
hugging_url_or_path="";
path_to_save_model="";
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            echo "Usage: hugging-dl.sh [model_path|model_url] [output_dir]";
            echo "";
            echo "Options:";
            echo "  -h, --help: Print help message and exit.";
            echo "  -v, --version: Print version and exit.";
            echo "  -t, --token: Set Huggingface access token for authentication, which can be created from [https://huggingface.co/settings/tokens]";
            echo "";
            echo "Example:"
            echo "  hugging-dl.sh meta-llama/Llama-2-70b-chat-hf /path/to/save/model";
            echo "  hugging-dl.sh https://huggingface.co/meta-llama/Llama-2-70b-chat-hf /path/to/save/model";
            echo "";
            echo "1. You can directly copy the [model_path] from the model card page, such as [meta-llama/Llama-2-70b-chat-hf]."
            echo "2. The [model_url] is full URL of the model such as [https://huggingface.co/meta-llama/Llama-2-70b-chat-hf]."
            echo "3. The [output_dir] is the path to save the files of model, if not specified the default path will be the name of the [model_path]."
            echo "";
            echo "For more information, please visit: https://github.com/wsvn53/hugging-dl"
            exit 0;
            ;;
        -v|--version)
            echo "hugging-dl version: $VERSION";
            exit 0;
            ;;
        -t|--token)
            token=$2;
            shift;
            shift;
            ;;
        *)
            # The first free option is the model url or repo path
            hugging_url_or_path=$1;
            shift;
            # The second free option is the output dir
            path_to_save_model=$1;
            shift;
            ;;
    esac
done

# Required jq or python to parse json
which jq>/dev/null || which python3 2>/dev/null || {
    echo "[ERROR] No 'jq' and 'python3' command found, please install 'jq' or 'python3' first!";
    exit 1;
}

# Read first free option as model url
[[ -z "$hugging_url_or_path" ]] && echo "[FAILED] No huggingface model url or repo path specified!" && exit 2;
[[ "$hugging_url_or_path" != http* ]] && hugging_url_or_path="https://huggingface.co/$hugging_url_or_path";
echo "🤗 Starting download Huggingface model from url: $hugging_url_or_path";

# Detect Huggingface host [huggingface.co] for assemble API url
hugging_proto=$(echo "$hugging_url_or_path" | cut -d/ -f1);
hugging_host=$(echo "$hugging_url_or_path" | cut -d/ -f3);
hugging_api_prefix="$hugging_proto//$hugging_host/api/models";
hugging_api_suffix="tree/main";
echo "→ Using Huggingface API prefix: $hugging_api_prefix/../$hugging_api_suffix";

# Detect path to save model files
[[ -z "$path_to_save_model" ]] && path_to_save_model=$(basename "$hugging_url_or_path");
echo "→ Path to save model files: $path_to_save_model";
[[ -d "$path_to_save_model" ]] || mkdir -p "$path_to_save_model";
cd "$output_dir" || {
    echo "[ERROR] Can't change directory to $path_to_save_model, please check permissions.";
    exit 3;
}

# Detect model path from huggingface url
# shellcheck disable=SC2001
hugging_model_root_path="$(echo "$hugging_url_or_path" | sed "s#$hugging_proto//$hugging_host/##g")";
hugging_model_api_url="$hugging_api_prefix/$hugging_model_root_path/$hugging_api_suffix";
echo "→ Huggingface API url for $hugging_model_root_path: $hugging_model_api_url";

# Function to parse value from json
parse_json_value() {
    local json_data=$1;
    local key=$2;

    # Using jq to parse json if installed
    which jq>/dev/null && echo "$json_data" | jq ".$key" --raw-output --compact-output 2>/dev/null && return 0;
    # Alternatively, use python3 to parse path
    python -c "import json; import sys; data=json.loads('$json_data'); print(data['$key']) if '$key' != '[]' else [print(item) for item in data]"  2>/dev/null;
    # shellcheck disable=SC2181
    [[ $? != 0 ]] && printf "[ERROR] Load model files FAILED, please check the JSON data:\n%s\n" "$json_data" 1>&2 && \
        printf "\n[Note] If you are downloading a private model, you may need to set an access token for downloading which can be created from [https://huggingface.co/settings/tokens].\n" 1>&2;
}

# Function to download file
download_file() {
    local filename=$1;
	local file_url="$hugging_proto//$hugging_host$hugging_path/$hugging_model_root_path/resolve/main/$filename";

	echo "⬇️Downloading [$filename] from [$file_url]";
	local max_retry=20;
	local ret_code=1;
	while [[ $ret_code != 0 ]]; do
		echo "→ curl -C - -L -o '$filename' \"$file_url\"";
		curl -C - -H "Authorization: Bearer $token" -L -o "$filename" "$file_url";
		ret_code=$?;
		[[ $ret_code == 0 ]] && echo "✅ Download Completed [$filename]" && break;

		max_retry=$((max_retry-1));
		[[ $max_retry == 0 ]] && echo "[ERROR] Download failed: $file_url" && break;
		echo "⚠️ Download failed. Retrying with continuous download(retry $max_retry remains)."
		sleep 3;
	done
}

# Function to read download path from huggingface api url
download_model_files() {
    local current_path=$1;
    local model_api_url="$hugging_model_api_url";
    [[ ! -z "$current_path" ]] && {
        model_api_url="$hugging_model_api_url$current_path";
        echo "→ Downloading: [$current_path] from [$model_api_url]";
        [[ ! -d ".$current_path" ]] && mkdir -p ".$current_path";
    }
    local model_data=$(curl -s -H "Authorization: Bearer $token" "$model_api_url");
    # shellcheck disable=SC2162
    parse_json_value "$model_data" "[]" | while read json_line; do
        local file_type=$(parse_json_value "$json_line" "type");
        local file_path=$(parse_json_value "$json_line" "path");

        [[ "$file_type" == "directory" ]] && {
            # Download files in sub directory
            download_model_files "$current_path/$file_path";
        }

        [[ "$file_type" == "file" ]] && {
            # Download model file
            download_file "$file_path";
        }
    done
}

# Starting download
cd "$path_to_save_model";
download_model_files;

#!/bin/bash

# by Qwen3

# 设置默认参数
INPUT_DIR="static"
OUTPUT_DIR="static_compressed"

# 如果提供了参数，则使用参数值
if [ $# -ge 1 ]; then
    INPUT_DIR="$1"
fi
if [ $# -ge 2 ]; then
    OUTPUT_DIR="$2"
fi

# 转换为绝对路径（解决路径计算错误）
INPUT_DIR_ABS=$(realpath -m "$INPUT_DIR" 2>/dev/null || readlink -f "$INPUT_DIR" 2>/dev/null || echo "$INPUT_DIR")
OUTPUT_DIR_ABS=$(realpath -m "$OUTPUT_DIR" 2>/dev/null || readlink -f "$OUTPUT_DIR" 2>/dev/null || echo "$OUTPUT_DIR")

# 确保路径以 / 结尾（避免路径拼接错误）
INPUT_DIR_ABS="${INPUT_DIR_ABS%/}/"
OUTPUT_DIR_ABS="${OUTPUT_DIR_ABS%/}/"

# 创建输出目录
mkdir -p "$OUTPUT_DIR_ABS"

# 处理所有图片文件
find "$INPUT_DIR_ABS" -type f \( -iname "*.jpg" -o -iname "*.png" \) -print0 | while IFS= read -r -d $'\0' file; do
    # 安全计算相对路径（避免 realpath 兼容性问题）
    rel_path="${file#$INPUT_DIR_ABS}"

    # 创建目标路径（替换扩展名为.webp）
    target_path="${OUTPUT_DIR_ABS}${rel_path%.*}.webp"

    # 确保目标目录存在
    mkdir -p "$(dirname "$target_path")"

    # 转换图片（关键修复：添加 -nostdin 避免交互模式）
    echo "Converting: $file -> $target_path"
    if ! ffmpeg -nostdin -hide_banner -y -i "$file" -c:v libwebp -preset picture "$target_path" 2>/dev/null; then
        echo "  [ERROR] Failed to convert $file" >&2
    fi
done

# ffmpeg -hide_banner -i "$file" -c:v libx265 -crf 23 -preset medium "$output_file"

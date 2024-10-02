# by 通义千问

# 指定要处理的目录
input_dir="pending/"

# 使用 find 命令找到目录及其子目录中的所有文件，并存储到一个数组中
mapfile -t files < <(find "$input_dir" -type f)

# 遍历文件数组
for file in "${files[@]}"; do
    # 构建输出文件路径，添加 '_compressed' 后缀
    base_name=$(basename "$file")
    output_file="done/${base_name%.*}.jpg"

    # 使用 FFmpeg 进行压缩；qscale=15；crf=23
    ffmpeg -hide_banner -i "$file" -qscale 15 -preset medium "$output_file"
    # ffmpeg -hide_banner -i "$file" -c:v libx265 -crf 23 -preset medium "$output_file"
done

echo "压缩完成。"
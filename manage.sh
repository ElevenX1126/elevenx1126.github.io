#!/bin/bash

# 博客文章目录
POSTS_DIR="source/_posts"

# 1. 获取所有未推送到远端的文件列表（包括未追踪和未推送的提交）
# git cherry 可以列出未 push 的 commit，git ls-files --others 可以列出未 add 的文件
unpushed_files=$(git cherry -v origin/main 2>/dev/null | awk '{print $NF}' || echo "")
untracked_files=$(git ls-files --others --exclude-standard)
staged_files=$(git diff --name-only --cached)
modified_files=$(git diff --name-only)

# 汇总所有“变动中”的文件名
all_changes="$unpushed_files $untracked_files $staged_files $modified_files"

# 2. 定义处理列表的函数
# 遍历文件，如果在变动列表中，则加上 *
list_files_with_tags() {
    ls -t "$POSTS_DIR"/*.md | while read -r file; do
        relative_path=${file}
        # 检查该文件是否在变动汇总里
        if echo "$all_changes" | grep -q "$(basename "$file")"; then
            echo "$file *"
        else
            echo "$file"
        fi
    done
}

# 3. 使用 fzf 进行选择
if ! command -v fzf &> /dev/null; then
    echo "提示：请安装 fzf 以获得最佳体验 (brew install fzf)"
    selected_entry=$(list_files_with_tags | head -n 20)
else
    # fzf 处理带标记的行，最后再把末尾的 * 删掉还原成路径
    selected_entry=$(list_files_with_tags | fzf --preview "head -n 20 {1}" --height 50% --reverse --header "带 * 的文件表示本地有改动或未推送")
fi

# 4. 提取真实的文件路径（去掉末尾的 * 和空格）
files=$(echo "$selected_entry" | sed 's/ \*$//')

# 5. 判断是否选择了文件
if [ -z "$files" ]; then
    echo "已取消操作。"
    exit 0
fi

echo "正在打开: $files"
open -a "Typora" "$files"

# 6. 询问是否同步
echo "---------------------------------------"
read -p "编辑完成后，是否现在同步到 GitHub? (y/n): " confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    git add .
    filename=$(basename "$files")
    git commit -m "update: $filename"
    git push origin main
    echo "✅ 发布完成！"
else
    echo "已保存修改。"
fi
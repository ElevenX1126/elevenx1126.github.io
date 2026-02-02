#!/bin/bash
set -e

# 配置区域
POSTS_DIR="source/_posts"
TYPORA_APP="Typora"

# 检查 fzf 是否安装
if ! command -v fzf &> /dev/null; then
    echo "请先安装 fzf 以获得最佳体验: brew install fzf"
    exit 1
fi

# 函数：Git 同步
sync_github() {
    local msg=$1
    echo "---------------------------------------"
    read -p "是否同步到 GitHub 发布？(y/n): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        git add .
        git commit -m "$msg"
        git push origin main
        echo "✅ 同步完成！"
    else
        echo "📦 已保存本地内容（下次列表将显示 * 标记）。"
    fi
}

# 菜单 1：新建文章
create_post() {
    read -p "请输入博文标题: " title
    if [ -z "$title" ]; then return; fi

    date_prefix=$(date +%Y-%m-%d)
    slug_title=$(echo "$title" | tr ' ' '-')
    filename="${date_prefix}-${slug_title}"

    echo "正在创建..."
    hexo new post "$title" --slug "$filename"
    filepath="${POSTS_DIR}/${filename}.md"

    open -a "$TYPORA_APP" "$filepath"
    sync_github "feat: publish $title"
}

# 菜单 2：管理文章
manage_posts() {
    # 获取所有待提交/未推送的文件列表（?? 为新文件，M 为已修改）
    local unpushed_files=$(git status --porcelain "$POSTS_DIR" | awk '{print $2}')

    # 生成带标记的列表
    # 如果文件在 unpushed_files 中，前面加 *，否则加空格对齐
    local list_content=""
    for file in $(ls -t "$POSTS_DIR"/*.md); do
        if echo "$unpushed_files" | grep -q "$file"; then
            list_content="${list_content}* $file\n"
        else
            list_content="${list_content}  $file\n"
        fi
    done

    # 使用 fzf 选择文章
    # 使用 --with-nth 2.. 隐藏掉用于逻辑判断的 * 标记，保持界面整洁，或者直接显示出来
    local selected=$(echo -e "$list_content" | fzf \
        --header "回车:修改 | Ctrl-P:直接发布 | (* 表示有本地改动未推送)" \
        --expect="ctrl-p" \
        --preview "head -n 15 {2}" --height 80% --reverse)

    key=$(echo "$selected" | sed -n '1p')
    # 提取选中的路径（去掉开头的 * 或空格）
    target=$(echo "$selected" | sed -n '2p' | awk '{print $2}')

    if [ -z "$target" ]; then return; fi

    if [ "$key" == "ctrl-p" ]; then
        filename=$(basename "$target")
        echo "🚀 准备直接发布: $filename"
        sync_github "style: manual publish $filename"
    else
        open -a "$TYPORA_APP" "$target"
        filename=$(basename "$target")
        sync_github "fix: update $filename"
    fi
}

# 主菜单界面
clear
echo "--- 许多的博客管理系统 ---"
echo "1) 🆕 新建博文 (New Post)"
echo "2) 📂 管理/直接发布 (List & Manage)"
echo "q) 退出 (Quit)"
echo "--------------------------"
read -p "请选择操作: " opt

case $opt in
    1) create_post ;;
    2) manage_posts ;;
    q) exit 0 ;;
    *) echo "无效选项"; sleep 1; exec $0 ;;
esac
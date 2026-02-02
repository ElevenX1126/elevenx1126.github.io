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

# 函数：Git 同步 (已修改：支持定向同步单个文件)
sync_github() {
    local target_file=$1  # 接收目标文件路径
    local msg=$2
    echo "---------------------------------------"
    echo "🎯 目标: $(basename "$target_file")"
    read -p "是否同步到 GitHub 发布该文章？(y/n): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        # 关键修改：只 add 选中的文件，不影响其他 * 标记的文件
        git add "$target_file"
        
        # 检查是否有内容需要提交
        if git diff --cached --quiet; then
            echo "提示：内容无变化，无需发布。"
        else
            git commit -m "$msg"
            git push origin main
            echo "✅ 该文章发布完成！"
        fi
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
    # 调用同步函数并传入当前文件路径
    sync_github "$filepath" "feat: publish $title"
}

# 菜单 2：管理文章 (保留 * 标记逻辑)
manage_posts() {
    # 获取所有待提交/未推送的文件列表
    local unpushed_files=$(git status --porcelain "$POSTS_DIR" | awk '{print $2}')

    # 生成带标记的列表 (严格保留原有逻辑)
    local list_content=""
    for file in $(ls -t "$POSTS_DIR"/*.md); do
        if echo "$unpushed_files" | grep -q "$file"; then
            list_content="${list_content}* $file\n"
        else
            list_content="${list_content}  $file\n"
        fi
    done

    # 使用 fzf 选择文章
    local selected=$(echo -e "$list_content" | fzf \
        --header "Ctrl-D:删除 | Ctrl-P:直接发布 | (* 表示有本地改动未推送)" \
        --expect="ctrl-p,ctrl-d" \
        --preview "bat --color=always --line-range :15 {-1}" --height 80% --reverse)

    key=$(echo "$selected" | sed -n '1p')
    target=$(echo "$selected" | sed -n '2p' | awk '{print $NF}')

    if [ -z "$target" ]; then return; fi
    local filename=$(basename "$target")

    case "$key" in
        "ctrl-d")
            # --- 删除逻辑 ---
            echo -e "\n❗ 确定要删除文章吗？: $filename"
            read -p "此操作不可逆，请输入 (y/n): " confirm
            if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                git rm "$target"
                git commit -m "fix: delete post $filename"
                git push origin main
                echo "✅ GitHub 同步成功。"
            else
                echo "✋ 已取消删除。"
            fi
            ;;
            
        "ctrl-p")
            # --- 发布逻辑 ---
            echo "🚀 准备直接发布: $filename"
            sync_github "$target" "style: manual publish $filename"
            ;;
            
        *)
            # --- 默认编辑逻辑 ---
            open -a "$TYPORA_APP" "$target"
            sync_github "$target" "fix: update $filename"
            ;;
    esac
}

# 主菜单
while true; do
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
        *) echo "无效选项"; sleep 1 ;;
    esac
done
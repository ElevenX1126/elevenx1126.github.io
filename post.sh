#!/bin/bash

# 1. 获取输入标题
echo "--- Hexo 快捷发布脚本 ---"
read -p "请输入博文标题 (Title): " title

if [ -z "$title" ]; then
    echo "错误：标题不能为空！"
    exit 1
fi

# 2. 执行 hexo new 并捕获生成的文件路径
# Hexo 会返回类似 "INFO  Created: ~/blog/source/_posts/test.md" 的提示
filepath=$(hexo new "$title" | grep -oE "source/_posts/.*\.md")

if [ -z "$filepath" ]; then
    echo "错误：Hexo 文件创建失败。"
    exit 1
fi

echo "成功创建：$filepath"

# 3. 使用 Typora 打开该文件
# 如果你是 macOS:
open -a "Typora" "$filepath"

# 如果你是 Windows (Git Bash), 请取消下面这行的注释，并注释掉上面的 macOS 命令:
# "/c/Program Files/Typora/Typora.exe" "$filepath"

# 4. 等待编辑并同步
echo "---------------------------------------"
echo "Typora 已打开，请在编辑器中完成内容编写。"
echo "编写完成后，保存文件并回到终端按回车 [Enter] 开始同步..."
read -p "准备好同步了吗？" confirm

# 5. 执行 Git 同步
echo "正在推送到 GitHub..."
git add .
git commit -m "feat: publish new post - $title"
git push origin main # 确保你这里的分支名是 main

echo "---------------------------------------"
echo "✅ 发布完成！"
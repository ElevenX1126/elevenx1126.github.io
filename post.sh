#!/bin/bash

echo "--- Hexo 快捷发布脚本---"
read -p "请输入博文标题: " title

if [ -z "$title" ]; then
    echo "错误：标题不能为空！"
    exit 1
fi

# 1. 生成日期前缀和文件名
date_prefix=$(date +%Y-%m-%d)
# 将标题中的空格替换为连字符，方便作为文件名
slug_title=$(echo "$title" | tr ' ' '-')
filename="${date_prefix}-${slug_title}"

# 2. 创建文章
# --slug 参数可以指定生成的文件名，而文章内的 title 依然使用引号内的原词
echo "正在创建文章..."
hexo new post "$title" --slug "$filename"

# 3. 定位文件路径
filepath="source/_posts/${filename}.md"

if [ ! -f "$filepath" ]; then
    echo "错误：无法找到生成的文件 $filepath"
    exit 1
fi

echo "成功创建：$filepath"

# 4. 使用 Typora 打开
open -a "Typora" "$filepath"

# 5. 等待编辑并同步
echo "---------------------------------------"
echo "编写完成后，保存并回到终端按回车 [Enter] 开始同步..."
read -p "准备好同步了吗？" confirm

# 6. Git 同步
git add .
git commit -m "feat: publish $title"
git push origin main

echo "✅ 发布完成！"
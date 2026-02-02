---
title: test
date: 2026-02-01 17:21:36
categories:
  - 随笔
tags:
  - 人生道理
  - 复盘总结
category_bar: true   //必填
math: true
---

this is a test

```c++
class Solution {
public:
    vector<vector<string>> groupAnagrams(vector<string>& strs) {
        vector<int> v1 ={3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97,101,103};
        unordered_map<unsigned long long, vector<string>> m1;
        for(auto it: strs)
        {
            unsigned long long temp = 1;
            for(auto ch:it)
            {
                temp*=v1[ch-'a'];
            }
            m1[temp].emplace_back(it);
        }
        vector<vector<string>> ans;
        for(auto &[x,y]: m1)
        {
            ans.emplace_back(y);
        }
        return ans;
    }
};
```

<p class="note note-primary">标签</p>

`1111`

{% fold info @title %}
需要折叠的一段内容，支持 markdown
{% endfold %}

$Fitness = 1/3 [σ(\Delta loss) + σ(\Delta benchmark) + LLMjudge]$

$E=mc^2$

$\frac{\partial L}{\partial W_{xh}} = \underbrace{\frac{\partial L}{\partial y_2} \frac{\partial y_2}{\partial h_2} \frac{\partial h_2}{\partial W_{xh}}}_{\text{第2步的直接贡献}} + \underbrace{\frac{\partial L}{\partial y_2} \frac{\partial y_2}{\partial h_2} \frac{\partial h_2}{\partial h_1} \frac{\partial h_1}{\partial W_{xh}}}_{\text{倒推回第1步的间接贡献}}$

![](https://cdn.statically.io/gh/ElevenX1126/blog-assets/main/images2026/02/20260202151030.png)



![](https://cdn.statically.io/gh/ElevenX1126/blog-assets/main/images2026/02/20260202172302.png)



# 这是一级标题

## 这是二级标题

### 这是三级标题

#### 这是四级标题



{% cb 这是一个勾选框%}




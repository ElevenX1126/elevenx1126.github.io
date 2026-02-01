---
title: test
date: 2026-02-01 17:21:36
categories:
  - 随笔
tags:
  - 人生道理
  - 复盘总结
category_bar: true   //必填
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

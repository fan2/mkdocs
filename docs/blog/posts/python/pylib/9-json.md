---
title: python中的json处理
authors:
  - xman
date:
    created: 2019-12-06T09:20:00
categories:
    - python
tags:
    - json
comments: true
---

本文简单梳理了 python 中的 json 处理惯用法。

<!-- more -->

[json — JSON encoder and decoder](https://docs.python.org/3/library/json.html)
[json --- JSON 编码和解码器](https://docs.python.org/zh-cn/3/library/json.html)

[JSON](https://www.json.org/json-en.html) (JavaScript Object Notation)，由 RFC 7159 (它取代了 RFC 4627) 和 ECMA-404 指定，是一个受 JavaScript 的对象字面值句法启发的轻量级数据交换格式，尽管它不仅仅是一个严格意义上的 JavaScript 的子集 1。

- [Python3 JSON 数据解析](https://www.w3cschool.cn/python3/python3-json.html)
- [使用Python读取、写入和解析JSON](https://cloud.tencent.com/developer/article/1654900)
- [Working With JSON Data in Python](https://realpython.com/python-json/)

Python3 中可以使用 json 模块来对 JSON 数据进行编解码，它包含了两个函数：

- json.dumps(): 对数据进行编码。
- json.loads(): 对数据进行解码。

## dumps(dict -> json_str)

以下实例演示了将 Python 数据结构（dict）转换为 JSON 对象：

```Python
#!/usr/bin/env python3

import json

# Python 字典类型转换为 JSON 对象
data = {
    'no' : 1,
    'name' : 'W3CSchool',
    'url' : 'http://www.w3cschool.cn'
}

json_str = json.dumps(data)
print ("Python 原始数据：", repr(data))
print ("JSON 对象：", json_str)
```

## dump(dict -> json_file)

`json.dump()` 方法可用于将Python字典写入JSON文件。

句法：

```Python
json.dump（dict，file_pointer）
```

## loads(json_str -> dict)

接着以上实例，我们可以将一个JSON编码的字符串转换回一个Python数据结构：

```Python
#!/usr/bin/env python3

import json

# Python 字典类型转换为 JSON 对象
data1 = {
    'no' : 1,
    'name' : 'W3CSchool',
    'url' : 'http://www.w3cschool.cn'
}

json_str = json.dumps(data1)
print ("Python 原始数据：", repr(data1))
print ("JSON 对象：", json_str)

# 将 JSON 对象转换为 Python 字典
data2 = json.loads(json_str)
print ("data2['name']: ", data2['name'])
print ("data2['url']: ", data2['url'])
```

## load(json_file -> dict)

`json.load()` 方法可用于从JSON文件读取为Python字典对象。

```Shell
>>> with open("test.json", "r") as read_file:
...     data = json.load(read_file)
...
>>> type(data)
<class 'dict'>
```

## requests

以下是使用 [requests](https://requests.readthedocs.io/en/latest/) post 发送和接收json的代码片段：

```Python
import requests
import json

headers = {'Content-Type': 'application/json'}
content = {"no": 1, "name": "W3CSchool", "url": "http://www.w3cschool.cn"}
payload = {
  'msgtype': 'markdown',
  'markdown': {
    'content': json.dumps(content)
  }
}
rsp = requests.request("POST", robot_url, headers=headers, json=payload)
rspJson = json.loads(rsp.text)  # rsp.json()
print('push_alarm rsp:', rspJson)
if rspJson['errcode'] != 0 or rsp.status_code != 200:
    print(f"发送提醒消息失败 接口状态码{rsp.status_code}"
          f"code: {rspJson['errcode']}"
          f"msg: {rspJson['errmsg']}")
```

## json.tool

对于压缩/转义的 JSON 字符串，可以在以下网站进行格式化或解析转换。

- [JSON在线解析及格式化验证](https://www.json.cn/)：支持在线解析和压缩转义。
- [JSON解析格式化工具](https://www.sojson.com/)：支持校验/格式化、压缩/转义。
- [JSON格式化查看工具](https://www.baidufe.com/fehelper/json-format/index.html)：支持对 JSON 进行压缩，以及对压缩（转义）的JSON字符串进行还原。

macOS/Linux 下还可以安装 `jq` 命令行工具，将压缩/转义的json字符串转换为格式化的 JSON 对象。

[jq](https://stedolan.github.io/jq/) is a lightweight and flexible command-line JSON processor.

---

Using `json.tool` from the shell to validate and pretty-print:

```Shell
$ echo '{"json":"obj"}' | python3 -m json.tool
{
    "json": "obj"
}
```

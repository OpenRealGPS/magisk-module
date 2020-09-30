# OpenRealGPS Core

## 使用说明

1. 安装 [Magisk](https://github.com/topjohnwu/Magisk) v20.0 或以上版本
2. 下载并安装 [OpenRealGPS Core Magisk module](https://github.com/OpenRealGPS/magisk-module/releases)
3. 阅读以下注意事项并激活模块

## 注意事项

本模块涉及系统底层文件修改，有较高风险导致系统无法启动，本模块不对任何可能造成的后果负责。在安装模块前，请对设备进行完整备份。不建议在常用设备上安装及使用本模块。

强烈建议首先安装带有 ADB 和 Shell 功能的第三方 Recovery (如 TWRP)。当系统无法启动时，可通过 Recovery 禁用模块，操作方式为在 Shell 中执行 `touch /data/adb/modules/openrealgps/disable`

若已阅读以上事项并接受风险，请在模块目录下创建一个名为 `i_have_read_the_warning` (区分大小写) 的文件以激活模块。模块的激活可在一个具备 root 权限的 shell 中执行：`touch /data/adb/modules/openrealgps/i_have_read_the_warning`

## API

模块将在本地启动一个 HTTP 端口用于提供 API 交互，详见 [API 文档](API.md)

## License

MIT License

Copyright (c) 2020 OpenRealGPS Project

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

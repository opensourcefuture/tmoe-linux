# T Moe

化繁为简，让 gnu/linux 的乐趣触手可及。

## 1. 目录

### 1.1. 主要

| 章节                    | 简介                           | 文件      |
| ----------------------- | ------------------------------ | --------- |
| 序章前篇                | 用简短的说明带您领略其中的魅力 | lite.md   |
| [序章后篇](./readme.md) | 历史与发展                     | readme.md |
| [第一章](./1.md)        | 容器的安装与配置               | 1.md      |
| [第二章](./2.md)        | 错误处理                       | 2.md      |
| [第三章](./3.md)        | 介绍 vscode & haskell 等容器   | 3.md      |

### 1.2. 本章

中文 | [English](../../../Readme.md)

- [1. 目录](#1-目录)
  - [1.1. 主要](#11-主要)
  - [1.2. 本章](#12-本章)
- [2. 快速上手](#2-快速上手)
  - [2.1. 方法](#21-方法)
  - [2.2. 有问题?](#22-有问题)
  - [2.3. 我可以干什么?](#23-我可以干什么)
- [3. 翻页](#3-翻页)

## 2. 快速上手

### 2.1. 方法

| 方法  | 工具  | 条件                                                                                   | 命令                                       |
| ----- | ----- | -------------------------------------------------------------------------------------- | ------------------------------------------ |
| ~~1~~ | cargo | ~~you are using `rustc` **nightly**~~ (暂时不可用, `tmm`(稳定版) 将于 2023 年之前发布) | ~~`cargo install tmm`~~                    |
| 2     | curl  | 您已经安装了 `curl`, 并且可以访问 github                                               | `. <(curl -L git.io/linux.sh)`             |
| 3     | curl  | 您无法访问 github                                                                      | `. <(curl -L gitee.com/mo2/linux/raw/2/2)` |
| 4     | curl  | 您记不住上面的链接，或以上方法都出错了                                                 | `curl -Lo l l.tmoe.me; sh l`               |

<!--  | 1     | cargo                                                                                                                                 | you have `cargo` installed                  | `cargo install tmoe` | -->

### 2.2. 有问题?

有问题一定要问哦！不能憋坏了。  
您可以提 [issue](https://github.com/2moe/tmoe-linux/issues/new/choose)，也可以在 **discussions** 里进行交流和讨论。

您如果无法访问 GitHub 的话，那就前往 [gitee](https://gitee.com/mo2/linux/issues) 反馈吧！

### 2.3. 我可以干什么?

您可以在 arm64 设备上运行 gnome 或其它桌面。

![gnome40_p1](https://images.gitee.com/uploads/images/2021/0806/224412_07b5cd5b_5617340.png "Screenshot_20210806-221622.png")  
![gnome40_p2](https://images.gitee.com/uploads/images/2021/0806/224423_fa8285a5_5617340.png "Screenshot_20210806-222714.png")

## 3. 翻页

| 章节                  | 简介                                               | 文件      |
| --------------------- | -------------------------------------------------- | --------- |
| [下一章](./readme.md) | 简单了解不同版本之间的区别，并进一步细化安装的过程 | readme.md |
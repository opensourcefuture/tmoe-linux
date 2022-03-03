# T Moe

化繁為簡，讓 gnu/linux 的樂趣觸手可及。

## 1. 目錄

### 1.1. 主要

| 章節                    | 簡介                           | 文件      |
| ----------------------- | ------------------------------ | --------- |
| 序章前篇                | 用簡短的説明帶您領略其中的魅力 | lite.md   |
| [序章後篇](./readme.md) | 歷史與發展                     | readme.md |
| [第一章](./1.md)        | 容器的安裝與配置               | 1.md      |
| [第二章](./2.md)        | 錯誤處理                       | 2.md      |
| [第三章](./3.md)        | 介紹 vscode & haskell 等容器   | 3.md      |

### 1.2. 本章

中文 | [English](../../../Readme.md)

- [1. 目錄](#1-目錄)
  - [1.1. 主要](#11-主要)
  - [1.2. 本章](#12-本章)
- [2. 快速上手](#2-快速上手)
  - [2.1. 方法](#21-方法)
  - [2.2. 有問題?](#22-有問題)
  - [2.3. 我可以幹什麼?](#23-我可以幹什麼)
- [3. 翻頁](#3-翻頁)

## 2. 快速上手

### 2.1. 方法

| 方法  | 工具  | 條件                                                                                   | 命令                                       |
| ----- | ----- | -------------------------------------------------------------------------------------- | ------------------------------------------ |
| ~~1~~ | cargo | ~~you are using `rustc` **nightly**~~ (暫時不可用, `tmm`(穩定版) 將於 2023 年之前發佈) | ~~`cargo install tmm`~~                    |
| 2     | curl  | 您已經安裝了 `curl`, 並且可以訪問 github                                               | `. <(curl -L git.io/linux.sh)`             |
| 3     | curl  | 您無法訪問 github                                                                      | `. <(curl -L gitee.com/mo2/linux/raw/2/2)` |
| 4     | curl  | 您記不住上面的鏈接，或以上方法都出錯了                                                 | `curl -Lo l l.tmoe.me; sh l`               |

<!--  | 1     | cargo                                                                                                                                 | you have `cargo` installed                  | `cargo install tmoe` | -->

### 2.2. 有問題?

有問題一定要問哦！不能憋壞了。  
您可以提 [issue](https://github.com/2moe/tmoe-linux/issues/new/choose)，也可以在 **discussions** 裏進行交流和討論。

您如果無法訪問 GitHub 的話，那就前往 [gitee](https://gitee.com/mo2/linux/issues) 反饋吧！

### 2.3. 我可以幹什麼?

您可以在 arm64 設備上運行 gnome 或其它桌面。

![gnome40_p1](https://images.gitee.com/uploads/images/2021/0806/224412_07b5cd5b_5617340.png "Screenshot_20210806-221622.png")  
![gnome40_p2](https://images.gitee.com/uploads/images/2021/0806/224423_fa8285a5_5617340.png "Screenshot_20210806-222714.png")

## 3. 翻頁

| 章節                  | 簡介                                               | 文件      |
| --------------------- | -------------------------------------------------- | --------- |
| [下一章](./readme.md) | 簡單瞭解不同版本之間的區別，並進一步細化安裝的過程 | readme.md |
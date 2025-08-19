## 项目简介
Harmony-EcoGuardian (EviromentalApp) 是一个基于 HarmonyOS 开发的环保应用。该应用旨在提供与环境保护相关的功能，例如环保知识普及、环保活动参与等，帮助用户更好地了解和参与环保事业。

## 功能特性
- 环保知识库 ：提供丰富的环保知识。
- 环保活动 ：发布和参与环保志愿活动，如垃圾分类、植树造林等。
- 用户互动 ：用户可以分享环保心得，交流环保经验。
- 数据备份 ：支持应用数据的备份功能。
## 技术栈
- 开发语言 ：ArkTS (TypeScript)
- 开发框架 ：HarmonyOS SDK
- 构建工具 ：Hvigor
- 设备类型 ：主要针对手机设备进行开发。
## 安装与运行
### 前提条件
- 已安装 DevEco Studio。
- 已配置 HarmonyOS 开发环境。
## 项目结构
- AppScope/ : 应用的全局配置和资源，包括应用名称、图标等。
- entry/ : 应用的主模块，包含主要的业务逻辑和页面。
- entry/src/main/ets/entryability/EntryAbility.ets : 应用的入口能力。
- entry/src/main/ets/entrybackupability/EntryBackupAbility.ets : 应用的备份能力。
- entry/src/main/ets/pages/ : 存放应用的各个页面。
- entry/src/main/resources/ : 存放模块的资源文件，如图片、布局文件等。
- hvigorfile.ts : 构建脚本文件。
- oh-package.json5 : 项目的包管理配置文件。

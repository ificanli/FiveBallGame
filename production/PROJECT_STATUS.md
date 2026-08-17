# 《五球满贯》Steam 项目状态

更新时间：2026-08-17  
当前阶段：PREPRODUCTION / TOOLING  
主里程碑：M0 工具链与正式仓库  
里程碑状态：VERIFYING

## 已完成

- 正式仓库与目录建立；Git main 分支、Git LFS 本地 hooks/属性生效；
- Godot 4.7.1 stable (`a13da4feb`) 单一版本安装并锁定；
- 最小 Godot 工程可导入、无头启动；
- OpenSpec 1.9.0 初始化，doctor 通过，遥测关闭；
- GdUnit4 v6.2.0 vendored，Headless 示例 2/2 通过；
- Golden Replay M0 数据契约与占位案例可加载并输出结构化 JSON，未执行物理；
- Windows/Linux 空工程本地导出成功；Windows 导出包 Headless 冒烟通过；
- GitHub Actions CI 已配置为验证、测试、回放契约与双平台 Artifact；
- 权威规划与历史资料已复制并记录来源；
- 未开发正式物理、内容、Steamworks、联网或 MCP。

## 未完成 / 阻塞

- GitHub Actions 尚未真实运行：当前仓库未配置 remote，无法提供云端 run/Artifact 证据；
- 初始 Git commit 尚待合法作者身份可用；当前全局/仓库 `user.name`、`user.email` 均未配置；
- Linux 导出包已生成但未在 Linux 主机上启动；由 CI 承担后续平台验证；
- M0 独立 Reviewer 尚未执行。

## 当前证据

- `reports/m0-local-verification.log`：4.7.1、导入、启动与 Golden contract；
- `reports/gdunit.log`：2 cases / 0 failures；
- `reports/export-retry.log`：Windows/Linux export exit 0；
- `reports/m0-final-checks.log`：Windows build startup、OpenSpec doctor、LFS 与敏感文件审计；
- `production/M0_ACCEPTANCE_REPORT.md`：完整验收摘要。

## 下一决策

1. 配置 Git 作者身份并完成初始提交；
2. 配置仓库 remote 后推送并验证 GitHub Actions Artifact；
3. 完成 M0 Reviewer 后，将状态改为 `PASSED`；
4. M0 通过后只创建 `deterministic-physics-table` OpenSpec Change；未经用户 Gate P 批准不得进入 M1。

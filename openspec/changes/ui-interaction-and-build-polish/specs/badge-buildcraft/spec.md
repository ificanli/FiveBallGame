# badge-buildcraft Specification

## Purpose
M3.5 为现有 18 枚徽章补充中文说明与流派标签，不改动徽章的规则效果、触发条件与结算顺序。

## MODIFIED Requirements

### Requirement: Badge catalog is versioned, complete, and auditable
M3.5 SHALL 保持恰好 18 枚唯一 ID 的桌边徽章与三条打法结构不变；每枚徽章 SHALL 声明中文名称、中文说明（触发条件 + 效果 + 数值）、触发阶段、读取字段、效果类型和数值。徽章规则效果、触发条件与结算顺序 SHALL 与 M3 保持一致。

#### Scenario: Catalog audit runs
- **WHEN** 系统或 CI 加载徽章配置
- **THEN** SHALL 验证数量为 18、ID 唯一、本地化键（含中文说明）存在、效果参数有限且三条打法的角色覆盖完整

#### Scenario: Badge cannot affect a shot
- **WHEN** 某候选徽章只提供无条件固定分数且不改变选球、力度、撞库、连锁、功能墙、保留或爆仓判断
- **THEN** 该徽章 SHALL NOT 计入"改变击球判断"的 70% 验收数量

#### Scenario: Badge description key is missing
- **WHEN** 某徽章配置引用不存在或为空的中文说明键
- **THEN** 本地化审计 SHALL 失败并指出徽章 ID 与缺失键

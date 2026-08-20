class_name M35UiContentTest
extends GdUnitTestSuite


func test_every_badge_has_readable_chinese_description() -> void:
	for badge: Dictionary in BadgeCatalog.BADGES:
		var id := str(badge.id)
		var key := "badge.%s.desc" % id
		assert_bool(LocalizationZhCn.TEXT.has(key)).is_true()
		assert_bool(LocalizationZhCn.text(key).strip_edges().is_empty()).is_false()


func test_every_tool_has_readable_chinese_description() -> void:
	for tool: Dictionary in ToolCatalog.TOOLS:
		var id := str(tool.id)
		var key := "tool.%s.desc" % id
		assert_bool(LocalizationZhCn.TEXT.has(key)).is_true()
		assert_bool(LocalizationZhCn.text(key).strip_edges().is_empty()).is_false()


func test_build_and_role_labels_exist() -> void:
	for build in BuildIdentity.BUILD_IDS:
		assert_bool(LocalizationZhCn.TEXT.has(BuildIdentity.LABEL_KEYS[build])).is_true()
	for role in ["starter", "core", "amplifier", "finisher", "growth"]:
		assert_bool(LocalizationZhCn.TEXT.has("role.%s" % role)).is_true()


func test_build_identity_stays_out_of_rule_data() -> void:
	for badge: Dictionary in BadgeCatalog.BADGES:
		assert_bool(badge.has("visual_color")).is_false()
	for build in BuildIdentity.BUILD_IDS:
		assert_bool(BuildIdentity.COLORS.has(build)).is_true()
		assert_bool(BuildIdentity.LABEL_KEYS.has(build)).is_true()

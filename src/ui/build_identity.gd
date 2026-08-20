class_name BuildIdentity
extends RefCounted

## UI-only visual identity for the three build archetypes.
## These constants affect display only. They MUST NOT enter rule data,
## replay hashes, snapshots or settlement evidence.

const BUILD_IDS := ["pure_combo", "rail_chain", "wall_risk"]

const COLORS := {
	"pure_combo": Color("8fd7cf"),
	"rail_chain": Color("f5cf72"),
	"wall_risk": Color("e085c0"),
}

const LABEL_KEYS := {
	"pure_combo": "build.pure_combo",
	"rail_chain": "build.rail_chain",
	"wall_risk": "build.wall_risk",
}

static func color(build_id: String) -> Color:
	return COLORS.get(build_id, Color("9db1c4"))

static func label(build_id: String) -> String:
	return LocalizationZhCn.text(LABEL_KEYS.get(build_id, ""), build_id)

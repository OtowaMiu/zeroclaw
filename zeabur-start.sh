set -eu

ZC_DIR="${HOME:-/root}/.zeroclaw"
mkdir -p "$ZC_DIR/workspace"

# TELEGRAM_ALLOWED_USERS 例子：myusername,123456789（也可用 * 放行所有）
oldIFS="${IFS}"; IFS=,
set -- ${TELEGRAM_ALLOWED_USERS:?set TELEGRAM_ALLOWED_USERS}
IFS="${oldIFS}"
allowed_users_toml=""
for u in "$@"; do
  [ -n "$allowed_users_toml" ] && allowed_users_toml="$allowed_users_toml, "
  allowed_users_toml="${allowed_users_toml}\"${u}\""
done

cat > "$ZC_DIR/config.toml" <<TOML
workspace_dir = "$ZC_DIR/workspace"
config_path = "$ZC_DIR/config.toml"
api_key = "${ZEROCLAW_API_KEY:?set ZEROCLAW_API_KEY}"
default_provider = "${ZEROCLAW_PROVIDER:-openrouter}"
default_model = "${ZEROCLAW_MODEL:-anthropic/claude-sonnet-4-20250514}"
default_temperature = 0.7

[secrets]
encrypt = false

[gateway]
allow_public_bind = true
require_pairing = true

[channels_config.telegram]
bot_token = "${TELEGRAM_BOT_TOKEN:?set TELEGRAM_BOT_TOKEN}"
allowed_users = [${allowed_users_toml}]
TOML

exec /app/main daemon --host 0.0.0.0 --port "${PORT:-8080}"

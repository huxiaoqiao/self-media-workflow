#!/bin/bash

# 飞书交互卡片发送脚本
# 用法：./send-card.sh 图片路径 标题 内容 标签 笔记 ID

set -e

# 配置（从 ~/.openclaw/openclaw.json 读取）
APP_ID="cli_a93d321f76f89bc2"
APP_SECRET="jaHXE9P93dfeffcjkvr7MhbYiawyMXer"
RECEIVE_ID="ou_5f272e72aba67f5fb6ebd96cb458fd4a"

# 参数
IMAGE_PATH="$1"
TITLE="$2"
CONTENT="$3"
TAGS="$4"
NOTE_ID="$5"

if [ -z "$IMAGE_PATH" ] || [ -z "$TITLE" ]; then
  echo "❌ 用法：$0 <图片路径> <标题> <内容> <标签> <笔记 ID>"
  echo "示例：$0 /path/to/image.png '🎨 标题' '**内容**' '#标签' note1"
  exit 1
fi

echo "🚀 开始发送飞书交互卡片..."

# 1. 获取访问令牌
echo "📝 步骤 1/4: 获取访问令牌..."
TOKEN_RESPONSE=$(curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
  -H "Content-Type: application/json" \
  -d "{\"app_id\":\"$APP_ID\",\"app_secret\":\"$APP_SECRET\"}")

TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.tenant_access_token')

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
  echo "❌ 获取访问令牌失败：$TOKEN_RESPONSE"
  exit 1
fi

echo "✅ 获取访问令牌成功"

# 2. 上传图片
echo "📝 步骤 2/4: 上传图片..."
IMAGE_RESPONSE=$(curl -s -X POST "https://open.feishu.cn/open-apis/im/v1/images" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image_type=message" \
  -F "image=@$IMAGE_PATH")

IMAGE_KEY=$(echo "$IMAGE_RESPONSE" | jq -r '.data.image_key')

if [ "$IMAGE_KEY" = "null" ] || [ -z "$IMAGE_KEY" ]; then
  echo "❌ 上传图片失败：$IMAGE_RESPONSE"
  exit 1
fi

echo "✅ 上传图片成功：$IMAGE_KEY"

# 3. 构建卡片 JSON
echo "📝 步骤 3/4: 构建卡片内容..."

# 确定卡片颜色（根据笔记 ID）
TEMPLATE="blue"
if [[ "$NOTE_ID" == *"note2"* ]]; then
  TEMPLATE="red"
elif [[ "$NOTE_ID" == *"note3"* ]]; then
  TEMPLATE="green"
fi

CARD_CONTENT=$(cat <<EOF
{
  "config": {"wide_screen_mode": true},
  "header": {
    "template": "$TEMPLATE",
    "title": {"tag": "plain_text", "content": "$TITLE"}
  },
  "elements": [
    {"tag": "img", "img_key": "$IMAGE_KEY", "alt": {"tag": "plain_text", "content": "Cover Image"}},
    {"tag": "div", "text": {"tag": "lark_md", "content": "$CONTENT"}},
    {"tag": "hr"},
    {"tag": "note", "elements": [{"tag": "plain_text", "content": "$TAGS"}]},
    {"tag": "action", "actions": [
      {"tag": "button", "text": {"tag": "plain_text", "content": "✅ 通过"}, "type": "primary", "value": "approve_$NOTE_ID"},
      {"tag": "button", "text": {"tag": "plain_text", "content": "✏️ 修改"}, "type": "default", "value": "modify_$NOTE_ID"},
      {"tag": "button", "text": {"tag": "plain_text", "content": "❌ 重写"}, "type": "default", "value": "rewrite_$NOTE_ID"}
    ]}
  ]
}
EOF
)

# 4. 发送卡片
echo "📝 步骤 4/4: 发送卡片..."

CARD_CONTENT_STR=$(echo "$CARD_CONTENT" | jq -Rs .)

SEND_RESPONSE=$(curl -s -X POST "https://open.feishu.cn/open-apis/im/v1/messages?receive_id=$RECEIVE_ID&receive_id_type=open_id" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"msg_type\":\"interactive\",\"content\":$CARD_CONTENT_STR}")

MESSAGE_ID=$(echo "$SEND_RESPONSE" | jq -r '.data.message_id')

if [ "$MESSAGE_ID" = "null" ] || [ -z "$MESSAGE_ID" ]; then
  echo "❌ 发送卡片失败：$SEND_RESPONSE"
  exit 1
fi

echo "✅ 卡片发送成功！"
echo "📱 消息 ID: $MESSAGE_ID"
echo "🎨 标题：$TITLE"
echo "🏷️ 笔记 ID: $NOTE_ID"

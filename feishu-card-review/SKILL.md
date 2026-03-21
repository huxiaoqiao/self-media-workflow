---
name: feishu-card-review
description: 使用飞书交互式卡片发送内容审核请求和最终稿发布卡片，支持图片展示、结构化文案、可点击审核按钮（通过/修改/重写）和发布到小红书按钮。集成 Gemini 生图，支持修改/重写自动生成新图。适用于小红书笔记、文案、设计稿等内容的审核和发布流程。
homepage: https://github.com/openclaw/openclaw
metadata:
  {
    "openclaw":
      {
        "emoji": "🎨",
        "requires": { "bins": ["browser", "curl", "jq"] },
        "install": [],
      },
  }
---

# 飞书交互卡片审核 Skill（v2.0 简化版）

> **版本：** 2.0（简化版）  
> **更新时间：** 2026-03-20  
> **核心优化：** 一键直达，不要多级交互；集成 Gemini 生图，修改/重写自动生成新图

## 📋 简化版交互流程（v2.0）

**核心原则：一键直达，不要多级交互！**

| 按钮 | 直接操作 |
|------|---------|
| **✅ 通过** | 发送最终稿卡片（图片 + 完整文案 + 🍠发布按钮） |
| **✏️ 修改** | 修改原提示词 → Gemini 生成新图 → 发送新审核卡片 |
| **❌ 重写** | 全新主题 → Gemini 生成新图 → 发送新审核卡片 |

### 完整流程图

```
1️⃣ 审核卡片（蓝色，待审核）
   🖼️ 图片 + 📝 文案 + 🔘 按钮
   ↓
   用户点击按钮
   ↓
2️⃣ 根据操作直接反馈：
   
   ✅ 通过 → 最终稿卡片（绿色，🍠发布按钮）
   
   ✏️ 修改 → 反馈卡片（告知预计耗时）
            → 修改提示词 → Gemini 生图
            → 新审核卡片（修改版）
   
   ❌ 重写 → 反馈卡片（告知预计耗时）
            → 全新主题 → Gemini 生图
            → 新审核卡片（全新主题）
```

---

## 触发场景

### 审核卡片
- 用户要求发送审核卡片
- 需要发送带图片的结构化内容
- 需要可点击的审核按钮（通过/修改/重写）
- 用户说"用卡片发我"、"发审核卡片"等

### 发布卡片（最终稿）
- 审核通过后发送最终稿
- 需要"发布到小红书"按钮（拉起小红书 App）
- 需要展示完整文案方便复制
- 用户说"发最终稿"、"发发布卡片"等

### Gemini 生图集成
- 需要调用 Gemini 生成图片
- 支持修改/重写自动生成新图
- 自动从提示词库获取优质提示词

---

## 🔧 配置要求

### 飞书应用配置

在 `~/.openclaw/openclaw.json` 中配置飞书应用：

```json
{
  "channels": {
    "feishu": {
      "accounts": {
        "xiaohongshu-bot": {
          "appId": "cli_xxxxxxxx",
          "appSecret": "xxxxxxxxxxxxxxxxxxxx",
          "dmPolicy": "open",
          "allowFrom": ["*"]
        }
      }
    }
  }
}
```

### 必需权限

- `im:message:send_as_bot` - 发送消息
- `im:resource` - 上传图片

### Gemini 生图配置

- **工具**：OpenClaw browser 工具
- **目标**：https://gemini.google.com/app
- **提示词库**：`skills/gemini-prompts-library/SKILL.md`

---

## 完整流程（5 步）

### 卡片类型

#### 类型 A：审核卡片
- **Header**：蓝色/红色/绿色主题
- **图片**：展示封面图
- **内容**：精简文案（亮点 + 要点）
- **按钮**：✅ 通过 | ✏️ 修改 | ❌ 重写
- **用途**：内容审核阶段

#### 类型 B：发布卡片（最终稿）
- **Header**：带"✅ 最终稿"标识
- **图片**：展示封面图
- **内容**：完整文案（标题 + 正文 + 标签）
- **按钮**：🍠 发布到小红书
- **用途**：审核通过后发布

---

### 步骤 1：获取飞书应用配置

```bash
# 从 ~/.openclaw/openclaw.json 读取
appId="cli_a93d321f76f89bc2"
appSecret="jaHXE9P93dfeffcjkvr7MhbYiawyMXer"
```

### 步骤 2：获取访问令牌

```bash
curl -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
  -H "Content-Type: application/json" \
  -d "{
    \"app_id\": \"$appId\",
    \"app_secret\": \"$appSecret\"
  }"
```

**返回：**
```json
{"code":0,"tenant_access_token":"t-g1043idjWPV5VNZC6XXGAXECE7XJCDSRD5MH6HTM","expire":7200}
```

### 步骤 3：上传图片获取 img_key

```bash
curl -X POST "https://open.feishu.cn/open-apis/im/v1/images" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image_type=message" \
  -F "image=@/path/to/image.png"
```

**返回：**
```json
{"code":0,"data":{"image_key":"img_v3_02vt_xxxxx"},"msg":"success"}
```

### 步骤 4：构建卡片 JSON

```json
{
  "receive_id": "ou_xxxxxxxxxxxx",
  "msg_type": "interactive",
  "content": "{\"config\":{\"wide_screen_mode\":true},\"header\":{\"template\":\"blue\",\"title\":{\"tag\":\"plain_text\",\"content\":\"🎨 标题\"}},\"elements\":[{\"tag\":\"img\",\"img_key\":\"img_v3_xxxxx\"},{\"tag\":\"div\",\"text\":{\"tag\":\"lark_md\",\"content\":\"**正文内容**\"}},{\"tag\":\"note\",\"elements\":[{\"tag\":\"plain_text\",\"content\":\"#标签\"}]},{\"tag\":\"action\",\"actions\":[{\"tag\":\"button\",\"text\":{\"tag\":\"plain_text\",\"content\":\"✅ 通过\"},\"type\":\"primary\",\"value\":\"approve_note1\"},{\"tag\":\"button\",\"text\":{\"tag\":\"plain_text\",\"content\":\"✏️ 修改\"},\"type\":\"default\",\"value\":\"modify_note1\"},{\"tag\":\"button\",\"text\":{\"tag\":\"plain_text\",\"content\":\"❌ 重写\"},\"type\":\"default\",\"value\":\"rewrite_note1\"}]}]}"
}
```

### 步骤 5：发送卡片消息

```bash
curl -X POST "https://open.feishu.cn/open-apis/im/v1/messages?receive_id=OU_ID&receive_id_type=open_id&msg_type=interactive" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d @card-payload.json
```

---

### 发布卡片（最终稿）JSON 示例

```json
{
  "receive_id": "ou_xxxxxxxxxxxx",
  "msg_type": "interactive",
  "content": {
    "config": {"wide_screen_mode": true},
    "header": {
      "template": "blue",
      "title": {"tag": "plain_text", "content": "✅ 笔记一最终稿：春季流行色"}
    },
    "elements": [
      {
        "tag": "img",
        "img_key": "img_v3_xxxxx",
        "alt": {"tag": "plain_text", "content": "封面图"}
      },
      {
        "tag": "div",
        "text": {
          "tag": "lark_md",
          "content": "**🎨 标题：** 2026 春季最火配色！\n\n**✨ 5 个流行色：**\n• 柔雾粉\n• 薄荷绿\n• 奶油黄\n• 天空蓝\n• 薰衣草紫\n\n**💡 穿搭小 Tips：**\n• 全身不要超过 3 个颜色\n• 同色系渐变最显高\n• 亮色放上半身更衬肤色"
        }
      },
      {
        "tag": "hr"
      },
      {
        "tag": "note",
        "elements": [
          {"tag": "plain_text", "content": "#春季穿搭 #2026 流行色 #穿搭灵感"}
        ]
      },
      {
        "tag": "action",
        "actions": [
          {
            "tag": "button",
            "text": {"tag": "plain_text", "content": "🍠 发布到小红书"},
            "type": "primary",
            "multi_url": {
              "url": "https://creator.xiaohongshu.com",
              "android_url": "xhsdiscover://",
              "ios_url": "xhsdiscover://"
            }
          },
          {
            "tag": "button",
            "text": {"tag": "plain_text", "content": "📋 复制文案"},
            "type": "default",
            "value": "copy_note1"
          }
        ]
      }
    ]
  }
}
```

**关键点：**
- `multi_url` 支持多端跳转（PC/Android/iOS）
- `xhsdiscover://` Scheme 在移动端拉起小红书 App
- 完整文案直接展示在卡片中，用户长按即可复制

---

## 🎨 Gemini 生图集成流程

### 修改/重写按钮处理逻辑

```python
# 伪代码示例
def handle_button_click(action_value, original_prompt):
    if "approve" in action_value:
        # ✅ 通过 → 发送最终稿卡片
        send_final_draft()
    
    elif "modify" in action_value:
        # ✏️ 修改 → 修改提示词 → 生成新图 → 发送新审核卡片
        send_feedback_card("正在修改...", "约 60 秒")
        modified_prompt = modify_prompt(original_prompt)
        new_image_key = generate_with_gemini(modified_prompt)
        send_review_card(new_image_key, modified_prompt, "修改版")
    
    elif "rewrite" in action_value:
        # ❌ 重写 → 全新主题 → 生成新图 → 发送新审核卡片
        send_feedback_card("正在重写...", "约 60 秒")
        new_prompt = generate_new_topic()
        new_image_key = generate_with_gemini(new_prompt)
        send_review_card(new_image_key, new_prompt, "全新主题")
```

### Gemini 生图步骤

**1. 打开浏览器**
```bash
browser open url="https://gemini.google.com/app"
```

**2. 点击"制作图片"按钮**
```bash
browser snapshot refs="aria"
browser act click ref="e94" targetId="xxx"
```

**3. 输入提示词**
```bash
browser act type ref="e249" targetId="xxx" text="提示词内容"
```

**4. 点击发送**
```bash
browser act click ref="e269" targetId="xxx"
```

**5. 等待生成（约 45 秒）**
```bash
sleep 45
```

**6. 点击复制图片**
```bash
browser act click ref="e342" targetId="xxx"
```

**7. 等待剪贴板就绪**
```bash
sleep 10
```

**8. 保存剪贴板**
```bash
osascript -e "try" \
  -e "  set theData to the clipboard as «class PNGf»" \
  -e "  set fileName to \"/tmp/image.png\"" \
  -e "  set outFile to open for access POSIX file fileName with write permission" \
  -e "  write theData to outFile" \
  -e "  close access outFile" \
  -e "on error" \
  -e "end try"
```

**9. 上传飞书获取 img_key**
```bash
curl -X POST "https://open.feishu.cn/open-apis/im/v1/images" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image_type=message" \
  -F "image=@/tmp/image.png"
```

**10. 发送审核卡片**
```bash
curl -X POST "https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=open_id" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"receive_id":"ou_xxx","msg_type":"interactive","content":"{...}"}'
```

### 提示词修改策略

**修改版（调整部分元素）：**
```python
# 原提示词
original = "创作一张手绘风格的信息图卡片，比例为 9:16 竖版。背景为米色，春季流行色..."

# 修改后（调整颜色/主题）
modified = "创作一张手绘风格的信息图卡片，比例为 9:16 竖版。背景改为浅蓝色调，营造夏日清凉感。夏季流行色..."
```

**重写版（全新主题）：**
```python
# 原主题：春季/夏季流行色
# 新主题：冬季护肤攻略

new_prompt = "创作一张手绘风格的冬季护肤步骤指南信息图，比例为 9:16 竖版。暖色调背景..."
```

### 时间估算

| 步骤 | 耗时 |
|------|------|
| 打开浏览器 + 点击制作图片 | 5 秒 |
| 输入提示词 + 发送 | 5 秒 |
| 等待 Gemini 生成 | 45-60 秒 |
| 复制图片 + 保存剪贴板 | 15 秒 |
| 上传飞书 + 发送卡片 | 10 秒 |
| **总计** | **约 80-95 秒** |

---

## 📋 卡片元素详解

| 元素 | 字段 | 说明 |
|------|------|------|
| **header** | `template` | 卡片头部颜色（blue/red/green） |
| **header** | `title` | 卡片标题（带 emoji） |
| **img** | `img_key` | 图片标识（需先上传） |
| **div** | `text.tag` | `lark_md` 支持 Markdown |
| **hr** | - | 分隔线 |
| **note** | `elements[]` | 灰色提示文字（标签等） |
| **action** | `actions[]` | 按钮组 |
| **button** | `type` | `primary`（蓝色）或 `default` |
| **button** | `value` | 按钮点击返回值 |

---

## 完整执行脚本

**位置：** `skills/feishu-card-review/send-card.sh`

```bash
#!/bin/bash

# 配置
APP_ID="cli_a93d321f76f89bc2"
APP_SECRET="jaHXE9P93dfeffcjkvr7MhbYiawyMXer"
RECEIVE_ID="ou_5f272e72aba67f5fb6ebd96cb458fd4a"
IMAGE_PATH="$1"
TITLE="$2"
CONTENT="$3"
TAGS="$4"
NOTE_VALUE="$5"

# 1. 获取访问令牌
TOKEN=$(curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
  -H "Content-Type: application/json" \
  -d "{\"app_id\":\"$APP_ID\",\"app_secret\":\"$APP_SECRET\"}" | jq -r '.tenant_access_token')

echo "✅ 获取访问令牌成功"

# 2. 上传图片
IMAGE_KEY=$(curl -s -X POST "https://open.feishu.cn/open-apis/im/v1/images" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image_type=message" \
  -F "image=@$IMAGE_PATH" | jq -r '.data.image_key')

echo "✅ 上传图片成功：$IMAGE_KEY"

# 3. 构建卡片内容
CARD_CONTENT=$(cat <<EOF
{
  "config": {"wide_screen_mode": true},
  "header": {
    "template": "blue",
    "title": {"tag": "plain_text", "content": "$TITLE"}
  },
  "elements": [
    {"tag": "img", "img_key": "$IMAGE_KEY", "alt": {"tag": "plain_text", "content": "Cover"}},
    {"tag": "div", "text": {"tag": "lark_md", "content": "$CONTENT"}},
    {"tag": "hr"},
    {"tag": "note", "elements": [{"tag": "plain_text", "content": "$TAGS"}]},
    {"tag": "action", "actions": [
      {"tag": "button", "text": {"tag": "plain_text", "content": "✅ 通过"}, "type": "primary", "value": "approve_$NOTE_VALUE"},
      {"tag": "button", "text": {"tag": "plain_text", "content": "✏️ 修改"}, "type": "default", "value": "modify_$NOTE_VALUE"},
      {"tag": "button", "text": {"tag": "plain_text", "content": "❌ 重写"}, "type": "default", "value": "rewrite_$NOTE_VALUE"}
    ]}
  ]
}
EOF
)

# 4. 发送卡片
curl -X POST "https://open.feishu.cn/open-apis/im/v1/messages?receive_id=$RECEIVE_ID&receive_id_type=open_id&msg_type=interactive" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"content\":$(echo "$CARD_CONTENT" | jq -c .)}"

echo "✅ 卡片发送成功"
```

---

## 📖 使用示例

### 示例 1：发送审核卡片（简化版）

```bash
cd /Volumes/1TB/openclaw/xiaohongshu-bot/skills/feishu-card-review

./send-card.sh \
  "/path/to/image.png" \
  "🎨 小红书笔记审核 - 手绘信息图" \
  "**📌 标题：** 2026 春季流行色指南\n\n**✨ 3 个流行色：**\n• 柔雾粉 - 温柔显白\n• 薄荷绿 - 清新自然\n• 奶油黄 - 元气满满" \
  "#春季穿搭 #2026 流行色 #穿搭灵感" \
  "spring_colors_001"
```

### 示例 2：简化版交互流程（完整演示）

**步骤 1：发送审核卡片**
```
用户：帮我发一个审核卡片
↓
助手：发送审核卡片（蓝色主题）
🖼️ 图片 + 📝 文案 + 🔘 ✅通过 | ✏️修改 | ❌重写
```

**步骤 2：用户点击"✅ 通过"**
```
用户：点击"✅ 通过"按钮
↓
助手：立即发送最终稿卡片（绿色主题）
🟢 ✅ 最终稿：2026 春季流行色
📝 完整文案（方便复制）
🔘 🍠发布到小红书 | 📋复制文案
```

**步骤 3：用户点击"✏️ 修改"**
```
用户：点击"✏️ 修改"按钮
↓
助手：发送反馈卡片（告知预计耗时）
🔵 ✏️ 正在修改...
⏳ 预计耗时：约 60 秒
↓
助手：修改提示词 → Gemini 生图 → 发送新审核卡片
🖼️ 修改版图片（夏季流行色）
📝 修改说明：背景改为浅蓝色，增加夏日清凉感
🔘 ✅通过 | ✏️再改 | ❌重写
```

**步骤 4：用户点击"❌ 重写"**
```
用户：点击"❌ 重写"按钮
↓
助手：发送反馈卡片（告知预计耗时）
🔵 ❌ 正在重写...
🎨 新主题：冬季护肤攻略
⏳ 预计耗时：约 60 秒
↓
助手：全新主题 → Gemini 生图 → 发送新审核卡片
🖼️ 重写版图片（冬季护肤指南）
📝 全新主题：5 个护肤步骤
🔘 ✅通过 | ✏️修改 | ❌再重写
```

### 示例 2：在 OpenClaw 中调用

```yaml
task: send_review_card
version: 1.0

inputs:
  - name: image_path
    type: string
    required: true
  - name: title
    type: string
    required: true
  - name: content
    type: string
    required: true
  - name: tags
    type: string
    required: true
  - name: note_id
    type: string
    required: true

steps:
  - name: get_token
    tool: exec
    command: |
      curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
        -H "Content-Type: application/json" \
        -d '{"app_id":"cli_a93d321f76f89bc2","app_secret":"jaHXE9P93dfeffcjkvr7MhbYiawyMXer"}'
    parse: jq -r '.tenant_access_token'
    store: token

  - name: upload_image
    tool: exec
    command: |
      curl -s -X POST "https://open.feishu.cn/open-apis/im/v1/images" \
        -H "Authorization: Bearer $token" \
        -F "image_type=message" \
        -F "image=@$image_path"
    parse: jq -r '.data.image_key'
    store: image_key

  - name: send_card
    tool: exec
    command: |
      curl -X POST "https://open.feishu.cn/open-apis/im/v1/messages?receive_id=ou_5f272e72aba67f5fb6ebd96cb458fd4a&receive_id_type=open_id&msg_type=interactive" \
        -H "Authorization: Bearer $token" \
        -H "Content-Type: application/json" \
        -d "{\"content\":$(build_card_json)}"
```

---

## 回调处理（可选）

### 配置飞书回调 URL

1. 进入飞书开放平台：https://open.feishu.cn/app
2. 找到应用 → 事件订阅
3. 配置回调 URL：`http://your-server:18795/feishu/card/callback`
4. 订阅事件：`im.message`

### 回调处理逻辑

```javascript
// 飞书回调处理
app.post('/feishu/card/callback', (req, res) => {
  const { challenge, header, event } = req.body;
  
  // 验证挑战
  if (challenge) {
    return res.send(challenge);
  }
  
  // 处理按钮点击
  if (event.message_type === 'interactive') {
    const action = event.action?.value;
    
    if (action.startsWith('approve_')) {
      console.log(`✅ 笔记 ${action} 审核通过`);
      // 发送确认消息
    } else if (action.startsWith('modify_')) {
      console.log(`✏️ 笔记 ${action} 需要修改`);
      // 询问修改意见
    } else if (action.startsWith('rewrite_')) {
      console.log(`❌ 笔记 ${action} 需要重写`);
      // 重新创作
    }
  }
  
  res.send('success');
});
```

---

## 常见问题

| 问题 | 原因 | 解决方案 |
|------|------|----------|
| 图片不显示 | `img_key` 过期 | 重新上传图片获取新 key |
| 按钮无响应 | 未配置回调 URL | 飞书开放平台配置事件订阅 |
| 发送失败 | 权限不足 | 检查 app_id/app_secret 配置 |
| 内容格式错乱 | Markdown 语法错误 | 检查转义字符和换行符 |

---

## 相关文件

| 文件 | 位置 | 说明 |
|------|------|------|
| **SKILL.md** | `skills/feishu-card-review/` | 本说明文档 |
| **send-card.sh** | `skills/feishu-card-review/` | 发送脚本 |
| **card-templates/** | `skills/feishu-card-review/` | 卡片模板 |
| **openclaw.json** | `~/.openclaw/` | 飞书应用配置 |

---

## ✅ 最佳实践（v2.0 简化版）

### 交互设计

1. **一键直达**：不要多级交互，点击按钮直接反馈
2. **即时反馈**：收到按钮点击后 1 秒内发送反馈卡片
3. **颜色区分**：通过=绿色，修改/重写=红色
4. **明确状态**：反馈卡片清晰显示当前状态和预计耗时
5. **下一步引导**：每个反馈都提供下一步操作按钮

### Gemini 生图

1. **提示词优化**：从提示词库获取优质模板（`skills/gemini-prompts-library/SKILL.md`）
2. **修改策略**：保留风格，调整颜色/主题/元素
3. **重写策略**：完全换主题，保持相同格式
4. **时间管理**：告知用户预计耗时（约 60 秒）
5. **错误处理**：生图失败时重试 1-2 次

### 飞书卡片

1. **图片预上传**：提前上传图片获取 `img_key`，避免发送时等待
2. **卡片模板化**：将常用卡片保存为模板，复用结构
3. **Token 缓存**：`tenant_access_token` 有效期 2 小时，可缓存复用
4. **审核状态追踪**：记录每条卡片的审核状态（待审核/通过/修改/重写）
5. **文案完整**：最终稿卡片包含完整文案，方便用户复制

---

## 📊 版本历史

| 版本 | 日期 | 更新内容 |
|------|------|---------|
| **v2.0** | 2026-03-20 | 简化版交互流程，集成 Gemini 生图，修改/重写自动生成新图 |
| **v1.0** | 2026-03-18 | 初始版本，基础审核卡片 + 最终稿卡片功能 |

---

---

**版本：** 2.0（简化版）  
**创建时间：** 2026-03-18  
**更新时间：** 2026-03-20  
**适用场景：** 小红书笔记审核、文案审核、设计稿审核、Gemini 生图集成

# 飞书交互卡片 Skill

📱 使用飞书交互式卡片发送内容审核请求和最终稿发布卡片，支持：
- ✅ 审核卡片（通过/修改/重写按钮）
- ✅ 发布卡片（🍠 发布到小红书按钮）
- ✅ 图片展示
- ✅ 完整文案展示（长按复制）

---

## 🚀 快速开始

### 1. 确认配置

确保 `~/.openclaw/openclaw.json` 中已配置飞书应用：

```json
{
  "channels": {
    "feishu": {
      "accounts": {
        "xiaohongshu-bot": {
          "appId": "cli_xxxxxxxx",
          "appSecret": "xxxxxxxxxxxxxxxxxxxx"
        }
      }
    }
  }
}
```

### 2. 使用脚本发送

#### 发送审核卡片

```bash
cd /Volumes/1TB/openclaw/xiaohongshu-bot/skills/feishu-card-review

./send-card.sh \
  "/path/to/image.png" \
  "🎨 卡片标题" \
  "**正文内容**\n• 列表项 1\n• 列表项 2" \
  "#标签 1 #标签 2" \
  "note1"
```

#### 发送最终稿发布卡片

```bash
./send-final-card.sh \
  "/path/to/image.png" \
  "✅ 笔记一最终稿：春季流行色" \
  "**🎨 标题：** 2026 春季最火配色！\n\n**✨ 5 个流行色：**\n• 柔雾粉\n• 薄荷绿" \
  "#春季穿搭 #2026 流行色" \
  "note1"
```

### 3. 在 OpenClaw 中调用

```yaml
# 示例：发送小红书笔记审核卡片
task: send_xiaohongshu_review_card
inputs:
  image_path: "/Volumes/1TB/openclaw/xiaohongshu-bot/output/images/note1.png"
  title: "🎨 2026 春季最火配色！"
  content: "**✨ 5 个流行色：**\n• 柔雾粉\n• 薄荷绿"
  tags: "#春季穿搭 #2026 流行色"
  note_id: "note1"

steps:
  - skill: feishu-card-review
    with:
      image_path: $image_path
      title: $title
      content: $content
      tags: $tags
      note_id: $note_id
```

---

## 📋 卡片模板

### 小红书笔记最终稿（发布卡片）

```json
{
  "header": {"template": "blue", "title": "✅ 笔记一最终稿：春季流行色"},
  "elements": [
    {"tag": "img", "img_key": "xxx"},
    {"tag": "div", "text": {"tag": "lark_md", "content": "**🎨 标题：** 2026 春季最火配色！\n\n**✨ 5 个流行色：**\n• 柔雾粉\n• 薄荷绿"}},
    {"tag": "hr"},
    {"tag": "note", "elements": [{"tag": "plain_text", "content": "#春季穿搭 #2026 流行色"}]},
    {"tag": "action", "actions": [
      {"tag": "button", "text": "🍠 发布到小红书", "type": "primary", "multi_url": {
        "url": "https://creator.xiaohongshu.com",
        "android_url": "xhsdiscover://",
        "ios_url": "xhsdiscover://"
      }}
    ]}
  ]
}
```

**按钮功能：**
- 🍠 发布到小红书：点击在移动端拉起小红书 App
- 完整文案直接展示在卡片中，长按即可复制

### 小红书笔记审核

```json
{
  "header": {"template": "blue", "title": "🍠 小红书笔记审核"},
  "elements": [
    {"tag": "img", "img_key": "xxx"},
    {"tag": "div", "text": {"tag": "lark_md", "content": "文案内容"}},
    {"tag": "note", "elements": [{"tag": "plain_text", "content": "#标签"}]},
    {"tag": "action", "actions": [
      {"tag": "button", "text": "✅ 通过", "type": "primary", "value": "approve_note1"},
      {"tag": "button", "text": "✏️ 修改", "type": "default", "value": "modify_note1"},
      {"tag": "button", "text": "❌ 重写", "type": "default", "value": "rewrite_note1"}
    ]}
  ]
}
```

### 设计稿审核

```json
{
  "header": {"template": "purple", "title": "🎨 设计稿审核"},
  "elements": [
    {"tag": "img", "img_key": "xxx"},
    {"tag": "div", "text": {"tag": "lark_md", "content": "设计说明"}},
    {"tag": "action", "actions": [
      {"tag": "button", "text": "✅ 通过", "type": "primary", "value": "approve_design1"},
      {"tag": "button", "text": "✏️ 修改", "type": "default", "value": "modify_design1"}
    ]}
  ]
}
```

### 文案审核

```json
{
  "header": {"template": "orange", "title": "📝 文案审核"},
  "elements": [
    {"tag": "div", "text": {"tag": "lark_md", "content": "文案内容"}},
    {"tag": "note", "elements": [{"tag": "plain_text", "content": "字数：100 | 风格：活泼"}]},
    {"tag": "action", "actions": [
      {"tag": "button", "text": "✅ 通过", "type": "primary", "value": "approve_copy1"},
      {"tag": "button", "text": "✏️ 修改", "type": "default", "value": "modify_copy1"},
      {"tag": "button", "text": "❌ 重写", "type": "default", "value": "rewrite_copy1"}
    ]}
  ]
}
```

---

## 🔘 按钮功能说明

### 审核卡片按钮

| 按钮 | 类型 | 功能 |
|------|------|------|
| ✅ 通过 | `primary` | 审核通过，发送最终稿卡片 |
| ✏️ 修改 | `default` | 需要修改，询问修改意见 |
| ❌ 重写 | `default` | 需要重写，重新创作 |

### 发布卡片按钮

| 按钮 | 类型 | 功能 |
|------|------|------|
| 🍠 发布到小红书 | `primary` | 点击在移动端拉起小红书 App |
| 📋 复制文案 | `default` | 点击返回文案内容（需配置回调） |

**🍠 发布到小红书按钮行为：**
- 📱 **移动端（iOS/Android）**：直接拉起小红书 App
- 💻 **PC 端**：打开小红书创作平台 https://creator.xiaohongshu.com

**技术实现：**
```json
{
  "tag": "button",
  "text": "🍠 发布到小红书",
  "type": "primary",
  "multi_url": {
    "url": "https://creator.xiaohongshu.com",
    "android_url": "xhsdiscover://",
    "ios_url": "xhsdiscover://"
  }
}
```

---

## 🔧 配置回调（可选）

### 1. 飞书开放平台配置

1. 进入 https://open.feishu.cn/app
2. 找到你的应用
3. 事件订阅 → 添加事件
4. 订阅 `im.message` 事件
5. 配置回调 URL

### 2. 回调处理示例

```javascript
// OpenClaw Gateway 回调处理
app.post('/feishu/card/callback', (req, res) => {
  const { challenge, event } = req.body;
  
  // 验证挑战
  if (challenge) {
    return res.send(challenge);
  }
  
  // 处理按钮点击
  const action = event.action?.value;
  
  if (action?.startsWith('approve_')) {
    console.log(`✅ 审核通过：${action}`);
    // 发送确认消息
  } else if (action?.startsWith('modify_')) {
    console.log(`✏️ 需要修改：${action}`);
    // 询问修改意见
  } else if (action?.startsWith('rewrite_')) {
    console.log(`❌ 需要重写：${action}`);
    // 重新创作
  }
  
  res.send('success');
});
```

---

## 📊 卡片颜色选择

| 颜色 | 适用场景 | 示例 |
|------|----------|------|
| 🔵 Blue | 科技、专业、通用 | 小红书笔记审核 |
| 🔴 Red | 热情、重要、紧急 | 重要通知 |
| 🟢 Green | 自然、健康、环保 | 可持续时尚 |
| 🟣 Purple | 创意、设计、艺术 | 设计稿审核 |
| 🟠 Orange | 活力、年轻、美食 | 美食推荐 |

---

## 🛠️ 故障排查

### 图片不显示

**原因：** `img_key` 过期或权限不足

**解决：**
```bash
# 重新上传图片获取新 key
curl -X POST "https://open.feishu.cn/open-apis/im/v1/images" \
  -H "Authorization: Bearer $TOKEN" \
  -F "image_type=message" \
  -F "image=@image.png"
```

### 按钮无响应

**原因：** 未配置回调 URL

**解决：**
1. 飞书开放平台 → 事件订阅
2. 配置回调 URL
3. 订阅 `im.message` 事件

### 发送失败

**原因：** 权限不足或配置错误

**解决：**
```bash
# 检查配置
cat ~/.openclaw/openclaw.json | jq '.channels.feishu.accounts'

# 测试令牌
curl -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
  -H "Content-Type: application/json" \
  -d '{"app_id":"xxx","app_secret":"xxx"}'
```

---

## 📚 参考文档

- [飞书卡片消息格式](https://open.feishu.cn/document/ukTMukTMukTM/uEjNwUjLxYDM14SM2ATN)
- [飞书图片上传接口](https://open.feishu.cn/document/ukTMukTMukTM/uYjNwUjL2YDM14iN2ATN)
- [飞书交互式卡片](https://open.feishu.cn/document/ukTMukTMukTM/uYjNwUjL3YDM14iN2ATN)

---

**版本：** 1.0  
**创建时间：** 2026-03-18  
**维护者：** xiaohongshu-bot

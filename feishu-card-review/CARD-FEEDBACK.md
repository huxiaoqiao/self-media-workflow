# 飞书卡片按钮反馈设计（简化版）

## 📋 简化交互原则

**一键直达，不要多级交互！**

| 按钮 | 直接操作 |
|------|---------|
| **✅ 通过** | 发送最终稿卡片（图片 + 完整文案 + 🍠发布按钮） |
| **✏️ 修改** | 修改原提示词 → 生成新图 → 发送新审核卡片 |
| **❌ 重写** | 全新主题 → 生成新图 → 发送新审核卡片 |

---

## 🎨 完整流程

### 步骤 1：发送审核卡片

```json
{
  "header": {"template": "blue", "title": "🎨 小红书笔记审核"},
  "elements": [
    {"tag": "img", "img_key": "img_v3_xxxxx"},
    {"tag": "div", "text": {"content": "📌 标题 + ✨ 亮点 + 💡 Tips"}},
    {"tag": "note", "elements": [{"content": "#标签"}]},
    {"tag": "action", "actions": [
      {"tag": "button", "text": "✅ 通过", "value": "approve_xxx"},
      {"tag": "button", "text": "✏️ 修改", "value": "modify_xxx"},
      {"tag": "button", "text": "❌ 重写", "value": "rewrite_xxx"}
    ]}
  ]
}
```

---

### 步骤 2：根据按钮直接反馈

#### ✅ 通过 → 发送最终稿卡片

```json
{
  "header": {"template": "green", "title": "✅ 最终稿：2026 春季流行色"},
  "elements": [
    {"tag": "img", "img_key": "img_v3_xxxxx"},
    {
      "tag": "div",
      "text": {
        "content": "**📌 标题：** 2026 春季最火配色！\n\n**✨ 正文：**\n• 柔雾粉 - 温柔显白\n• 薄荷绿 - 清新自然\n• 奶油黄 - 元气满满\n\n**💡 标签：** #春季穿搭 #2026 流行色"
      }
    },
    {"tag": "action", "actions": [
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
    ]}
  ]
}
```

**关键点：**
- 绿色主题（已通过）
- 完整文案（方便复制）
- 只有"🍠 发布到小红书"按钮

---

#### ✏️ 修改 → 修改提示词 → 重新生图 → 发送新审核卡片

**修改策略：**
```python
# 原提示词
original_prompt = "创作一张手绘风格的信息图卡片，比例为 9:16 竖版..."

# 修改后（调整颜色/布局/元素）
modified_prompt = "创作一张手绘风格的信息图卡片，比例为 9:16 竖版，背景改为浅蓝色调，增加更多留白空间..."
```

**发送新审核卡片：**
```json
{
  "header": {"template": "blue", "title": "🎨 修改版 - 手绘信息图"},
  "elements": [
    {"tag": "img", "img_key": "img_v3_new_xxxxx"},
    {"tag": "div", "text": {"content": "📝 修改说明：调整了背景色调，增加了留白..."}},
    {"tag": "action", "actions": [
      {"tag": "button", "text": "✅ 通过", "value": "approve_modified_xxx"},
      {"tag": "button", "text": "✏️ 再改", "value": "modify_again_xxx"},
      {"tag": "button", "text": "❌ 重写", "value": "rewrite_xxx"}
    ]}
  ]
}
```

---

#### ❌ 重写 → 全新主题 → 重新生图 → 发送新审核卡片

**重写策略：**
```python
# 原主题：春季流行色
# 新主题：夏季防晒攻略（完全换主题）

new_prompt = "创作一张手绘风格的防晒指南信息图，比例为 9:16 竖版..."
```

**发送新审核卡片：**
```json
{
  "header": {"template": "blue", "title": "🎨 全新主题 - 夏季防晒攻略"},
  "elements": [
    {"tag": "img", "img_key": "img_v3_new_xxxxx"},
    {"tag": "div", "text": {"content": "📝 新主题：夏季防晒完全指南..."}},
    {"tag": "action", "actions": [
      {"tag": "button", "text": "✅ 通过", "value": "approve_new_xxx"},
      {"tag": "button", "text": "✏️ 修改", "value": "modify_new_xxx"},
      {"tag": "button", "text": "❌ 重写", "value": "rewrite_new_xxx"}
    ]}
  ]
}
```

---

## 📊 交互对比

### ❌ 旧版（多级交互，复杂）
```
审核卡片 → 点击通过 → 反馈卡片 → 点击发布 → 打开小红书
              ↓
         点击修改 → 反馈卡片 → 询问意见 → 等待回复 → 再生成
              ↓
         点击重写 → 反馈卡片 → 确认重写 → 再生成
```

### ✅ 新版（一键直达，简洁）
```
审核卡片 → 点击通过 → 最终稿卡片（带发布按钮）
              ↓
         点击修改 → 新审核卡片（修改版）
              ↓
         点击重写 → 新审核卡片（全新主题）
```

---

## 🔧 Python 实现示例

```python
import requests
import json

TOKEN = "t-g1043kdqGOILQDM4BBHOHBQQWGJT4YY7XT3JJLOR"
CHAT_ID = "oc_883da3c19d83765512434a7447d11271"

def handle_button_click(action_value, image_key, original_prompt):
    """处理按钮点击，直接发送对应内容"""
    
    if "approve" in action_value:
        # ✅ 通过 → 发送最终稿
        send_final_draft(image_key)
    
    elif "modify" in action_value:
        # ✏️ 修改 → 修改提示词 → 生成新图 → 发送新审核卡片
        modified_prompt = modify_prompt(original_prompt)
        new_image_key = generate_image(modified_prompt)
        send_review_card(new_image_key, modified_prompt, "修改版")
    
    elif "rewrite" in action_value:
        # ❌ 重写 → 全新主题 → 生成新图 → 发送新审核卡片
        new_prompt = generate_new_topic()
        new_image_key = generate_image(new_prompt)
        send_review_card(new_image_key, new_prompt, "全新主题")

def send_final_draft(image_key):
    """发送最终稿卡片"""
    card = {
        "config": {"wide_screen_mode": True},
        "header": {
            "template": "green",
            "title": {"tag": "plain_text", "content": "✅ 最终稿：2026 春季流行色"}
        },
        "elements": [
            {"tag": "img", "img_key": image_key},
            {
                "tag": "div",
                "text": {
                    "tag": "lark_md",
                    "content": "**📌 标题：** 2026 春季最火配色！\n\n**✨ 正文：**\n• 柔雾粉 - 温柔显白\n• 薄荷绿 - 清新自然\n• 奶油黄 - 元气满满\n\n**💡 标签：** #春季穿搭 #2026 流行色"
                }
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
                    }
                ]
            }
        ]
    }
    
    send_card(card)

def send_review_card(image_key, prompt, card_type="审核"):
    """发送审核卡片"""
    card = {
        "config": {"wide_screen_mode": True},
        "header": {
            "template": "blue",
            "title": {"tag": "plain_text", "content": f"🎨 {card_type}"}
        },
        "elements": [
            {"tag": "img", "img_key": image_key},
            {"tag": "div", "text": {"tag": "lark_md", "content": generate_content(prompt)}},
            {"tag": "note", "elements": [{"tag": "plain_text", "content": "#标签"}]},
            {
                "tag": "action",
                "actions": [
                    {"tag": "button", "text": "✅ 通过", "type": "primary", "value": "approve_xxx"},
                    {"tag": "button", "text": "✏️ 修改", "type": "default", "value": "modify_xxx"},
                    {"tag": "button", "text": "❌ 重写", "type": "default", "value": "rewrite_xxx"}
                ]
            }
        ]
    }
    
    send_card(card)

def send_card(card):
    """发送卡片消息"""
    url = f"https://open.feishu.cn/open-apis/im/v1/messages?receive_id_type=chat_id"
    headers = {
        "Authorization": f"Bearer {TOKEN}",
        "Content-Type": "application/json"
    }
    payload = {
        "receive_id": CHAT_ID,
        "msg_type": "interactive",
        "content": json.dumps(card, ensure_ascii=False)
    }
    
    response = requests.post(url, headers=headers, json=payload)
    return response.json()
```

---

## 📁 相关文件

| 文件 | 位置 | 说明 |
|------|------|------|
| `SKILL.md` | `skills/feishu-card-review/` | 技能主文档 |
| `send-card.sh` | `skills/feishu-card-review/` | 发送审核卡片脚本 |
| `CARD-FEEDBACK.md` | `skills/feishu-card-review/` | 本文档（简化版） |

---

**版本：** 2.0（简化版）  
**更新时间：** 2026-03-20  
**适用场景：** 小红书笔记审核 + 发布流程

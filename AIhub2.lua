-- ============================================
--  AIhub 1.0 - 完整脚本（带独立聊天记录窗口）
--  作者: PISKIM
-- ============================================

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "WindUI 加载失败",
        Text = "请检查网络连接后重试",
        Duration = 5
    })
    return
end

-- ===== 创建主窗口 =====
local Window = WindUI:CreateWindow({
    Title = "AIhub 1.0",
    Author = "PISKIM",
    Icon = "bot",
    Theme = "Dark",
    Folder = "AIhub",
    Size = UDim2.fromOffset(600, 480),
    MinSize = Vector2.new(500, 350),
    MaxSize = Vector2.new(800, 700),
    Resizable = true,
    ToggleKey = Enum.KeyCode.RightShift,
    SideBarWidth = 180,
    Transparent = false,
})

-- ===== 创建5个标签页 =====
local homeTab = Window:Tab({ Title = "主页", Icon = "home" })
local combatTab = Window:Tab({ Title = "战斗", Icon = "sword" })
local utilsTab = Window:Tab({ Title = "工具", Icon = "wrench" })
local chatTab = Window:Tab({ Title = "AI对话", Icon = "message-circle" })
local settingsTab = Window:Tab({ Title = "设置", Icon = "settings" })

-- ============================================
--  1. 主页标签页
-- ============================================
homeTab:Paragraph({
    Title = "🏠 欢迎使用 AIhub",
    Description = "一个集成了AI功能的Roblox脚本工具\n\n📌 使用说明：\n• 按 RightShift 显示/隐藏窗口\n• 所有功能分布在5个标签页中"
})

homeTab:Button({
    Title = "📖 查看教程",
    Description = "点击查看完整使用教程",
    Callback = function()
        print("教程功能待完善")
    end
})

-- ============================================
--  2. 战斗标签页
-- ============================================
combatTab:Paragraph({
    Title = "⚔️ 战斗功能",
    Description = "自动战斗相关设置"
})

combatTab:Toggle({
    Title = "自动攻击",
    Description = "开启后自动攻击最近的敌人",
    Callback = function(value)
        print("自动攻击: " .. tostring(value))
    end
})

combatTab:Toggle({
    Title = "自动格挡",
    Description = "开启后自动格挡敌人攻击",
    Callback = function(value)
        print("自动格挡: " .. tostring(value))
    end
})

combatTab:Slider({
    Title = "攻击范围",
    Description = "调整自动攻击的检测范围",
    Default = 30,
    Min = 10,
    Max = 100,
    Step = 5,
    Callback = function(value)
        print("攻击范围: " .. tostring(value))
    end
})

-- ============================================
--  3. 工具标签页
-- ============================================
utilsTab:Paragraph({
    Title = "🛠️ 实用工具",
    Description = "各种辅助工具"
})

utilsTab:Button({
    Title = "🚀 传送至重生点",
    Description = "点击立即传送回重生点",
    Callback = function()
        print("传送至重生点")
    end
})

utilsTab:Button({
    Title = "💉 满血回复",
    Description = "立即回复全部生命值",
    Callback = function()
        print("满血回复")
    end
})

-- ============================================
--  4. AI对话标签页（带独立聊天记录窗口）
-- ============================================
chatTab:Paragraph({
    Title = "🤖 AI 智能对话",
    Description = "输入问题，AI 会为你解答"
})

-- 存储用户输入
local userInput = ""

-- 存储完整的聊天历史（用于独立窗口）
local chatHistory = "等待你的提问..."

-- 对话记录预览（只显示最新一条）
local displayLabel = chatTab:Label({
    Title = "📝 最新回复",
    Description = chatHistory
})

-- 输入框
chatTab:Input({
    Title = "✏️ 输入问题",
    Description = "输入你想问的问题",
    Placeholder = "例如：如何快速升级？",
    Callback = function(text)
        userInput = text or ""
        print("输入内容: " .. userInput)
    end
})

-- 发送按钮
chatTab:Button({
    Title = "📤 发送",
    Description = "点击发送你的问题给AI",
    Callback = function()
        print("发送按钮被点击")
        
        if userInput == "" or userInput == nil then
            displayLabel:Set({
                Title = "⚠️ 提示",
                Description = "请先输入问题再发送"
            })
            return
        end
        
        -- 显示"思考中"
        displayLabel:Set({
            Title = "🤔 AI 思考中...",
            Description = "正在处理你的问题，请稍候..."
        })
        
        -- 发送网络请求
        local http = game:GetService("HttpService")
        local encoded = http:UrlEncode(userInput)
        local url = "https://api.xygeng.cn/api?msg=" .. encoded
        
        print("请求URL: " .. url)
        
        task.spawn(function()
            local ok, result = pcall(function()
                return http:GetAsync(url)
            end)
            
            if ok and result then
                print("收到响应: " .. result)
                
                local success, data = pcall(function()
                    return http:JSONDecode(result)
                end)
                
                if success and data and data.data and data.data.content then
                    local reply = data.data.content
                    -- 更新预览
                    displayLabel:Set({
                        Title = "💬 最新回复",
                        Description = reply
                    })
                    -- 更新聊天历史（追加新内容）
                    chatHistory = chatHistory .. "\n\n🧑 你: " .. userInput .. "\n🤖 AI: " .. reply
                    print("聊天历史已更新")
                else
                    displayLabel:Set({
                        Title = "❌ 解析失败",
                        Description = "AI 返回的数据格式异常，请重试"
                    })
                end
            else
                print("请求失败: " .. tostring(result))
                displayLabel:Set({
                    Title = "❌ 请求失败",
                    Description = "网络连接失败，请检查网络后重试"
                })
            end
        end)
    end
})

-- ✅ 新增：查看完整聊天记录的按钮
chatTab:Button({
    Title = "📜 查看完整对话记录",
    Description = "打开独立窗口查看完整聊天历史",
    Callback = function()
        -- 创建一个独立的窗口
        local historyWindow = WindUI:CreateWindow({
            Title = "📜 对话记录",
            Author = "AIhub",
            Icon = "message-square",
            Theme = "Dark",
            Folder = "AIhub_History",
            Size = UDim2.fromOffset(500, 400),
            MinSize = Vector2.new(400, 300),
            MaxSize = Vector2.new(700, 600),
            Resizable = true,
            ToggleKey = Enum.KeyCode.RightShift,
            SideBarWidth = 0,
            Transparent = false,
        })
        
        -- 在独立窗口中显示完整聊天历史（用 Label 代替 Paragraph 以支持动态更新）
        local historyLabel = historyWindow:Label({
            Title = "📋 完整对话记录",
            Description = chatHistory
        })
        
        -- 刷新按钮
        historyWindow:Button({
            Title = "🔄 刷新内容",
            Description = "刷新当前显示的对话记录",
            Callback = function()
                historyLabel:Set({
                    Title = "📋 完整对话记录",
                    Description = chatHistory
                })
                print("对话记录已刷新")
            end
        })
        
        -- 清空历史按钮
        historyWindow:Button({
            Title = "🗑️ 清空全部记录",
            Description = "清除所有对话历史",
            Callback = function()
                chatHistory = "对话记录已清空"
                displayLabel:Set({
                    Title = "📝 最新回复",
                    Description = chatHistory
                })
                -- 关闭当前窗口
                historyWindow:Destroy()
                -- 提示用户
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "已清空",
                    Text = "所有对话记录已清除",
                    Duration = 3
                })
            end
        })
    end
})

-- 清空记录按钮（保留在主标签页）
chatTab:Button({
    Title = "🗑️ 清空当前回复",
    Description = "仅清空当前显示的回复预览",
    Callback = function()
        displayLabel:Set({
            Title = "📝 最新回复",
            Description = "已清空，可以继续提问了"
        })
    end
})

-- ============================================
--  5. 设置标签页
-- ============================================
settingsTab:Paragraph({
    Title = "⚙️ 设置",
    Description = "脚本设置"
})

settingsTab:Toggle({
    Title = "启用提示音",
    Description = "操作时播放提示音效",
    Callback = function(value)
        print("提示音: " .. tostring(value))
    end
})

settingsTab:Toggle({
    Title = "显示调试信息",
    Description = "在控制台显示详细日志",
    Callback = function(value)
        print("调试模式: " .. tostring(value))
    end
})

settingsTab:Button({
    Title = "🔄 重置默认",
    Description = "恢复所有设置为默认值",
    Callback = function()
        print("重置所有设置")
    end
})

-- ============================================
--  脚本启动完成提示
-- ============================================
print("✅ AIhub 加载完成！按 RightShift 打开菜单")

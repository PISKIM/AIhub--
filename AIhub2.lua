local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "WindUI 加载失败",
        Text = "请检查网络连接后重试",
        Duration = 5
    })
    return
end

local Window = WindUI:CreateWindow({
    Title = "AIhub-1.0.0",
    Author = "PISKIM",
    Icon = "house",
    Theme = "Dark",
    Folder = "MySuperScript",
    Size = UDim2.fromOffset(600, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 600),
    Resizable = true,
    ToggleKey = Enum.KeyCode.RightShift,
    SideBarWidth = 200,
    Transparent = true,
    Background = "rbxassetid://123456",
})

-- ===== 创建5个标签页 =====
local homeTab = Window:Tab({ Title = "主页", Icon = "home" })
local generalTab = Window:Tab({ Title = "通用", Icon = "sword" })
local otherTab = Window:Tab({ Title = "其他脚本", Icon = "box" })
local aiTab = Window:Tab({ Title = "AI制作脚本", Icon = "bot" })
local ai2Tab = Window:Tab({ Title = "AI对话", Icon = "message-circle" })
local settingsTab = Window:Tab({ Title = "设置", Icon = "settings" })

-- ===== 主页 =====
homeTab:Paragraph({
    Title = "🏠 欢迎使用 AIhub",
    Description = "这是脚本的主页，所有功能分布在5个标签页中"
})

-- ===== 通用 =====
generalTab:Toggle({
    Title = "示例开关",
    Description = "这是一个通用的开关示例",
    Callback = function(Value)
        print("开关状态：" .. tostring(Value))
    end
})

-- ===== 其他脚本 =====
otherTab:Paragraph({
    Title = "📦 其他脚本",
    Description = "这里可以放其他脚本的功能"
})

-- ===== AI制作脚本（指令执行器） =====
aiTab:Paragraph({
    Title = "🧠 AI 指令执行器",
    Description = "用自然语言告诉 AI 你想做什么"
})

aiTab:Input({
    Title = "输入指令",
    Description = "例如：攻击最近的敌人 / 向宝箱移动 / 使用技能1",
    Placeholder = "告诉 AI 你想执行的操作...",
    Callback = function(Command)
        if Command and Command ~= "" then
            local lowerCmd = string.lower(Command)
            if string.find(lowerCmd, "攻击") or string.find(lowerCmd, "打") then
                print("🤖 AI 执行：攻击模式启动")
            elseif string.find(lowerCmd, "移动") or string.find(lowerCmd, "走") then
                print("🤖 AI 执行：移动指令")
            elseif string.find(lowerCmd, "技能") then
                print("🤖 AI 执行：释放技能")
            else
                print("🤖 AI 无法识别指令：" .. Command)
            end
        end
    end
})

aiTab:Toggle({
    Title = "🤖 AI 自动模式",
    Description = "开启后 AI 会自动分析局势并执行最佳操作",
    Callback = function(Value)
        if Value then
            print("AI 自动模式已开启")
        else
            print("AI 自动模式已关闭")
        end
    end
})

-- ===== AI对话（手机适配版） =====
ai2Tab:Paragraph({
    Title = "🤖 AI 智能助手",
    Description = "输入你的问题，点击发送按钮即可获取回答"
})

-- 对话记录显示区
local chatBox = ai2Tab:Paragraph({
    Title = "💬 对话记录",
    Description = "等待你的提问..."
})

-- 存储输入框的内容
local currentQuestion = ""

-- 输入框
ai2Tab:Input({
    Title = "✏️ 输入问题",
    Description = "在下方输入你想问 AI 的问题",
    Placeholder = "例如：如何快速升级？",
    Callback = function(Question)
        currentQuestion = Question or ""
    end
})

-- ✅ WindUI 标准按钮：发送问题
ai2Tab:Button({
    Title = "📤 发送问题",
    Description = "点击后向 AI 发送你输入的问题",
    Callback = function()
        if currentQuestion and currentQuestion ~= "" then
            chatBox:Set({
                Title = "🤔 AI 思考中...",
                Description = "正在处理你的问题，请稍候..."
            })
            
            local HttpService = game:GetService("HttpService")
            local url = "https://api.xygeng.cn/api?msg=" .. HttpService:UrlEncode(currentQuestion)
            
            task.spawn(function()
                local success, response = pcall(function()
                    return HttpService:GetAsync(url)
                end)
                
                if success and response then
                    local data = HttpService:JSONDecode(response)
                    if data and data.data and data.data.content then
                        chatBox:Set({
                            Title = "💬 AI 回答",
                            Description = data.data.content
                        })
                    else
                        chatBox:Set({
                            Title = "❌ 出错了",
                            Description = "AI 返回的数据格式异常，请重试"
                        })
                    end
                else
                    chatBox:Set({
                        Title = "❌ 请求失败",
                        Description = "网络连接失败，请检查网络后重试"
                    })
                end
            end)
        else
            chatBox:Set({
                Title = "⚠️ 提示",
                Description = "请先在输入框中输入问题再发送"
            })
        end
    end
})

-- ✅ WindUI 标准按钮：清空对话
ai2Tab:Button({
    Title = "🗑️ 清空对话",
    Description = "清除当前的对话记录",
    Callback = function()
        chatBox:Set({
            Title = "💬 对话记录",
            Description = "已清空，可以继续提问了"
        })
        currentQuestion = ""
    end
})

-- ===== 设置 =====
settingsTab:Paragraph({
    Title = "⚙️ 设置",
    Description = "脚本设置选项"
})

settingsTab:Toggle({
    Title = "启用通知",
    Description = "开启后脚本会显示通知提示",
    Callback = function(Value)
        print("通知开关：" .. tostring(Value))
    end
})

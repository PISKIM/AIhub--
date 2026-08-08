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

-- 创建5个标签页（变量名改为以字母开头）
local homeTab = Window:Tab({ Title = "主页", Icon = "home" })
local generalTab = Window:Tab({ Title = "通用", Icon = "sword" })
local otherTab = Window:Tab({ Title = "其他脚本", Icon = "box" }) 
local aiTab = Window:Tab({ Title = "AI制作脚本", Icon = "bot" })

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
            -- 这里写你的 AI 指令解析逻辑
            -- 简单示例：根据关键词执行不同操作
            local lowerCmd = string.lower(Command)
            
            if string.find(lowerCmd, "攻击") or string.find(lowerCmd, "打") then
                print("🤖 AI 执行：攻击模式启动")
                -- 调用你的战斗函数
                -- StartCombat()
            elseif string.find(lowerCmd, "移动") or string.find(lowerCmd, "走") then
                print("🤖 AI 执行：移动指令")
                -- 调用你的移动函数
                -- MoveToTarget()
            elseif string.find(lowerCmd, "技能") then
                print("🤖 AI 执行：释放技能")
                -- 调用技能函数
                -- UseSkill()
            else
                print("🤖 AI 无法识别指令：" .. Command)
                -- 提示用户
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
            -- 启动 AI 决策循环
            -- StartAILoop()
        else
            print("AI 自动模式已关闭")
            -- 停止 AI 决策循环
            -- StopAILoop()
        end
    end
})
local ai2Tab = Window:Tab({ Title = "AI对话", Icon = "bot" })


-- 在 AI 标签页创建一个对话区域
aiTab:Paragraph({
    Title = "🤖 AI 智能助手",
    Description = "输入你的问题，AI 会为你解答"
})

-- 显示对话内容的文本框（只读）
local chatBox = aiTab:Paragraph({
    Title = "对话记录",
    Description = "等待你的提问..."
})

-- 输入框：输入你的问题
aiTab:Input({
    Title = "提问",
    Description = "输入你想问 AI 的问题",
    Placeholder = "例如：如何快速升级？",
    Callback = function(Question)
        if Question and Question ~= "" then
            -- 更新界面显示"思考中..."
            chatBox:Set({
                Title = "🤔 AI 思考中...",
                Description = "正在处理你的问题，请稍候..."
            })
            
            -- 调用免费的 AI API（使用 http 服务）
            local HttpService = game:GetService("HttpService")
            local url = "https://api.xygeng.cn/api?msg=" .. HttpService:UrlEncode(Question)
            
            task.spawn(function()
                local success, response = pcall(function()
                    return HttpService:GetAsync(url)
                end)
                
                if success and response then
                    -- 解析返回的 JSON 数据
                    local data = HttpService:JSONDecode(response)
                    if data and data.data and data.data.content then
                        -- 显示 AI 的回答
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
        end
    end
})

-- 加一个清空对话的按钮
aiTab:Button({
    Title = "🗑️ 清空对话",
    Description = "清除当前的对话记录",
    Callback = function()
        chatBox:Set({
            Title = "对话记录",
            Description = "已清空，可以继续提问了"
        })
    end
})
local settingsTab = Window:Tab({ Title = "设置", Icon = "settings" })

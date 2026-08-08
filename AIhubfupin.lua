-- ============================================
--  AI制作脚本标签页（DeepSeek 驱动）
-- ============================================

-- ===== DeepSeek AI 配置 =====
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- ⚠️ 重要：把下面的 API_KEY 换成你自己的 DeepSeek API Key
local API_KEY = "sk-你的key"  -- 去 https://platform.deepseek.com/ 注册获取
local MODEL = "deepseek-chat"
local API_URL = "https://api.deepseek.com/chat/completions"

local SYSTEM_PROMPT = "你现在运行在 Roblox 客户端里。当用户要求执行操作（传送、改血量、跑代码、拿信息等）时，回复里直接给出可运行的 Lua 代码，用 ```lua 和 ``` 包起来。若只是普通问答就正常回复。"

-- 请求函数（支持多种执行器）
local requestFn = syn and syn.request or http_request or request

-- 对话历史
local chatHistory = {}

-- ===== 界面元素（在 aiTab 上创建） =====
aiTab:Paragraph({
    Title = "🧠 DeepSeek AI 助手",
    Description = "由 DeepSeek 驱动的智能助手，支持执行代码"
})

-- 对话记录显示区域
local chatDisplay = aiTab:Label({
    Title = "💬 对话记录",
    Description = "等待你的提问..."
})

-- 存储完整对话历史（用于显示）
local fullChatText = "欢迎使用 DeepSeek AI 助手！\n"

-- 输入框
local userInput = ""

aiTab:Input({
    Title = "✏️ 输入问题",
    Description = "输入你想问的问题或指令",
    Placeholder = "例如：传送我到 100,50,100",
    Callback = function(text)
        userInput = text or ""
    end
})

-- ===== AI 核心函数 =====
local function extractCode(text)
    local codes = {}
    for code in (text or ""):gmatch("```lua(.-)```") do
        table.insert(codes, code)
    end
    if #codes == 0 then
        for code in (text or ""):gmatch("```(.-)```") do
            table.insert(codes, code)
        end
    end
    return codes
end

local function runCode(code)
    local fn, err = loadstring(code)
    if not fn then
        return "❌ 代码错误: " .. tostring(err)
    end
    local ok, result = pcall(fn)
    if ok then
        return "✅ 执行成功" .. (result and " → " .. tostring(result) or "")
    else
        return "❌ 执行失败: " .. tostring(result)
    end
end

local function callDeepSeek(prompt)
    if not requestFn then
        return nil, "执行器不支持 HTTP 请求"
    end
    
    -- 构建消息历史
    local messages = {
        { role = "system", content = SYSTEM_PROMPT }
    }
    for _, msg in ipairs(chatHistory) do
        table.insert(messages, msg)
    end
    table.insert(messages, { role = "user", content = prompt })
    
    local body = {
        model = MODEL,
        messages = messages,
        max_tokens = 2048,
        temperature = 0.7
    }
    
    local ok, resp = pcall(function()
        return requestFn({
            Url = API_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. API_KEY
            },
            Body = HttpService:JSONEncode(body)
        })
    end)
    
    if not ok then
        return nil, tostring(resp)
    end
    
    if resp.StatusCode ~= 200 then
        return nil, "HTTP " .. tostring(resp.StatusCode) .. " - " .. tostring(resp.Body)
    end
    
    local data = HttpService:JSONDecode(resp.Body)
    local reply = data.choices and data.choices[1] and data.choices[1].message and data.choices[1].message.content
    if not reply then
        return nil, "API 返回格式异常"
    end
    
    -- 保存历史
    table.insert(chatHistory, { role = "user", content = prompt })
    table.insert(chatHistory, { role = "assistant", content = reply })
    
    return reply, nil
end

-- ===== 发送按钮 =====
aiTab:Button({
    Title = "📤 发送到 AI",
    Description = "将问题发送给 DeepSeek AI",
    Callback = function()
        if not userInput or userInput == "" then
            chatDisplay:Set({
                Title = "⚠️ 提示",
                Description = "请先输入问题再发送"
            })
            return
        end
        
        if not API_KEY or API_KEY == "sk-你的key" then
            chatDisplay:Set({
                Title = "❌ 未配置 API Key",
                Description = "请先在脚本中设置你的 DeepSeek API Key"
            })
            return
        end
        
        -- 显示"思考中"
        chatDisplay:Set({
            Title = "🤔 AI 思考中...",
            Description = "正在联系 DeepSeek，请稍候..."
        })
        
        -- 更新显示
        fullChatText = fullChatText .. "\n🧑 你: " .. userInput .. "\n"
        
        task.spawn(function()
            local reply, err = callDeepSeek(userInput)
            
            if not reply then
                chatDisplay:Set({
                    Title = "❌ 请求失败",
                    Description = "错误: " .. tostring(err)
                })
                fullChatText = fullChatText .. "❌ 错误: " .. tostring(err) .. "\n"
                return
            end
            
            -- 提取并执行代码
            local codes = extractCode(reply)
            local execResults = ""
            
            if #codes > 0 then
                for i, code in ipairs(codes) do
                    local result = runCode(code)
                    execResults = execResults .. "\n📦 代码块 " .. i .. ": " .. result
                end
            end
            
            -- 显示回复
            local displayText = reply
            if execResults ~= "" then
                displayText = reply .. "\n\n" .. execResults
            end
            
            chatDisplay:Set({
                Title = "💬 AI 回复",
                Description = displayText
            })
            
            fullChatText = fullChatText .. "🤖 AI: " .. reply .. "\n"
            if execResults ~= "" then
                fullChatText = fullChatText .. "📦 执行结果: " .. execResults .. "\n"
            end
        end)
    end
})

-- ===== 清空对话按钮 =====
aiTab:Button({
    Title = "🗑️ 清空对话",
    Description = "清除所有对话历史",
    Callback = function()
        chatHistory = {}
        fullChatText = "对话已清空\n"
        chatDisplay:Set({
            Title = "💬 对话记录",
            Description = "已清空，可以继续提问了"
        })
    end
})

-- ===== 查看完整记录按钮 =====
aiTab:Button({
    Title = "📜 查看完整对话记录",
    Description = "打开独立窗口查看完整聊天历史",
    Callback = function()
        local historyWindow = WindUI:CreateWindow({
            Title = "📜 完整对话记录",
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
        
        historyWindow:Label({
            Title = "📋 全部对话历史",
            Description = fullChatText
        })
        
        historyWindow:Button({
            Title = "🔄 刷新",
            Description = "刷新显示最新内容",
            Callback = function()
                -- 重新创建窗口来刷新（简化方案）
                historyWindow:Destroy()
                -- 提示用户重新打开
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "已刷新",
                    Text = "请重新点击查看完整记录",
                    Duration = 2
                })
            end
        })
    end
})

-- ===== 原有的 AI 自动模式开关 =====
aiTab:Toggle({
    Title = "🤖 AI 自动模式",
    Description = "开启后 AI 会自动分析局势并执行最佳操作（开发中）",
    Callback = function(Value)
        if Value then
            print("AI 自动模式已开启")
        else
            print("AI 自动模式已关闭")
        end
    end
})

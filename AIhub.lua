local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
if not WindUI then
    -- 如果加载失败，可以给玩家一个提示，然后停止脚本
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "WindUI 加载失败",
        Text = "请检查网络连接后重试",
        Duration = 5
    })
    return
end
local Window = WindUI:CreateWindow({
    Title = "AIhub-1.0.0",      -- 窗口标题
    Author = "PISKIM",        -- 作者信息
    Icon = "house",            -- 窗口图标，使用 Lucide 图标库里的名字
    Theme = "Dark",            -- 主题，比如 "Dark" 或 "Midnight"[citation:4][citation:5][citation:10]
    Folder = "MySuperScript",  -- 存储配置文件的文件夹名

    Size = UDim2.fromOffset(600, 460), -- 窗口大小
    MinSize = Vector2.new(560, 350),   -- 最小尺寸
    MaxSize = Vector2.new(850, 600),   -- 最大尺寸
    Resizable = true,                  -- 是否允许玩家调整窗口大小

    ToggleKey = Enum.KeyCode.RightShift, -- 按哪个键显示/隐藏窗口[citation:4][citation:7][citation:10]
    SideBarWidth = 200,                  -- 侧边栏宽度[citation:5]

    Transparent = true,                  -- 背景是否透明[citation:2][citation:8]
    Background = "rbxassetid://123456",  -- 可以设置背景图片[citation:2][citation:8]
})
-- 创建几个不同功能的标签页
local MainTab = Window:Tab({ Title = "主页", Icon = "home" })
local CombatTab = Window:Tab({ Title = "通用", Icon = "sword" })
local SettingsTab = Window:Tab({ Title = "设置", Icon = "settings" })

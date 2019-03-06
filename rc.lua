-- Standard awesome library
local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")
local beautiful = require("beautiful")
local naughty = require("naughty")
local gears = require("gears")

awful.widget = require("awful.widget")
awful.autofocus = require("awful.autofocus")
awful.rules = require("awful.rules")

-- {{{ Variable definitions
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
local terminal = "x-terminal-emulator"
local editor = os.getenv("EDITOR") or "editor"
local editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
local modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max.fullscreen,
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
local tags = {}
local app_info = { 
    dev = { app = terminal },
    chrome = { app = "bash -c 'google-chrome'" },
    firefox = { app = "firefox"},
    file = { app = "bash -c 'nautilus --browser --no-desktop' " }
}
-- }}}

-- {{{ Menu
local mainmenu = awful.menu({
    items = {
        { "awesome", {
            { "manual", terminal .. " -e man awesome" },
            { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
            { "restart", awesome.restart },
            { "quit", function () awesome.quit() end}
        }, beautiful.awesome_icon },
        { "open terminal", terminal }
    }
})

-- }}}

-- {{{ Wibox

local inc_layout = function (amt) 
    return function () awful.layout.inc(layouts, amt) end
end
local taglist_buttons = awful.util.table.join(
    awful.button({ }, 1, function (tag) tag:view_only() end),
    awful.button({ }, 3, awful.tag.viewtoggle)
)
local tasklist_buttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
        if not c:isvisible() then
            awful.tag.viewonly(c:tags()[1])
        end
        client.focus = c
        c:raise()
    end),
    awful.button({ }, 3, function ()
        if instance then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ width=250 })
        end
    end)
)

local function set_wallpaper(s)
  -- if beautiful.wallpaper then
    -- local wallpaper = beautiful.wallpaper
    -- if type(wallpaper) == "function" then
    --   wallpaper = wallpaper(s)
    -- end
  -- end
  gears.wallpaper.maximized("/home/crypticswarm/Documents/lockerdome/images/backgrounds/Thunderbolt-27/Wallpaper6.jpg", s, true)
end
screen.connect_signal("property::geometry", set_wallpaper)

local screen_widgets = {}
function create_screen_widgets(s)
    set_wallpaper(s)
    local tagNames = { "dev", "chrome", "firefox", "file", 5, 6, 7, 8, 9 }
    awful.tag(tagNames, s, layouts[1])
    local w = {
        launcher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mainmenu }),
        promptbox = awful.widget.prompt(),
        layoutbox = awful.widget.layoutbox(s),
        taglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons),
        tasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons),
        wibox = awful.wibox({ position = "top", screen = s, height = 39 }),
        textclock = nil,
        spacer = nil,
        systray = nil,
        netwidget = nil,
        left_layout = wibox.layout.fixed.horizontal(),
        right_layout = wibox.layout.fixed.horizontal(),
        layout = wibox.layout.align.horizontal()
    }
    w.left_layout:add(w.launcher)
    w.left_layout:add(w.taglist)
    w.left_layout:add(w.promptbox)
    if s == 1 then
        w.textclock = wibox.widget.textclock("%F %T")
        w.spacer = wibox.widget.textbox(" ")
        w.systray = wibox.widget.systray()
        w.netwidget = wibox.widget.textbox()
        vicious.register(w.netwidget, vicious.widgets.net, '<span color="#CC9393">${eth0 down_kb}</span> <span color="#7F9F7F">${eth0 up_kb}</span>', 3)
        w.right_layout:add(w.systray)
        w.right_layout:add(w.netwidget)
        w.right_layout:add(w.spacer)
        w.right_layout:add(w.textclock)
    end
    w.right_layout:add(w.layoutbox)
    w.layoutbox:buttons(awful.util.table.join(
        awful.button({ }, 1, inc_layout(1)),
        awful.button({ }, 3, inc_layout(-1))))
    w.layout:set_left(w.left_layout)
    w.layout:set_middle(w.tasklist)
    w.layout:set_right(w.right_layout)
    w.wibox:set_widget(w.layout)
    return w
end

for s = 1, screen.count() do
    screen_widgets[s] = create_screen_widgets(s)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mainmenu:toggle() end)
))
-- }}}

-- {{{ Key bindings
local globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey,           }, "z", awful.tag.history.restore),

    awful.key({ modkey }, "b", function ()
        screen_widgets[mouse.screen].wibox.visible = not screen_widgets[mouse.screen].wibox.visible
    end),

    awful.key({ modkey,           }, "j", function ()
        awful.client.focus.byidx( 1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey,           }, "k", function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey,           }, "w", function () mainmenu:show(true)        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j",  function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k",  function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey,           }, "a",  function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "j",  function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k",  function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "F1", function () awful.screen.focus(1)           end),
    awful.key({ modkey,           }, "F2", function () awful.screen.focus(2)           end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab", function ()
        awful.client.focus.history.previous()
        if client.focus then
            client.focus:raise()
        end
    end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "p", function () 
        local name = awful.tag.selected().name
        if app_info[name] and app_info[name].app then
            awful.util.spawn(app_info[name].app)
        end
    end),
    awful.key({ modkey, "Control" }, "l", function () awful.util.spawn("gnome-screensaver-command -l") end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", inc_layout(1)),
    awful.key({ modkey, "Shift"   }, "space", inc_layout(-1)),

    -- Prompt
    awful.key({ modkey },            "r",     function () screen_widgets[mouse.screen].promptbox:run() end),

    awful.key({ modkey }, "x", function ()
        awful.prompt.run({ prompt = "Run Lua code: " },
        screen_widgets[mouse.screen].promptbox.widget,
        awful.util.eval, nil,
        awful.util.getdir("cache") .. "/history_eval")
    end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m", function (c)
        c.maximized_horizontal = not c.maximized_horizontal
        c.maximized_vertical   = not c.maximized_vertical
    end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9, function ()
          local screen = awful.screen.focused()
          local tag = screen.tags[i]
          if tag then
            tag:view_only()
          end
        end),
        awful.key({ modkey, "Control" }, "#" .. i + 9, function ()
          local screen = awful.screen.focused()
          local tag = screen.tags[i]
          if tag then
            awful.tag.viewtoggle(tag)
          end
        end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9, function ()
          if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then
              client.focus:move_to_tag(tag)
            end
          end
        end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function ()
          if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then
              client.focus:toggle_tag(tag)
            end
          end
        end)
    )
end

local clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    { rule = {},
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

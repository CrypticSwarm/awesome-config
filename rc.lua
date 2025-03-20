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
local terminal = "ghostty"
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
  gears.wallpaper.maximized("/home/crypticswarm/Documents/lockerdome/images/decide-backgrounds/decide_wallpaper-06.jpg", s, true)
end
screen.connect_signal("property::geometry", set_wallpaper)

local screen_widgets = {}
function create_screen_widgets(s)
  set_wallpaper(s)
  local tagNames = { "dev", "chrome", "firefox", "file", 5, 6, 7, 8, 9 }
  awful.tag(tagNames, s, layouts[1])
  s.promptbox = awful.widget.prompt()
  s.layoutbox = awful.widget.layoutbox(s)
  s.launcher = awful.widget.launcher({ image = '/home/crypticswarm/Documents/lockerdome/images/decide-logos/Avatar-Logo-Icon-Decide-v1-128px.png', menu = mainmenu })
  s.taglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)
  s.tasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)
  s.wibox = awful.wibox({ position = "top", screen = s, height = 39 })
  local layout = wibox.layout.align.horizontal()
  local left_layout = wibox.layout.fixed.horizontal()
  local right_layout = wibox.layout.fixed.horizontal()
  left_layout:add(s.launcher)
  left_layout:add(s.taglist)
  left_layout:add(s.promptbox)
  local netwidget = wibox.widget.textbox()
  vicious.register(netwidget, vicious.widgets.net, '<span color="#CC9393">${enp24s0 down_kb}</span> <span color="#7F9F7F">${enp24s0 up_kb}</span>|<span color="#CC9393">${wlp0s20f3 down_kb}</span> <span color="#7F9F7F">${wlp0s20f3 up_kb}</span>', 3)
  right_layout:add(wibox.widget.systray())
  right_layout:add(netwidget)
  right_layout:add(wibox.widget.textbox(" "))
  right_layout:add(wibox.widget.textclock("%F %T"))
  right_layout:add(s.layoutbox)
  s.layoutbox:buttons(awful.util.table.join(
  awful.button({ }, 1, inc_layout(1)),
  awful.button({ }, 3, inc_layout(-1))))
  layout:set_left(left_layout)
  layout:set_middle(s.tasklist)
  layout:set_right(right_layout)
  s.wibox:set_widget(layout)
end

awful.screen.connect_for_each_screen(create_screen_widgets)
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
    local focused = awful.screen.focused()
    focused.wibox.visible = not focused.wibox.visible
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
  awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end),
  awful.key({ modkey,           }, "p", function () 
    local name = awful.tag.selected().name
    if app_info[name] and app_info[name].app then
      awful.spawn(app_info[name].app)
    end
  end),
  awful.key({ modkey, "Control" }, "l", function () awful.spawn("dm-tool lock") end),
  awful.key({ modkey, "Control" }, "r", awesome.restart),
  awful.key({ modkey, "Shift"   }, "q", awesome.quit),

  awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
  awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
  awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
  awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
  awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
  awful.key({ modkey, "Control" }, ";",     function () awful.tag.incncol(-1)         end),
  awful.key({ modkey,           }, "space", inc_layout(1)),
  awful.key({ modkey, "Shift"   }, "space", inc_layout(-1)),

  -- Prompt
  awful.key({ modkey },            "r",     function () awful.screen.focused().promptbox:run() end),

  awful.key({ modkey }, "x", function ()
    awful.prompt.run {
      prompt       "Run Lua code: ",
      textbox      = awful.screen.focused().promptbox.widget,
      exe_callback = awful.util.eval,
      history_path = awful.util.getdir("cache") .. "/history_eval"
    }
  end),

  awful.key({}, "Print", function () awful.spawn('gnome-screenshot -ai') end)
)

clientkeys = awful.util.table.join(
  awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
  awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
  awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
  awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
  awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end),
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
    properties = { 
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = true,
      keys = clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
  }
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

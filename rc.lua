-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")
require("wicked")
require("vicious")

function get_playing_song()
    local s = io.popen("quodlibet --print-playing")
    local str = s:read("*all")
    return str 
end

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
--beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")
beautiful.init("/home/max/.config/awesome/theme.lua")

-- Icons for Menues
note_icon = "/home/max/.config/awesome/note.png"
lock_icon = "/home/max/.config/awesome/lock.png"
terminal_icon = "/home/max/.config/awesome/terminal.png"

-- This is used later as the default terminal and editor to run.
terminal = 'gnome-terminal'
editor = os.getenv("EDITOR") or "jed"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
awful.layout.suit.floating,
awful.layout.suit.tile,
awful.layout.suit.tile.left,
awful.layout.suit.tile.bottom,
awful.layout.suit.tile.top,
awful.layout.suit.fair,
awful.layout.suit.fair.horizontal,
awful.layout.suit.spiral,
awful.layout.suit.spiral.dwindle,
awful.layout.suit.max,
awful.layout.suit.max.fullscreen,
awful.layout.suit.magnifier
}
-- }}}


	    -- {{{ Tags
	    -- Define a tag table which hold all screen tags.
	    tags = {
	      names = { "sys", "im", "www", "mail", 5, 6, 7, 8, 9 },
	      layout = { layouts[2], layouts[6], layouts[10], layouts[10],
	          layouts[6], layouts[6], layouts[6], layouts[6],
	          layouts[6]
	    }}
	    
	    for s = 1, screen.count() do
		-- Each screen has its own tag table.
		tags[s] = awful.tag(tags.names, s, tags.layout)
	    end
	    -- }}}

	    -- {{{ Menu
	    -- Create a laucher widget and a main menu
	    myawesomemenu = {
	        { "manual", terminal .. " -e man awesome" },
	        { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
	        { "restart", awesome.restart },
	        { "quit", awesome.quit }
	    }

	    quodlibetratemenu = {
	        { "0.0", "/usr/bin/quodlibet --set-rating=0.0" },
	        { "0.1", "/usr/bin/quodlibet --set-rating=0.1" },
	        { "0.2", "/usr/bin/quodlibet --set-rating=0.2" },
	        { "0.3", "/usr/bin/quodlibet --set-rating=0.3" },
	        { "0.4", "/usr/bin/quodlibet --set-rating=0.4" },
	        { "0.5", "/usr/bin/quodlibet --set-rating=0.5" },
	        { "0.6", "/usr/bin/quodlibet --set-rating=0.6" },
	        { "0.7", "/usr/bin/quodlibet --set-rating=0.7" },
	        { "0.8", "/usr/bin/quodlibet --set-rating=0.8" },
	        { "0.9", "/usr/bin/quodlibet --set-rating=0.9" },
	        { "1.0", "/usr/bin/quodlibet --set-rating=1.0" }
	    }
	    
	    quodlibetmenu = {
	        { "Start GUI", "/usr/bin/quodlibet" },
	        { "Play/Pause", "/usr/bin/quodlibet --play-pause" },
		{ "Next", "/usr/bin/quodlibet --next" },
		{ "Show/Hide Window", "/usr/bin/quodlibet --toggle-window" },
	        { "Rate Song", quodlibetratemenu }
	    }

	    mymainmenu = awful.menu({ 
	        items = { 
	            { "Awesome", myawesomemenu, beautiful.awesome_icon },
	            { "Terminal", terminal, terminal_icon },
        	    { "Lock Screen", "/usr/bin/xscreensaver-command -lock", lock_icon},
	            { "Quodlibet", quodlibetmenu, note_icon }
	        }
	    })

	    mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
	    menu = mymainmenu })
	    -- }}}

	    -- {{{ Wibox

	    -- spacer-widget
	    spacer = widget({ type = "textbox" })
	    spacer.text = " | "

	    -- actual_track_widget
	    actual_track_widget = widget({ type = 'imagebox' })
	    actual_track_widget.image = image("/home/max/.config/awesome/note.png")
	    
	    actual_track_widget_t = awful.tooltip({ objects = { actual_track_widget},})
	    actual_track_widget_t:set_text(get_playing_song())

	    playing_text_timer = timer({ timeout = 2 })
	    playing_text_timer:add_signal(
	        "timeout", 
		function () actual_track_widget_t:set_text(get_playing_song()) end
	    )
	    playing_text_timer:start()
	    
	    -- Create a textclock widget
	    mytextclock = awful.widget.textclock({ align = "right" })

	    -- Calendar widget to attach to the textclock
	    require('calendar2')
	    calendar2.addCalendarToWidget(mytextclock)
	    
	    -- RAM usage widget
	    memwidget = awful.widget.progressbar({ align = "right" })
	    memwidget:set_width(38)
	    memwidget:set_height(19)
	    memwidget:set_vertical(true)
	    memwidget:set_background_color('#111111')
	    memwidget:set_color('#000000')
	    memwidget:set_gradient_colors({ '#00AA00', '#00DD00', '#00FF00' })

	    -- RAM usage tooltip
	    memwidget_t = awful.tooltip({ objects = { memwidget.widget },})

	    vicious.cache(vicious.widgets.mem)
	    vicious.register(memwidget, vicious.widgets.mem,
	    function (widget, args)
		memwidget_t:set_text(" RAM: " .. args[2] .. "MB / " .. args[3] .. "MB ")
		return args[1]
	    end, 13)
	                     --update every 13 seconds

            -- CPU usage widget
	    cpuwidget = awful.widget.graph({ align = "right" })
	    cpuwidget:set_width(38)
	    cpuwidget:set_height(19)
	    cpuwidget:set_background_color("#111111")
	    cpuwidget:set_color("#000000")
	    cpuwidget:set_gradient_colors({ "#AA0000", "#DD0000", "#FF0000" })
	    cpuwidget_t = awful.tooltip({ objects = { cpuwidget.widget },})
	    
	    -- Register CPU widget
	    vicious.register(cpuwidget, vicious.widgets.cpu, 
	    function (widget, args)
		cpuwidget_t:set_text("CPU Usage: " .. args[1] .. "%")
		return args[1]
	    end)

	    -- Create a systray
	    mysystray = widget({ type = "systray" })

	    

	    -- Create a wibox for each screen and add it
	    mywibox = {}
	    mypromptbox = {}
	    mylayoutbox = {}
	    mytaglist = {}
	    mytaglist.buttons = awful.util.table.join(
	    awful.button({ }, 1, awful.tag.viewonly),
	    awful.button({ modkey }, 1, awful.client.movetotag),
	    awful.button({ }, 3, awful.tag.viewtoggle),
	    awful.button({ modkey }, 3, awful.client.toggletag),
	    awful.button({ }, 4, awful.tag.viewnext),
	    awful.button({ }, 5, awful.tag.viewprev)
	    )
	    mytasklist = {}
	    mytasklist.buttons = awful.util.table.join(
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
	end),
	awful.button({ }, 4, function ()
	awful.client.focus.byidx(1)
	if client.focus then client.focus:raise() end
    end),
    awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
end))
		

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
    awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
    awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
    return awful.widget.tasklist.label.currenttags(c, s)
end, mytasklist.buttons)

-- Create the wibox
mywibox[s] = awful.wibox({ position = "top", screen = s })



-- Add widgets to the wibox - order matters
mywibox[s].widgets = {
{
mylauncher,
mytaglist[s],
mypromptbox[s],

layout = awful.widget.layout.horizontal.leftright
},		
mylayoutbox[s],

mytextclock,
spacer,
actual_track_widget,
spacer,
memwidget.widget,
spacer,
cpuwidget.widget,
spacer,

s == 1 and mysystray or nil,
mytasklist[s],
layout = awful.widget.layout.horizontal.rightleft

}
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
awful.button({ }, 3, function () mymainmenu:toggle() end),
awful.button({ }, 4, awful.tag.viewnext),
awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
awful.key({ modkey, }, "Left", awful.tag.viewprev ),
awful.key({ modkey, }, "Right", awful.tag.viewnext ),
awful.key({ modkey, }, "Escape", awful.tag.history.restore),
awful.key({ modkey, "Control" }, "l", function () awful.util.spawn("xscreensaver-command -lock") end),

awful.key({ modkey, }, "j",
function ()
    awful.client.focus.byidx( 1)
    if client.focus then client.focus:raise() end
end),
awful.key({ modkey, }, "k",
function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
end),
awful.key({ modkey, }, "w", function () mymainmenu:show({keygrabber=true}) end),

-- Layout manipulation
awful.key({ modkey, "Shift" }, "j", function () awful.client.swap.byidx( 1) end),
awful.key({ modkey, "Shift" }, "k", function () awful.client.swap.byidx( -1) end),
awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
awful.key({ modkey, }, "u", awful.client.urgent.jumpto),
awful.key({ modkey, }, "Tab",
function ()
    awful.client.focus.history.previous()
    if client.focus then
	client.focus:raise()
    end
end),

-- Standard program
awful.key({ modkey, }, "Return", function () awful.util.spawn(terminal) end),
awful.key({ modkey, "Control" }, "r", awesome.restart),
awful.key({ modkey, "Shift" }, "q", awesome.quit),

awful.key({ modkey, }, "l", function () awful.tag.incmwfact( 0.05) end),
awful.key({ modkey, }, "h", function () awful.tag.incmwfact(-0.05) end),
awful.key({ modkey, "Shift" }, "h", function () awful.tag.incnmaster( 1) end),
awful.key({ modkey, "Shift" }, "l", function () awful.tag.incnmaster(-1) end),
awful.key({ modkey, "Control" }, "h", function () awful.tag.incncol( 1) end),
awful.key({ modkey, "Control" }, "l", function () awful.tag.incncol(-1) end),
awful.key({ modkey, }, "space", function () awful.layout.inc(layouts, 1) end),
awful.key({ modkey, "Shift" }, "space", function () awful.layout.inc(layouts, -1) end),

-- Prompt
awful.key({ modkey }, "r", function () mypromptbox[mouse.screen]:run() end),

awful.key({ modkey }, "x",
function ()
    awful.prompt.run({ prompt = "Run Lua code: " },
    mypromptbox[mouse.screen].widget,
    awful.util.eval, nil,
    awful.util.getdir("cache") .. "/history_eval")
end)
)

clientkeys = awful.util.table.join(
awful.key({ modkey, }, "f", function (c) c.fullscreen = not c.fullscreen end),
awful.key({ modkey, "Shift" }, "c", function (c) c:kill() end),
awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle ),
awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
awful.key({ modkey, }, "o", awful.client.movetoscreen ),
awful.key({ modkey, "Shift" }, "r", function (c) c:redraw() end),
awful.key({ modkey, }, "t", function (c) c.ontop = not c.ontop end),
awful.key({ modkey, }, "n", function (c) c.minimized = not c.minimized end),
awful.key({ modkey, }, "m",
function (c)
    c.maximized_horizontal = not c.maximized_horizontal
    c.maximized_vertical = not c.maximized_vertical
end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
    keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, "#" .. i + 9,
    function ()
	local screen = mouse.screen
	if tags[screen][i] then
	    awful.tag.viewonly(tags[screen][i])
	end
    end),
    awful.key({ modkey, "Control" }, "#" .. i + 9,
    function ()
	local screen = mouse.screen
	if tags[screen][i] then
	    awful.tag.viewtoggle(tags[screen][i])
	end
    end),
    awful.key({ modkey, "Shift" }, "#" .. i + 9,
    function ()
	if client.focus and tags[client.focus.screen][i] then
	    awful.client.movetotag(tags[client.focus.screen][i])
	end
    end),
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
    function ()
	if client.focus and tags[client.focus.screen][i] then
	    awful.client.toggletag(tags[client.focus.screen][i])
	end
    end))
end

clientbuttons = awful.util.table.join(
awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
awful.button({ modkey }, 1, awful.mouse.client.move),
awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
-- All clients will match this rule.
{ rule = { },
properties = { border_width = beautiful.border_width,
border_color = beautiful.border_normal,
focus = true,
keys = clientkeys,
buttons = clientbuttons } },
{ rule = { class = "MPlayer" },
properties = { floating = true } },
{ rule = { class = "pinentry" },
properties = { floating = true } },
{ rule = { class = "gimp" },
properties = { floating = true } },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
-- Add a titlebar
-- awful.titlebar.add(c, { modkey = modkey })

-- Enable sloppy focus
c:add_signal("mouse::enter", function(c)
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

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

awful.util.spawn_with_shell("gnome-terminal --window-with-profile=syswindow -x watch -n 10 'ping -c 1 google.de'", 1)
awful.util.spawn_with_shell("gnome-terminal --window-with-profile=syswindow -x tty-clock -cs", 1)
awful.util.spawn_with_shell("gnome-terminal --window-with-profile=syswindow -x htop", 1)
awful.util.spawn("xscreensaver -nosplash")

-- Solarized Dark Color Theme
require("termit.colormaps")
require("termit.utils")

defaults = {}
defaults.windowTitle = 'Termit'
defaults.tabName = 'Terminal'
defaults.encoding = 'UTF-8'
defaults.wordChars = '+-AA-Za-z0-9,./?%&#:_~'
defaults.font = 'Ubuntu Mono 13'
--defaults.foregroundColor = 'gray'
--defaults.backgroundColor = 'black'
defaults.showScrollbar = true
defaults.transparency = 0.0
--defaults.imageFile = '/tmp/img.png'
defaults.hideSingleTab = false
defaults.hideTabbar = false
defaults.hideMenubar = false
--defaults.fillTabbar = false
defaults.fillTabbar = true
defaults.scrollbackLines = 4096
defaults.geometry = '80x24'
defaults.allowChangingTitle = false
--defaults.backspaceBinding = 'AsciiBksp'
--defaults.deleteBinding = 'AsciiDel'
defaults.setStatusbar = function (tabInd)
    tab = tabs[tabInd]
    if tab then
        return tab.encoding..'  Bksp: '..tab.backspaceBinding..'  Del: '..tab.deleteBinding
    end
    return ''
end
--defaults.changeTitle = function (title)
--    print('title='..title)
--    newTitle = 'Termit: '..title
--    return newTitle
--end
defaults.colormap = {
    '#070736364242',
    '#dcdc32322f2f',
    '#858599990000',
    '#b5b589890000',
    '#26268b8bd2d2',
    '#d3d336368282',
    '#2a2aa1a19898',
    '#eeeee8e8d5d5',
    '#00002b2b3636',
    '#cbcb4b4b1616',
    '#58586e6e7575',
    '#65657b7b8383',
    '#838394949696',
    '#6c6c7171c4c4',
    '#9393a1a1a1a1',
    '#fdfdf6f6e3e3',
}
defaults.matches = {['http[^ ]+'] = function (url) print('Matching url: '..url) end}
--defaults.tabs = {{title = 'Test new tab 1'; workingDir = '/tmp'};
    --{title = 'Test new tab 2'; workingDir = '/tmp'}}
setOptions(defaults)

bindKey('Ctrl-Page_Up', prevTab)
bindKey('Ctrl-Page_Down', nextTab)
bindKey('Ctrl-F', findDlg)
bindKey('Ctrl-2', function () print('Hello2!') end)
bindKey('Ctrl-3', function () print('Hello3!') end)
bindKey('Ctrl-3', nil) -- remove previous binding

-- don't close tab with Ctrl-w, use CtrlShift-w
bindKey('Ctrl-w', nil)
bindKey('CtrlShift-w', closeTab)

setKbPolicy('keycode')

bindMouse('DoubleClick', openTab)

-- 
userMenu = {}
table.insert(userMenu, {name='Close tab', action=closeTab})
table.insert(userMenu, {name='New tab name', action=function () setTabTitle('New tab name') end})

mi = {}
mi.name = 'Zsh tab'
mi.action = function ()
    tabInfo = {}
    tabInfo.title = 'Zsh tab'
    tabInfo.command = 'zsh'
    tabInfo.encoding = 'UTF-8'
    tabInfo.workingDir = '/tmp'
    tabInfo.backspaceBinding = 'AsciiBksp'
    tabInfo.deleteBinding = 'EraseDel'
    openTab(tabInfo)
end
table.insert(userMenu, mi)

table.insert(userMenu, {name='set red color', action=function () setTabForegroundColor('red') end})
table.insert(userMenu, {name='Reconfigure', action=reconfigure, accel='Ctrl-r'})
table.insert(userMenu, {name='Selection', action=function () print(selection()) end})
table.insert(userMenu, {name='dumpAllRows', action=function () forEachRow(print) end})
table.insert(userMenu, {name='dumpVisibleRowsToFile',
    action=function () termit.utils.dumpToFile(forEachVisibleRow, '/tmp/termit.dump') end})
table.insert(userMenu, {name='findNext', action=findNext, accel='Alt-n'})
table.insert(userMenu, {name='findPrev', action=findPrev, accel='Alt-p'})
table.insert(userMenu, {name='new colormap', action=function () setColormap(termit.colormaps.mikado) end})
table.insert(userMenu, {name='toggle menubar', action=function () toggleMenubar() end})
table.insert(userMenu, {name='toggle tabbar', action=function () toggleTabbar()  end})

mi = {}
mi.name = 'Get tab info'
mi.action = function ()
    tab = tabs[currentTabIndex()]
    if tab then
        termit.utils.printTable(tab, '  ')
    end
end
table.insert(userMenu, mi)

function changeTabFontSize(delta)
    tab = tabs[currentTabIndex()]
    setTabFont(string.sub(tab.font, 1, string.find(tab.font, '%d+$') - 1)..(tab.fontSize + delta))
end

table.insert(userMenu, {name='Increase font size', action=function () changeTabFontSize(1) end})
table.insert(userMenu, {name='Decrease font size', action=function () changeTabFontSize(-1) end})
table.insert(userMenu, {name='feed example', action=function () feed('example') end})
table.insert(userMenu, {name='feedChild example', action=function () feedChild('date\n') end})
table.insert(userMenu, {name='User quit', action=quit})

addMenu(userMenu, "User menu")
addPopupMenu(userMenu, "User menu")

addMenu(termit.utils.encMenu(), "Encodings")
addPopupMenu(termit.utils.encMenu(), "Encodings")

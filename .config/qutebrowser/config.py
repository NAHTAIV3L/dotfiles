import os

config.load_autoconfig(False)

c.colors.webpage.darkmode.increase_text_contrast = True
c.colors.webpage.preferred_color_scheme = "dark"
c.qt.force_platformtheme = "dark"
c.scrolling.smooth = True
c.qt.force_software_rendering = "software-opengl"

if os.environ.get("WINDOWMANAGER") == "e":
    c.tabs.tabs_are_windows = True
else:
    c.tabs.tabs_are_windows = False

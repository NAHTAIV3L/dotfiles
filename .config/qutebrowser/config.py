import os

config.load_autoconfig(False)

c.colors.webpage.darkmode.increase_text_contrast = True
c.colors.webpage.preferred_color_scheme = "dark"
c.qt.force_platformtheme = "dark"
c.scrolling.smooth = True
c.qt.force_software_rendering = "software-opengl"
c.content.tls.certificate_errors = "load-insecurely"

config.bind('xs', 'config-cycle statusbar.show always never')
config.bind('xt', 'config-cycle tabs.show always never')
config.bind('xx', 'config-cycle tabs.show always never;; config-cycle statusbar.show always never')

if os.environ.get("WINDOWMANAGER") == "e":
    c.tabs.tabs_are_windows = True
    c.tabs.show = "never"
else:
    c.tabs.tabs_are_windows = False
    c.tabs.show = "always"

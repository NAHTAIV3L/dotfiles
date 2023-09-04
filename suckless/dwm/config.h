/* See LICENSE file for copyright and license details. */

#define BrightUp  0x1008FF02  /* Monitor/panel brightness */
#define BrightDn  0x1008FF03  /* Monitor/panel brightness */

#define VolumeDn  0x1008FF11   /* Volume control down        */
#define AudioMut  0x1008FF12   /* Mute sound from the system */
#define VolumeUp  0x1008FF13   /* Volume control up          */
#define MicMute   0x1008FFB2   /* Mute the Mic from the system */


/* appearance */
static const unsigned int borderpx  = 1;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int gappih    = 5;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 5;       /* vert inner gap between windows */
static const unsigned int gappoh    = 5;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 5;       /* vert outer gap between windows and screen edge */
static       int smartgaps          = 0;        /* 1 means no outer gap when there is only one window */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "DroidSansMono:size=9" };
static const char dmenufont[]       = "DroidSansMono:size=9";
/*
static const char col_gray1[]       = "#222222";
static const char col_gray2[]       = "#444444";
static const char col_gray3[]       = "#bbbbbb";
static const char col_gray4[]       = "#eeeeee";
static const char col_cyan[]        = "#005577";
*/

static const char col_gray1[]       = "#222222";
static const char col_gray2[]       = "#444444";
static const char col_gray3[]       = "#bbbbbb";
static const char col_gray4[]       = "#eeeeee";
static const char col_cyan[]        = "#350069";
static const char *colors[][3]      = {
    /*               fg         bg         border   */
    [SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
    [SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

#include "shiftview.c"

static const Rule rules[] = {
    /* xprop(1):
     *  WM_CLASS(STRING) = instance, class
     *  WM_NAME(STRING) = title
     */
    /* class      instance    title       tags mask     isfloating   monitor */
    { "Gimp",     NULL,       NULL,       0,            1,           -1 },
    { "Firefox",  NULL,       NULL,       1 << 8,            0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.5; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

#define FORCE_VSPLIT 1  /* nrowgrid layout: force two clients to always split vertically */
#include "vanitygaps.c"

static const Layout layouts[] = {
    /* symbol     arrange function */
    { "[]=",      tile },    /* first entry is default */
    { "[M]",      monocle },
    { "[@]",      spiral },
    { "[\\]",     dwindle },
    { "H[]",      deck },
    { "TTT",      bstack },
    { "===",      bstackhoriz },
    { "HHH",      grid },
    { "###",      nrowgrid },
    { "---",      horizgrid },
    { ":::",      gaplessgrid },
    { "|M|",      centeredmaster },
    { ">M>",      centeredfloatingmaster },
    { "><>",      NULL },    /* no layout function means floating behavior */
    { NULL,       NULL },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
    { MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
    { MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
    { MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[]   ={ "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, "-i", NULL };
static const char *termcmd[]    ={ "st", NULL };
static const char *firehome[]   ={ "firefox", NULL };
static const char *fireschool[] ={ "firefox", "-p", "School", NULL };
static const char *firec[]      ={ "firefoxchoice", NULL };
static const char *brightup[]   ={ "/bin/sh", "-c", "backlightctrl -inc 1 ; restartslstatus", NULL };
static const char *brightdn[]   ={ "/bin/sh", "-c", "backlightctrl -dec 1 ; restartslstatus", NULL };
static const char *brightup1[]  ={ "/bin/sh", "-c", "backlightctrl -inc 5 ; restartslstatus", NULL };
static const char *brightdn1[]  ={ "/bin/sh", "-c", "backlightctrl -dec 5 ; restartslstatus", NULL };
static const char *volup[]      ={ "/bin/sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ +1% ; restartslstatus", NULL };
static const char *voldn[]      ={ "/bin/sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ -1% ; restartslstatus", NULL };
static const char *volup5[]     ={ "/bin/sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ +5% ; restartslstatus", NULL };
static const char *voldn5[]     ={ "/bin/sh", "-c", "pactl set-sink-volume @DEFAULT_SINK@ -5% ; restartslstatus", NULL };
static const char *volmute[]    ={ "/bin/sh", "-c", "pactl set-sink-mute @DEFAULT_SINK@ toggle ; restartslstatus", NULL };
static const char *suspend[]    ={ "loginctl", "suspend", NULL };
static const char *hibernate[]  ={ "loginctl", "hibernate", NULL };
static const char *bookmarkadd[]={ "/bin/sh", "-c", "bkmrkcli -a", NULL };
static const char *bookmarkdel[]={ "/bin/sh", "-c", "bkmrkcli -d", NULL };
static const char *bookmarktyp[]={ "/bin/sh", "-c", "bkmrkcli -p", NULL };
static const char *unmounter[]  ={ "unmounter", NULL };
static const char *mounter[]    ={ "mounter", NULL };
static const char *startemacs[] ={ "emacsconnect", NULL };
static const char *eeverywhere[]={ "/bin/sh", "-c", "doom +everywhere", NULL };
static const char *rstartemacs[]={ "restartemacs", NULL };
static const char *qutebrowser[]={ "qutebrowser", NULL };

static const Key keys[] = {
    /* modifier                     key        function        argument */
    { MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
    { MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
    { MODKEY,                       XK_w,      spawn,          {.v = firehome } },
    { MODKEY|ShiftMask,             XK_w,      spawn,          {.v = fireschool } },
    { MODKEY|ControlMask,           XK_w,      spawn,          {.v = firec } },
    { MODKEY,                       XK_o,      spawn,          {.v = qutebrowser } },
    { MODKEY|ShiftMask,             XK_b,      togglebar,      {0} },
    { MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
    { MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
    { MODKEY|ShiftMask,             XK_k,      incnmaster,     {.i = +1 } },
    { MODKEY|ShiftMask,             XK_j,      incnmaster,     {.i = -1 } },
    { MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
    { MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
    { MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
    /* { MODKEY|Mod4Mask,              XK_u,      incrgaps,       {.i = +1 } }, */
    /* { MODKEY|Mod4Mask|ShiftMask,    XK_u,      incrgaps,       {.i = -1 } }, */
    /* { MODKEY|Mod4Mask,              XK_i,      incrigaps,      {.i = +1 } }, */
    /* { MODKEY|Mod4Mask|ShiftMask,    XK_i,      incrigaps,      {.i = -1 } }, */
    /* { MODKEY|Mod4Mask,              XK_o,      incrogaps,      {.i = +1 } }, */
    /* { MODKEY|Mod4Mask|ShiftMask,    XK_o,      incrogaps,      {.i = -1 } }, */
    /* { MODKEY|Mod4Mask,              XK_6,      incrihgaps,     {.i = +1 } }, */
    /* { MODKEY|Mod4Mask|ShiftMask,    XK_6,      incrihgaps,     {.i = -1 } }, */
    /* { MODKEY|Mod4Mask,              XK_7,      incrivgaps,     {.i = +1 } }, */
    /* { MODKEY|Mod4Mask|ShiftMask,    XK_7,      incrivgaps,     {.i = -1 } }, */
    /* { MODKEY|Mod4Mask,              XK_8,      incrohgaps,     {.i = +1 } }, */
    /* { MODKEY|Mod4Mask|ShiftMask,    XK_8,      incrohgaps,     {.i = -1 } }, */
    /* { MODKEY|Mod4Mask,              XK_9,      incrovgaps,     {.i = +1 } }, */
    /* { MODKEY|Mod4Mask|ShiftMask,    XK_9,      incrovgaps,     {.i = -1 } }, */
    /* { MODKEY|Mod4Mask,              XK_0,      togglegaps,     {0} }, */
    /* { MODKEY|Mod4Mask|ShiftMask,    XK_0,      defaultgaps,    {0} }, */
    { MODKEY,                       XK_Tab,    view,           {0} },
    { MODKEY|ShiftMask,             XK_c,      killclient,     {0} },
    { MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
    { MODKEY,                       XK_comma,  cyclelayout,    {.i = -1 } },
    { MODKEY,                       XK_period, cyclelayout,    {.i = +1 } },
    /* { MODKEY,                       XK_space,  setlayout,      {0} }, */
    { MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
    { MODKEY,                       XK_f,      togglefullscr,  {0} },
    { MODKEY,                       XK_0,      view,           {.ui = ~0 } },
    { MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
    { MODKEY|ControlMask,           XK_comma,  focusmon,       {.i = -1 } },
    { MODKEY|ControlMask,           XK_period, focusmon,       {.i = +1 } },
    { MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
    { MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
    { MODKEY,                       XK_n,      shiftview,      {.i = +1 } },
    { MODKEY,                       XK_b,      shiftview,      {.i = -1 } },
    { 0,                            BrightUp,  spawn,          {.v = brightup } },
    { 0,                            BrightDn,  spawn,          {.v = brightdn } },
    { ShiftMask,                    BrightUp,  spawn,          {.v = brightup1 } },
    { ShiftMask,                    BrightDn,  spawn,          {.v = brightdn1 } },
    { 0,                            VolumeUp,  spawn,          {.v = volup } },
    { 0,                            VolumeDn,  spawn,          {.v = voldn } },
    { ShiftMask,                    VolumeUp,  spawn,          {.v = volup5 } },
    { ShiftMask,                    VolumeDn,  spawn,          {.v = voldn5 } },
    { 0,                            AudioMut,  spawn,          {.v = volmute } },
    { MODKEY|ShiftMask,             XK_x,      spawn,          {.v = suspend } },
    { MODKEY|ShiftMask,             XK_z,      spawn,          {.v = hibernate } },
    { MODKEY,                       XK_s,      spawn,          {.v = bookmarktyp } },
    { MODKEY|ShiftMask,             XK_s,      spawn,          {.v = bookmarkadd } },
    { MODKEY|ShiftMask|ControlMask, XK_s,      spawn,          {.v = bookmarkdel } },
    { ShiftMask,                    XK_F8,     spawn,          {.v = unmounter } },
    { ShiftMask,                    XK_F9,     spawn,          {.v = mounter } },
    { MODKEY,                       XK_e,      spawn,          {.v = startemacs} },
    { MODKEY|ShiftMask,             XK_e,      spawn,          {.v = eeverywhere} },
    { MODKEY,                       XK_r,      spawn,          {.v = rstartemacs} },
    TAGKEYS(                        XK_1,                      0)
    TAGKEYS(                        XK_2,                      1)
    TAGKEYS(                        XK_3,                      2)
    TAGKEYS(                        XK_4,                      3)
    TAGKEYS(                        XK_5,                      4)
    TAGKEYS(                        XK_6,                      5)
    TAGKEYS(                        XK_7,                      6)
    TAGKEYS(                        XK_8,                      7)
    TAGKEYS(                        XK_9,                      8)
    { MODKEY|ShiftMask,             XK_q,      quit,           {0} },
    { MODKEY|ControlMask|ShiftMask, XK_q,      quit,           {1} },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
    /* click                event mask      button          function        argument */
    { ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
    { ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
    { ClkWinTitle,          0,              Button2,        zoom,           {0} },
    { ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
    { ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
    { ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
    { ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
    { ClkTagBar,            0,              Button1,        view,           {0} },
    { ClkTagBar,            0,              Button3,        toggleview,     {0} },
    { ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
    { ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};


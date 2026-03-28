" ABOUTME: Lightline colorscheme based on Rosé Pine Moon.
" ABOUTME: Overrides tabsel to use pine blue instead of love/gold.

let s:base    = '#232136'
let s:surface = '#2a273f'
let s:overlay = '#393552'
let s:muted   = '#6e6a86'
let s:subtle  = '#908caa'
let s:text    = '#e0def4'
let s:love    = '#eb6f92'
let s:gold    = '#f6c177'
let s:pine    = '#3e8fb0'
let s:foam    = '#9ccfd8'
let s:iris    = '#c4a7e7'

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}

let s:p.normal.left    = [[s:base, s:pine], [s:text, s:overlay]]
let s:p.normal.middle  = [[s:subtle, s:surface]]
let s:p.normal.right   = [[s:base, s:pine], [s:text, s:overlay]]
let s:p.normal.error   = [[s:love, s:surface]]
let s:p.normal.warning = [[s:gold, s:surface]]

let s:p.insert.left    = [[s:base, s:foam], [s:text, s:overlay]]
let s:p.insert.middle  = [[s:subtle, s:surface]]
let s:p.insert.right   = [[s:base, s:foam], [s:text, s:overlay]]

let s:p.visual.left    = [[s:base, s:iris], [s:text, s:overlay]]
let s:p.visual.middle  = [[s:subtle, s:surface]]
let s:p.visual.right   = [[s:base, s:iris], [s:text, s:overlay]]

let s:p.replace.left   = [[s:base, s:love], [s:text, s:overlay]]
let s:p.replace.middle = [[s:subtle, s:surface]]
let s:p.replace.right  = [[s:base, s:love], [s:text, s:overlay]]

let s:p.inactive.left   = [[s:muted, s:surface], [s:muted, s:surface]]
let s:p.inactive.middle = [[s:muted, s:surface]]
let s:p.inactive.right  = [[s:muted, s:surface], [s:muted, s:surface]]

" Tabline: active buffer uses pine (not love/gold which signals errors/warnings)
let s:p.tabline.left   = [[s:subtle, s:surface]]
let s:p.tabline.tabsel = [[s:base, s:pine]]
let s:p.tabline.middle = [[s:muted, s:surface]]
let s:p.tabline.right  = [[s:muted, s:surface]]

let g:lightline#colorscheme#rosepine_patched#palette = lightline#colorscheme#fill(s:p)

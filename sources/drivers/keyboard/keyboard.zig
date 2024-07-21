const kernel = @import("kernel");
const libk = @import("libk");

const vga = @import("../vga/vga.zig");

var caps_on: bool = false;
var caps_lock: bool = false;
var num_lock: bool = false;

var keyboard_toggle : bool = true;

pub const UNKNOWN = 0xFFFFFFFF;
pub const ESC = 0xFFFFFFFF - 1;
pub const CTRL = 0xFFFFFFFF - 2;
pub const LSHFT = 0xFFFFFFFF - 3;
pub const RSHFT = 0xFFFFFFFF - 4;
pub const ALT = 0xFFFFFFFF - 5;
pub const F1 = 0xFFFFFFFF - 6;
pub const F2 = 0xFFFFFFFF - 7;
pub const F3 = 0xFFFFFFFF - 8;
pub const F4 = 0xFFFFFFFF - 9;
pub const F5 = 0xFFFFFFFF - 10;
pub const F6 = 0xFFFFFFFF - 11;
pub const F7 = 0xFFFFFFFF - 12;
pub const F8 = 0xFFFFFFFF - 13;
pub const F9 = 0xFFFFFFFF - 14;
pub const F10 = 0xFFFFFFFF - 15;
pub const F11 = 0xFFFFFFFF - 16;
pub const F12 = 0xFFFFFFFF - 17;
pub const SCRLCK = 0xFFFFFFFF - 18;
pub const HOME = 0xFFFFFFFF - 19;
pub const UP = 0xFFFFFFFF - 20;
pub const LEFT = 0xFFFFFFFF - 21;
pub const RIGHT = 0xFFFFFFFF - 22;
pub const DOWN = 0xFFFFFFFF - 23;
pub const PGUP = 0xFFFFFFFF - 24;
pub const PGDOWN = 0xFFFFFFFF - 25;
pub const END = 0xFFFFFFFF - 26;
pub const INS = 0xFFFFFFFF - 27;
pub const DEL = 0xFFFFFFFF - 28;
pub const CAPS = 0xFFFFFFFF - 29;
pub const NONE = 0xFFFFFFFF - 30;
pub const ALTGR = 0xFFFFFFFF - 31;
pub const NUMLCK = 0xFFFFFFFF - 32;
pub const BACKSPACE = 0x08;

const lowercase = [128]u32 {
    UNKNOWN,ESC,'1','2','3','4','5','6','7','8',
    '9','0','-','=',BACKSPACE,'\t','q','w','e','r',
    't','y','u','i','o','p','[',']','\n',CTRL,
    'a','s','d','f','g','h','j','k','l',';',
    '\'','`',LSHFT,'\\','z','x','c','v','b','n','m',',',
    '.','/',RSHFT,'*',ALT,' ',CAPS,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,NUMLCK,SCRLCK,HOME,UP,PGUP,'-',LEFT,UNKNOWN,RIGHT,
    '+',END,DOWN,PGDOWN,INS,DEL,UNKNOWN,UNKNOWN,UNKNOWN,F11,F12,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,
    UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,
    UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,
    UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN
};

const uppercase = [128]u32 {
    UNKNOWN,ESC,'!','@','#','$','%','^','&','*','(',')','_','+',BACKSPACE,'\t','Q','W','E','R',
    'T','Y','U','I','O','P','{','}','\n',CTRL,'A','S','D','F','G','H','J','K','L',':','"','~',LSHFT,'|','Z','X','C',
    'V','B','N','M','<','>','?',RSHFT,'*',ALT,' ',CAPS,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,NUMLCK,SCRLCK,HOME,UP,PGUP,'-',
    LEFT,UNKNOWN,RIGHT,'+',END,DOWN,PGDOWN,INS,DEL,UNKNOWN,UNKNOWN,UNKNOWN,F11,F12,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,
    UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,
    UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,
    UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN
};

var current_key_pressed: u32 = 0;

pub fn getCurrentKeyPressed() u32
{
    const ret = current_key_pressed;
    current_key_pressed = 0; // reset key to avoid stupidly fast key repeat
    return ret;
}

pub fn disableKeyboard() void
{
    keyboard_toggle = false;
}

pub fn keyboardHandler(regs: *kernel.arch.idt.IDTRegister) void
{
    _ = regs;
    const scan_code = kernel.arch.ports.in(u8, 0x60) & 0x7F;
    const press = kernel.arch.ports.in(u8, 0x60) & 0x80;

    switch(scan_code)
    {
        59...66, 69 => // control keys
        {
            if(scan_code == 69)
            {
                if(!caps_lock and press == 0)
                    caps_lock = true
                else if(caps_lock and press == 0)
                    caps_lock = false;
                return;
            }
            if(press != 0)
                current_key_pressed = 0
            else if(scan_code >= 59 and scan_code <= 66)
                vga.changeScreen(scan_code - 59);
            return;
        },
        else => {}
    }

    if(keyboard_toggle == false)
        return;

    switch(scan_code)
    {
        42, 54 =>
        {
            caps_on = press == 0;
            return;
        },
        else =>
        {
            if(press != 0)
                current_key_pressed = 0
            else if(caps_on or caps_lock)
                current_key_pressed = uppercase[scan_code]
            else
                current_key_pressed = lowercase[scan_code];
        }
    }
}

pub fn init() void
{
    @setCold(true);
    kernel.logs.klogln("[PS/2 Keyboard Driver] loading...");
    kernel.arch.idt.irqInstallHandler(1, &keyboardHandler);
    kernel.logs.klogln("[PS/2 Keyboard Driver] loaded");
}


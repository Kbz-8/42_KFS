const kernel = @import("kernel");
const vga = @import("../vga/vga.zig");
var capsOn : bool = false;
var capsLock : bool = false;

const  UNKNOWN : u32 = 0xFFFFFFFF;
const  ESC : u32 = 0xFFFFFFFF - 1;
const  CTRL : u32 = 0xFFFFFFFF - 2;
const  LSHFT : u32 = 0xFFFFFFFF - 3;
const  RSHFT : u32 = 0xFFFFFFFF - 4;
const  ALT : u32 = 0xFFFFFFFF - 5;
const  F1 : u32 = 0xFFFFFFFF - 6;
const  F2 : u32 = 0xFFFFFFFF - 7;
const  F3 : u32 = 0xFFFFFFFF - 8;
const  F4 : u32 = 0xFFFFFFFF - 9;
const  F5 : u32 = 0xFFFFFFFF - 10;
const  F6 : u32 = 0xFFFFFFFF - 11;
const  F7 : u32 = 0xFFFFFFFF - 12;
const  F8 : u32 = 0xFFFFFFFF - 13;
const  F9 : u32 = 0xFFFFFFFF - 14;
const  F10 : u32 = 0xFFFFFFFF - 15;
const  F11 : u32 = 0xFFFFFFFF - 16;
const  F12 : u32 = 0xFFFFFFFF - 17;
const  SCRLCK : u32 = 0xFFFFFFFF - 18;
const  HOME : u32 = 0xFFFFFFFF - 19;
const  UP : u32 = 0xFFFFFFFF - 20;
const  LEFT : u32 = 0xFFFFFFFF - 21;
const  RIGHT : u32 = 0xFFFFFFFF - 22;
const  DOWN : u32 = 0xFFFFFFFF - 23;
const  PGUP : u32 = 0xFFFFFFFF - 24;
const  PGDOWN : u32 = 0xFFFFFFFF - 25;
const  END : u32 = 0xFFFFFFFF - 26;
const  INS : u32 = 0xFFFFFFFF - 27;
const  DEL : u32 = 0xFFFFFFFF - 28;
const  CAPS : u32 = 0xFFFFFFFF - 29;
const  NONE : u32 = 0xFFFFFFFF - 30;
const  ALTGR : u32 = 0xFFFFFFFF - 31;
const  NUMLCK : u32 = 0xFFFFFFFF - 32;


const lowercase = [128]u32 {
UNKNOWN,ESC,'1','2','3','4','5','6','7','8',
'9','0','-','=',0x08,'\t','q','w','e','r',
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
    UNKNOWN,ESC,'!','@','#','$','%','^','&','*','(',')','_','+',0x08,'\t','Q','W','E','R',
'T','Y','U','I','O','P','{','}','\n',CTRL,'A','S','D','F','G','H','J','K','L',':','"','~',LSHFT,'|','Z','X','C',
'V','B','N','M','<','>','?',RSHFT,'*',ALT,' ',CAPS,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,NUMLCK,SCRLCK,HOME,UP,PGUP,'-',
LEFT,UNKNOWN,RIGHT,'+',END,DOWN,PGDOWN,INS,DEL,UNKNOWN,UNKNOWN,UNKNOWN,F11,F12,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,
UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,
UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,
UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN
};


var keybuffer: [256]u8 = .{0} ** 256;

pub fn keyboardHandler(regs : *kernel.idt.IDT_Register) void
{
    _ = regs;
    const scanCode = kernel.ports.in(u8, 0x60) & 0x7F;
    const press = kernel.ports.in(u8, 0x60) & 0x80;
    switch (scanCode)
    {
        1, 29, 56, 59...68, 87, 88 => return,
        42 =>
        {
            //shift key
            if (press == 0)
            {
                capsOn = true;
            }
            else
            {
                capsOn = false;
            }
            return;
        },
        58 =>
        {
            if (!capsLock and press == 0)
            {
                capsLock = true;
            }
            else if (capsLock and press == 0)
            {
                capsLock = false;
            }
            return;
        },
        else =>
        {
            if (press == 0)
            {
                if (capsOn or capsLock)
                {
                    vga.putChar(@truncate(uppercase[scanCode]));
                }
                else
                {
                    vga.putChar(@truncate(lowercase[scanCode]));
                }
            }
        }
    }
    
}

pub fn init() void
{
    @setCold(true);
    kernel.logs.klog("[PS/2 Keyboard Driver] loading...");
    kernel.idt.irq_install_handler(1, &keyboardHandler);
    kernel.logs.klog("[PS/2 Keyboard Driver] loaded");
}


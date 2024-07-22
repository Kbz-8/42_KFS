const libk = @import("libk");
const drivers = @import("drivers");

const logs = @import("../log.zig");
const stk = @import("../debug/stack_trace.zig");
const kpanic = @import("../panic.zig").kpanic;

pub const DumbShell = struct
{
    buffer: [256]u8 = undefined,
    halt: bool = false,

    fn getInputLine(self: *DumbShell) void
    {
        var i: usize = libk.str.strlen(&self.buffer);
        while(true)
        {
            const key: u32 = drivers.kb.getCurrentKeyPressed();
            if(self.halt)
            {
                if(key == drivers.kb.PGUP)
                    drivers.vga.reverseScroll()
                else if(key == drivers.kb.PGDOWN)
                    drivers.vga.scroll();
                if(key == drivers.kb.LEFT)
                    drivers.vga.moveCursor(.Left)
                else if(key == drivers.kb.RIGHT)
                    drivers.vga.moveCursor(.Right)
                else if(key == drivers.kb.UP)
                    drivers.vga.moveCursor(.Up)
                else if(key == drivers.kb.DOWN)
                    drivers.vga.moveCursor(.Down)
                else if(key == drivers.kb.BACKSPACE)
                    drivers.vga.backspace()
                else
                    libk.io.kputchar(@truncate(key));
                continue;
            }
            if(key == 0 or key == drivers.kb.UNKNOWN)
                continue;
            if(key == drivers.kb.LEFT)
            {
                if(i > 0)
                {
                    drivers.vga.moveCursor(.Left);
                    i -= 1;
                }
            }
            else if(key == drivers.kb.RIGHT)
            {
                if(i < libk.str.strlen(&self.buffer))
                {
                    drivers.vga.moveCursor(.Right);
                    i += 1;
                }
            }
            else if(key == drivers.kb.BACKSPACE)
            {
                if(libk.str.strlen(&self.buffer) > 0 and i > 0)
                {
                    drivers.vga.backspace();
                    self.buffer[i - 1] = 0;
                    i -= 1;
                    for(i..self.buffer.len - 1) |j|
                    {
                        self.buffer[j] = 0;
                        self.buffer[j] = self.buffer[j + 1];
                    }
                }
            }
            else if(key == '\n')
            {
                libk.io.kputchar('\n');
                return;
            }
            else if(key < 256) // to accept only printable keys
            {
                libk.io.kputchar(@truncate(key));
                var j: usize = self.buffer.len - 1;
                while(j > i) : (j -= 1)
                {
                    self.buffer[j] = 0;
                    self.buffer[j] = self.buffer[j - 1];
                }
                self.buffer[i] = @truncate(key);
                if(libk.str.strlen(&self.buffer) == self.buffer.len)
                    return;
                i += 1;
            }
        }
    }

    pub fn pause(self: *DumbShell) void
    {
        self.halt = true;
    }

    pub fn run(self: *DumbShell) void
    {
        self.halt = false;
    }

    pub fn launch(self: *DumbShell) void
    {
        libk.io.kputs("Welcome to RatiOS !\n\n");
        while(true)
        {
            if(self.halt)
                continue;
            libk.io.kputs("shell > ");
            _ = libk.mem.memset(&self.buffer, 0, self.buffer.len);
            getInputLine(self);
            if(libk.str.strlen(&self.buffer) == 0)
                continue
            else if(libk.str.streqlnt(&self.buffer, "shutdown"))
                break
            else if(libk.str.streqlnt(&self.buffer, "exit"))
                break
            else if(libk.str.streqlnt(&self.buffer, "reboot"))
                drivers.power.reboot()
            else if(libk.str.streqlnt(&self.buffer, "stack"))
                stk.stackTrace(8)
            else if(libk.str.streqlnt(&self.buffer, "panic"))
                kpanic("shell request")
            else if(libk.str.streqlnt(&self.buffer, "ratio"))
                kpanic("ratio")
            else if(libk.str.streqlnt(&self.buffer, "stfu"))
                drivers.kb.disableKeyboard()
            else if(libk.str.streqlnt(&self.buffer, "whoami"))
                libk.io.kputs("bozoman\n")
            else if(libk.str.streqlnt(&self.buffer, "journal"))
            {
                libk.io.kputs("================ Journal ================\n");
                libk.io.kputs(logs.getLogBuffer());
                libk.io.kputs("================ Journal ================\n");
            }
			else if (libk.str.streqlnt(&self.buffer, "help"))
			{
				libk.io.kputs("================ Help ================\n");
				libk.io.kputs("shutdown/exit -> shutdown RatiOS\n");
				libk.io.kputs("reboot -> reboot RatiOS\n");
				libk.io.kputs("journal -> prints the kernel logs\n");
				libk.io.kputs("stack -> prints the stack trace\n");
				libk.io.kputs("panic -> trigger a kernel panic\n");
				libk.io.kputs("stfu -> shutdown the keyboard\n");
				libk.io.kputs("clear -> clears the shell\n");
				libk.io.kputs("================ Help ================\n");
			}
			else if (libk.str.streqlnt(&self.buffer, "clear"))
			{
				drivers.vga.scroll_buffer_clear(drivers.vga.Color.BLACK);
			}
            else
                libk.io.kprintf("command not found: {}\n", .{ &self.buffer });
        }
    }
};

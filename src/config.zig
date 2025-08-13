pub const Config = struct {
    pub const enable_logs = true;
    pub const log_level: LogLevel = .info; // .trace | .debug | .info | .warn | .err
    pub const enable_paging = true;
    pub const enable_scheduler = false;
    pub const max_drivers = 64; // registry capacity (adjust for build)
    pub const print_sinks = 8; // kprint capacity
};

pub const LogLevel = enum {
    trace,
    debug,
    info,
    warn,
    err,
};

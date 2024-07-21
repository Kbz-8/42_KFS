all :
	@zig build -Ddebug=false

debug:
	@zig build -Ddebug=true

run : fclean
	@zig build run -Ddebug=false

run-debug : fclean
	@zig build run -Ddebug=true

run-debugger : fclean
	@zig build run-debug -Ddebug=true

clean:
	@rm -rf .zig_cache

fclean:
	@rm -rf zig-out

.PHONY : all run

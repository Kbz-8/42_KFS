all :
	@zig build

debug:
	@zig build -Ddebug=true

run : fclean
	@zig build run

run-debug : fclean
	@zig build run-debug -Ddebug=true

clean:

fclean : clean
	@rm -rf zig-out

.PHONY : all run

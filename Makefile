all :
	@zig build

run : fclean
	@zig build run

run-debug : fclean
	@zig build run-debug

clean:

fclean : clean
	@rm -rf zig-out

.PHONY : all run

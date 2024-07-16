all :
	@zig build

run :
	@zig build run

run-debug :
	@zig build run-debug

clean:

fclean : clean
	@rm -rf zig-out

.PHONY : all run

all :
	@zig build

run :
	@zig build run

clean:
	@rm -rf zig-cache

fclean : clean
	@rm -rf zig-out

.PHONY : all run

all :
	@zig build

run :
	@zig build run

clean:

fclean : clean
	@rm -rf zig-out

.PHONY : all run

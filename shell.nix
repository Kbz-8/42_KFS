{
	pkgs ? import <nixpkgs> {},
}:

pkgs.mkShell {
	nativeBuildInputs = with pkgs; [
		qemu
		grub2
		mtools
		neovim
		nodejs_22
	];
	shellHook = 
	''
		exec zsh
	'';
}

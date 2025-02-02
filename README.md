# Zig-Zag engine
#### This is a game engine mainly made to learn how game engines function and make my production of games faster.

It was made in zig in order to force me to understand further the concepts I am using to make it.\
It will heavily be inspired by the Unreal Engine for the 3D part, Unity for 2D and Godot for ease of use and appeal
#### A website will be made to showcase it's capabilities and for a wiki and quicker communication
# How to build it:
#### Thanks to Zig's build steps it is quite easy to build it!
1. Make sure you have Zig 0.13 installed
2. Then clone this repository
3. Open terminal in the root ofthe engine (the directory containing build.zig)
4. Then in the terminal run :
`zig build`.
Inside the zig-out/bin dirctory, you will find gameEngine.exe that you can run

# Build options
#### To take advantage of Zig's powerful build option, I aimed to add optional parameters.
As of now, the only parameter is UNICODE and it is  boolean (true or false).\
To change it, when running the build command add -DUNICODE=[true or false], like this :\
`zig build -DUNICODE=true`\
It is true by default and a false value will return a compile error, because I did not add support for non Unicode characters for now
# TODO
* Add releases so it is easier to install

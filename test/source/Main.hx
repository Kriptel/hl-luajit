package;

import luajit.LuaJIT;

function main() {
	LuaJIT.init();

	var state = LuaL.newstate();
	LuaL.openlibs(state);

	LuaJIT.addCallback(state, 'haxeFunction', function(a:Int, b:String, c:Bool) {
		trace(a, b, c);
	});

	LuaL.dostring(state, '
	local a = 0
	print(a)

	haxeFunction(1,"hello world",true)

	function luaFunction(a,b,c)
		print(a,b,c)

		return 123;
	end
	');

	Lua.getGlobal(state, "luaFunction");

	trace(Lua.dynCall(state, [12, 35, 'hello world'], 1)); // 123
}

package luajit;

import haxe.Constraints.Function;
import hl.I64;

@:access(String)
class LuaJIT {
	public static function init() {
		setCallbackFunction(__callbackFunction);
	}

	static var __callbacks:Map<LuaState, Map<String, Function>> = [];

	inline public static function addCallback(state:LuaState, functionName:String, callback:Function):Void {
		_LuaJIT.add_callback(state, functionName);
		getCallbacks(state)[functionName] = callback;
	}

	inline public static function getCallback(state:LuaState, functionName:String):Function {
		return getCallbacks(state)[functionName];
	}

	inline public static function getCallbacks(state:LuaState):Map<String, Function> {
		return __callbacks[state] ??= new Map<String, Function>();
	}

	public static function setCallbackFunction(callback:(state:LuaState, functionName:String) -> Void):Void {
		_LuaJIT.set_callback_function((bytes) -> {
			callback(_LuaJIT.__getState(), String.fromUTF8(bytes));
		});
	}

	private static function __callbackFunction(state:LuaState, functionName:String) {
		var args:Array<Dynamic> = [
			for (i in 1...Lua.getTop(state) + 1) {
				Lua.toDynamic(state, i);
			}
		];

		final func = LuaJIT.getCallback(state, functionName);

		Reflect.callMethod(null, func, args);
	}
}

enum abstract LuaType(Int) from Int to Int {
	var NONE = -1;
	var NIL = 0;
	var BOOLEAN = 1;
	var LIGHTUSERDATA = 2;
	var NUMBER = 3;
	var STRING = 4;
	var TABLE = 5;
	var FUNCTION = 6;
	var USERDATA = 7;
	var THREAD = 8;

	inline public function toString():String {
		return switch (this) {
			case NONE: 'none';
			case NIL: 'nil';
			case BOOLEAN: 'boolean';
			case LIGHTUSERDATA: 'lightuserdata';
			case NUMBER: 'number';
			case STRING: 'string';
			case TABLE: 'table';
			case FUNCTION: 'function';
			case USERDATA: 'userdata';
			case THREAD: 'thread';
			default: null;
		}
	}
}

class Lua {
	public static function close(state:LuaState):Void {
		_LuaJIT.lua_close(state);
	}

	public static function newthread(state:LuaState):LuaState {
		return _LuaJIT.lua_newthread(state);
	}

	public static function getTop(state:LuaState):Int {
		return _LuaJIT.lua_gettop(state);
	}

	public static function setTop(state:LuaState, idx:Int):Void {
		_LuaJIT.lua_settop(state, idx);
	}

	public static function pushValue(state:LuaState, idx:Int):Void {
		_LuaJIT.lua_pushvalue(state, idx);
	}

	public static function remove(state:LuaState, idx:Int):Void {
		_LuaJIT.lua_remove(state, idx);
	}

	public static function insert(state:LuaState, idx:Int):Void {
		_LuaJIT.lua_insert(state, idx);
	}

	public static function replace(state:LuaState, idx:Int):Void {
		_LuaJIT.lua_replace(state, idx);
	}

	public static function checkStack(state:LuaState, sz:Int):Int {
		return _LuaJIT.lua_checkstack(state, sz);
	}

	public static function xmove(state:LuaState, to:LuaState, n:Int):Void {
		_LuaJIT.lua_xmove(state, to, n);
	}

	public static function isNumber(state:LuaState, idx:Int):Bool {
		return _LuaJIT.lua_isnumber(state, idx) == 1;
	}

	public static function isString(state:LuaState, idx:Int):Bool {
		return _LuaJIT.lua_isstring(state, idx) == 1;
	}

	public static function isCFunction(state:LuaState, idx:Int):Bool {
		return _LuaJIT.lua_iscfunction(state, idx) == 1;
	}

	public static function isUserData(state:LuaState, idx:Int):Bool {
		return _LuaJIT.lua_isuserdata(state, idx) == 1;
	}

	public static function type(state:LuaState, idx:Int):LuaType {
		return _LuaJIT.lua_type(state, idx);
	}

	public static function typeName(state:LuaState, idx:Int):String {
		return _LuaJIT.lua_typename(state, idx);
	}

	public static function equal(state:LuaState, idx1:Int, idx2:Int):Int {
		return _LuaJIT.lua_equal(state, idx1, idx2);
	}

	public static function rawEqual(state:LuaState, idx1:Int, idx2:Int):Int {
		return _LuaJIT.lua_rawequal(state, idx1, idx2);
	}

	public static function lessThan(state:LuaState, idx1:Int, idx2:Int):Int {
		return _LuaJIT.lua_lessthan(state, idx1, idx2);
	}

	public static function toNumber(state:LuaState, idx:Int):Float {
		return _LuaJIT.lua_tonumber(state, idx);
	}

	public static function toInteger(state:LuaState, idx:Int):Int {
		return _LuaJIT.lua_tointeger(state, idx);
	}

	public static function toInteger64(state:LuaState, idx:Int):I64 {
		return _LuaJIT.lua_tointeger64(state, idx);
	}

	public static function toBoolean(state:LuaState, idx:Int):Bool {
		return _LuaJIT.lua_toboolean(state, idx) == 1;
	}

	public static function toLString(state:LuaState, idx:Int, l:Int):String {
		return _LuaJIT.lua_tolstring(state, idx, l);
	}

	public static function toString(state:LuaState, idx:Int):String {
		return _LuaJIT.lua_tostring(state, idx);
	}

	public static function toDynamic(state:LuaState, idx:Int):Dynamic {
		return switch (type(state, idx)) {
			case NONE, NIL, LIGHTUSERDATA, TABLE, FUNCTION, THREAD, USERDATA: null;
			case BOOLEAN: toBoolean(state, idx);
			case NUMBER: toNumber(state, idx);
			case STRING: toString(state, idx);
		}
	}

	public static function objLen(state:LuaState, l:Int):Int {
		return _LuaJIT.lua_objlen(state, l);
	}

	public static function toThread(state:LuaState, idx:Int):LuaState {
		return _LuaJIT.lua_tothread(state, idx);
	}

	public static function pushNil(state:LuaState):Void {
		_LuaJIT.lua_pushnil(state);
	}

	public static function pushNumber(state:LuaState, v:Float):Void {
		_LuaJIT.lua_pushnumber(state, v);
	}

	public static function pushInteger(state:LuaState, v:Int):Void {
		_LuaJIT.lua_pushinteger(state, v);
	}

	public static function pushInteger64(state:LuaState, v:I64):Void {
		_LuaJIT.lua_pushinteger64(state, v);
	}

	public static function pushLString(state:LuaState, v:String, l:Int):Void {
		_LuaJIT.lua_pushlstring(state, v, l);
	}

	public static function pushString(state:LuaState, v:String):Void {
		_LuaJIT.lua_pushstring(state, v);
	}

	public static function pushBoolean(state:LuaState, v:Bool):Void {
		_LuaJIT.lua_pushboolean(state, v ? 1 : 0);
	}

	public static function pushThread(state:LuaState):Int {
		return _LuaJIT.lua_pushthread(state);
	}

	public static function pushDynamic(state:LuaState, v:Dynamic):Void {
		switch (Type.typeof(v)) {
			case TNull:
				pushNil(state);
			case TInt:
				pushInteger(state, v);
			case TFloat:
				pushNumber(state, v);
			case TClass(String):
				pushString(state, v);
			case TBool:
				pushBoolean(state, v);
			case t:
				trace('unsupported type $t');
				pushNil(state);
		}
	}

	public static function getTable(state:LuaState, idx:Int):Void {
		_LuaJIT.lua_gettable(state, idx);
	}

	public static function getField(state:LuaState, idx:Int, field:String):Void {
		_LuaJIT.lua_getfield(state, idx, field);
	}

	public static function rawGet(state:LuaState, idx:Int):Void {
		_LuaJIT.lua_rawget(state, idx);
	}

	public static function rawGetI(state:LuaState, idx:Int, n:Int):Void {
		_LuaJIT.lua_rawgeti(state, idx, n);
	}

	public static function createTable(state:LuaState, narr:Int, nrec:Int):Void {
		_LuaJIT.lua_createtable(state, narr, nrec);
	}

	public static function newUserData(state:LuaState, l:Int):Void {
		_LuaJIT.lua_newuserdata(state, l);
	}

	public static function getMetatable(state:LuaState, objindex:Int):Int {
		return _LuaJIT.lua_getmetatable(state, objindex);
	}

	public static function getFEnv(state:LuaState, idx:Int):Void {
		_LuaJIT.lua_getfenv(state, idx);
	}

	public static function setTable(state:LuaState, idx:Int):Void {
		_LuaJIT.lua_settable(state, idx);
	}

	public static function setField(state:LuaState, idx:Int, field:String):Void {
		_LuaJIT.lua_setfield(state, idx, field);
	}

	public static function rawSet(state:LuaState, idx:Int):Void {
		_LuaJIT.lua_rawset(state, idx);
	}

	public static function rawSetI(state:LuaState, idx:Int, n:Int):Void {
		_LuaJIT.lua_rawseti(state, idx, n);
	}

	public static function setMetatable(state:LuaState, objindex:Int):Int {
		return _LuaJIT.lua_setmetatable(state, objindex);
	}

	public static function setFEnv(state:LuaState, idx:Int):Int {
		return _LuaJIT.lua_setfenv(state, idx);
	}

	public static function call(state:LuaState, nargs:Int, nresults:Int):Void {
		_LuaJIT.lua_call(state, nargs, nresults);
	}

	public static function pcall(state:LuaState, nargs:Int, nresults:Int, errfunc:Int):Int {
		return _LuaJIT.lua_pcall(state, nargs, nresults, errfunc);
	}

	public static function dynCall(state:LuaState, args:Array<Dynamic>, ?nresults:Int = 1):Dynamic {
		for (arg in args)
			pushDynamic(state, arg);

		call(state, args.length, nresults);

		final result:Dynamic = if (nresults == 1)
			toDynamic(state, 1);
		else
			[
				for (i in 1...nresults + 1)
					toDynamic(state, i)

			];

		_LuaJIT.lua_pop(state, 1);

		return result;
	}

	public static function lua_pop(state:LuaState, n:Int):Void {
		_LuaJIT.lua_pop(state, n);
	}

	public static function lua_newtable(state:LuaState):Void {
		_LuaJIT.lua_newtable(state);
	}

	public static function getGlobal(state:LuaState, s:String):Void {
		_LuaJIT.lua_getglobal(state, s);
	}

	public static function setGlobal(state:LuaState, s:String):Void {
		_LuaJIT.lua_setglobal(state, s);
	}
}

class LuaL {
	inline public static function newState():LuaState {
		return _LuaJIT.lual_newstate();
	}

	inline public static function openLibs(state:LuaState):Void {
		_LuaJIT.lual_openlibs(state);
	}

	inline public static function loadString(state:LuaState, str:String):Void {
		_LuaJIT.lual_loadstring(state, str);
	}

	inline public static function doString(state:LuaState, str:String):Void {
		_LuaJIT.lual_dostring(state, str);
	}
}

@:access(String)
abstract HlString(hl.Bytes) from hl.Bytes {
	@:from inline static function fromString(s:String):HlString {
		return s.toUtf8();
	}

	@:to inline function toString():String {
		return String.fromUTF8(this);
	}
}

@:hlNative("luajit")
private class _LuaJIT {
	public static function lua_close(state:LuaState):Void {}

	public static function lua_newthread(state:LuaState):LuaState {
		return null;
	}

	public static function lua_gettop(state:LuaState):Int {
		return 0;
	}

	public static function lua_settop(state:LuaState, idx:Int):Void {}

	public static function lua_pushvalue(state:LuaState, idx:Int):Void {}

	public static function lua_remove(state:LuaState, idx:Int):Void {}

	public static function lua_insert(state:LuaState, idx:Int):Void {}

	public static function lua_replace(state:LuaState, idx:Int):Void {}

	public static function lua_checkstack(state:LuaState, sz:Int):Int {
		return 0;
	}

	public static function lua_xmove(state:LuaState, to:LuaState, n:Int):Void {}

	public static function lua_isnumber(state:LuaState, idx:Int):Int {
		return 0;
	}

	public static function lua_isstring(state:LuaState, idx:Int):Int {
		return 0;
	}

	public static function lua_iscfunction(state:LuaState, idx:Int):Int {
		return 0;
	}

	public static function lua_isuserdata(state:LuaState, idx:Int):Int {
		return 0;
	}

	public static function lua_type(state:LuaState, idx:Int):Int {
		return 0;
	}

	public static function lua_typename(state:LuaState, idx:Int):HlString {
		return null;
	}

	public static function lua_equal(state:LuaState, idx1:Int, idx2:Int):Int {
		return 0;
	}

	public static function lua_rawequal(state:LuaState, idx1:Int, idx2:Int):Int {
		return 0;
	}

	public static function lua_lessthan(state:LuaState, idx1:Int, idx2:Int):Int {
		return 0;
	}

	public static function lua_tonumber(state:LuaState, idx:Int):Float {
		return 0.0;
	}

	public static function lua_tointeger(state:LuaState, idx:Int):Int {
		return 0;
	}

	public static function lua_tointeger64(state:LuaState, idx:Int):I64 {
		return 0;
	}

	public static function lua_toboolean(state:LuaState, idx:Int):Int {
		return 0;
	}

	public static function lua_tolstring(state:LuaState, idx:Int, l:Int):HlString {
		return null;
	}

	public static function lua_tostring(state:LuaState, idx:Int):HlString {
		return null;
	}

	public static function lua_objlen(state:LuaState, l:Int):Int {
		return 0;
	}

	public static function lua_tothread(state:LuaState, idx:Int):LuaState {
		return null;
	}

	public static function lua_pushnil(state:LuaState):Void {}

	public static function lua_pushnumber(state:LuaState, v:Float):Void {}

	public static function lua_pushinteger(state:LuaState, v:Int):Void {}

	public static function lua_pushinteger64(state:LuaState, v:I64):Void {}

	public static function lua_pushlstring(state:LuaState, v:HlString, l:Int):Void {}

	public static function lua_pushstring(state:LuaState, v:HlString):Void {}

	public static function lua_pushboolean(state:LuaState, v:Int):Void {}

	public static function lua_pushthread(state:LuaState):Int {
		return 0;
	}

	public static function lua_gettable(state:LuaState, idx:Int):Void {}

	public static function lua_getfield(state:LuaState, idx:Int, field:HlString):Void {}

	public static function lua_rawget(state:LuaState, idx:Int):Void {}

	public static function lua_rawgeti(state:LuaState, idx:Int, n:Int):Void {}

	public static function lua_createtable(state:LuaState, narr:Int, nrec:Int):Void {}

	public static function lua_newuserdata(state:LuaState, l:Int):Void {}

	public static function lua_getmetatable(state:LuaState, objindex:Int):Int {
		return 0;
	}

	public static function lua_getfenv(state:LuaState, idx:Int):Void {}

	public static function lua_settable(state:LuaState, idx:Int):Void {}

	public static function lua_setfield(state:LuaState, idx:Int, field:HlString):Void {}

	public static function lua_rawset(state:LuaState, idx:Int):Void {}

	public static function lua_rawseti(state:LuaState, idx:Int, n:Int):Void {}

	public static function lua_setmetatable(state:LuaState, objindex:Int):Int {
		return 0;
	}

	public static function lua_setfenv(state:LuaState, idx:Int):Int {
		return 0;
	}

	public static function lua_call(state:LuaState, nargs:Int, nresults:Int):Void {}

	public static function lua_pcall(state:LuaState, nargs:Int, nresults:Int, errfunc:Int):Int {
		return 0;
	}

	public static function lua_pop(state:LuaState, n:Int):Void {}

	public static function lua_newtable(state:LuaState):Void {}

	public static function lua_setglobal(state:LuaState, str:HlString):Void {}

	public static function lua_getglobal(state:LuaState, str:HlString):Void {}

	public static function lual_newstate():LuaState {
		return null;
	}

	public static function lual_openlibs(state:LuaState):Void {}

	public static function lual_loadstring(state:LuaState, str:HlString):Void {}

	public static function lual_dostring(state:LuaState, str:HlString):Void {}

	public static function add_callback(state:LuaState, s:HlString):Void {}

	public static function set_callback_function(func:hl.Bytes->Void):Void {}

	public static function __getState():LuaState {
		return null;
	}
}

typedef LuaState = hl.Abstract<"lua_State">;

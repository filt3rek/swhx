/*
 * Copyright (c) 2007, Edwin van Rijkom, Nicolas Cannasse
 * All rights reserved.
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE HAXE PROJECT CONTRIBUTORS "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE HAXE PROJECT CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */
package swhx;

/**
An SWHX application consists of one or more windows.
By instantiating a Window class, a new application window gets created.
Use the available meth
**/
class MessageHook {

	var h 	: Dynamic;
	var id1	: Dynamic; 
	var id2 : Dynamic;
	
	public var p1(get_p1,null) : Dynamic;
	public var p2(get_p2,null) : Dynamic;
	public var callbackData(get_callbackData,set_callbackData) : Dynamic;
	
	public function new( hook : Dynamic, msgid1 : Dynamic, msgid2 : Dynamic ) {		
		h = hook;
		id1 = msgid1;
		id2 = if (msgid2!=null) msgid2 else untyped 0;
	}
	
	public function setCCallback( f: Dynamic ) {
		_msghook_set_c_cb(h,f);
	}
	
	public function setNekoCallback( f: Dynamic ) {
		_msghook_set_n_cb(h,f);
	}
	
	function get_p1() {
		return _msghook_get_param1(h);
	}
	
	function get_p2() {
		return _msghook_get_param2(h);
	}
	
	function get_callbackData() {
		return _msghook_get_c_data(h);
	}
	
	function set_callbackData( d : Dynamic ) {
		_msghook_set_c_data(h, d);
		return d;
	}
		
	static var _msghook_set_c_cb = neko.Lib.load("swhx", "msghook_set_c_callback", 2);
	static var _msghook_set_n_cb = neko.Lib.load("swhx", "msghook_set_n_callback", 2);
	static var _msghook_get_param1 = neko.Lib.load("swhx", "msghook_get_param1", 1);
	static var _msghook_get_param2 = neko.Lib.load("swhx", "msghook_get_param2", 1);
	static var _msghook_get_c_data = neko.Lib.load("swhx", "msghook_get_cdata", 1);
	static var _msghook_set_c_data = neko.Lib.load("swhx", "msghook_set_cdata", 2);	
}	
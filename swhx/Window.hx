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
class Window {

	var w : Dynamic;

	/**Get/Set allowing operating system default chrome window resizing.**/
	public var resizable(get_resizable,set_resizable) : Bool;

	/**Get/Set operating system default chrome maximize button presence/enablement.**/
	public var maximizeIcon(get_maximizeIcon,set_maximizeIcon) : Bool;

	/**Get/Set operating system default chrome minimize button presence/enablement.**/
	public var minimizeIcon(get_minimizeIcon,set_minimizeIcon) : Bool;

	/**Get/Set the width of the window's client area.**/
	public var width(get_width,set_width) : Int;

	/**Get/Set the height of the window's client area.**/
	public var height(get_height,set_height) : Int;

	/**Get/Set the window's vertical position on the desktop.**/
	public var left(get_left,set_left) : Int;

	/**Get/Set the window's horizontal position on the desktop.**/
	public var top(get_top,set_top) : Int;

	public var handle(get_handle,null) : Dynamic;

	/**
	Get/Set window full-screen mode.
	On OS-X, full-screen mode will disable the menu bar, task-switching and force quit.
	**/
	public var fullscreen(get_fullscreen,set_fullscreen) : Bool;

	/**Not implemented.**/
	public var transparent(get_transparent,null) : Bool;

	/**''true'' if the window contains a running Flash instance.**/
	public var flashRunning(get_flashRunning,null) : Bool;

	/**Get/Set window file-drop acceptance.**/
	public var dropTarget(get_dropTarget,set_dropTarget) : Bool;

	/**Get/Set window title.**/
	public var title(default,set_title) : String;

	/**''true'' if the window was created with the WF_PLAIN flag set.**/
	public var plain(get_plain,null) : Bool;

	/**Get/Set window minimized state.**/
	public var minimized(get_minimized,set_minimized) : Bool;

	/**Get/Set window maximized state.**/
	public var maximized(get_maximized,set_maximized) : Bool;

	/**Get/Set window visibility.**/
	public var visible(default,set_visible) : Bool;

	public static var WF_FULLSCREEN	= 1;
	public static var WF_TRANSPARENT	= 1 << 1;
	public static var WF_DROPTARGET	= 1 << 3;
	public static var WF_PLAIN			= 1 << 4;
	public static var WF_ALWAYS_ONTOP	= 1 << 5;
	public static var WF_NO_TASKBAR	= 1 << 6;

	public function new( title : String, width : Int, height : Int, ?flags : Int ) {
		this.title = title;
		if (flags == null) flags = 0;
		visible = false;
		w = _window_create(untyped title.__s,width,height,flags);
		// late binding of events
		var me = this;
		_window_on_destroy(w,function() { me.onDestroy(); });
		_window_on_close(w,function() { return me.onClose(); });
		_window_on_minimize(w,function() { return me.onMinimize(); });
		_window_on_maximize(w,function() { return me.onMaximize(); });
		_window_on_rightclick(w,function() { return me.onRightClick(); });
		_window_on_filesdropped(w,function(s) {
				var a : Array<String> = untyped Array.new1(s,__dollar__asize(s));
				for( i in 0...a.length ) a[i] = new String(a[i]);
				return me.onFilesDropped(a);
			});
		_window_on_restore(w,function() { return me.onRestore(); });
	}

	/** Show or hide the window [DEPRECATED] uses .visible instead **/
	public function show( b : Bool ) {
		visible = b;
	}

	/**Close the window.**/
	public function close() {
		if( onClose() )
			destroy();
	}

	/**Destroy the window.**/
	public function destroy() {
		neko.vm.Ui.sync(_window_destroy.bind(w));
	}

	public function addMessageHook(msgid1: Dynamic, ?msgid2: Dynamic) {
		return new MessageHook
			(	_window_add_message_hook(w,msgid1,if (msgid2!=null) msgid2 else untyped 0)
			,	msgid1
			,	if (msgid2!=null) msgid2 else untyped 0
			);
	}

	public function removeMessageHook(h: MessageHook) {
		_window_remove_message_hook(w,h);
	}

	/**
	<p>
	Initiate user window resizing.
	<p>
	Specify either "L","R","T","TL","TR","B","BL" or "BR" to set the resize direction.
	Windows on OSX ignore this argument and always resizes from the bottom-right ("BR") corner of the window.
	**/
	public function resize(?direction: String) {
		var i;
		switch (direction) {
			case "L": i=1;
			case "R": i=2;
			case "T": i=3;
			case "TL": i=4;
			case "TR": i=5;
			case "B": i=6;
			case "BL": i=7;
			case "BR": i=8;
			default: i=8;
		}
		_window_resize(w,i);
	}

	/**Initiate user window dragging.**/
	public function drag() {
		return _window_drag(w);
	}

	/**Event invoked on window destruction.**/
	public dynamic function onDestroy() {
		Application.exitLoop();
	}

	/**Event invoked on window closure. Returning ''false'' from the event handler will cancel window closure.**/
	public dynamic function onClose() {
		return true;
	}

	/**
	Event invoked when the window is minimized from the operating system window chrome.
	Returning ''false'' will cancel this action.
	**/
	public dynamic function onMinimize() {
		return true;
	}

	/**
	Event invoked when the window is maximized from the operating system window chrome.
	Returning ''false'' will cancel this action.
	**/
	public dynamic function onMaximize() {
		return true;
	}

	/**
	Event invoked when the user right-clicks in the window's client area.
	Returning ''false'' from the event handler will prevent the event being forwarded to the Flash player.
	**/
	public dynamic function onRightClick() {
		return true;
	}

	/**Event invoked when the user drops files on the window's client area while Window.dropTarget is enabled.**/
	public dynamic function onFilesDropped( files : Array<String> ) {
		return true;
	}

	/**
	Event invoked when the window is restored by the user.
	Returning ''false'' will cancel this action.
	**/
	public dynamic function onRestore() {
		return true;
	}

	function get_resizable() {
		return _window_get_prop(w,0) != 0;
	}

	function set_resizable( b ) {
		_window_set_prop(w,0,if( b ) 1 else 0);
		return b;
	}

	function get_maximizeIcon() {
		return _window_get_prop(w,1) != 0;
	}

	function set_maximizeIcon(b) {
		_window_set_prop(w,1,if( b ) 1 else 0);
		return b;
	}

	function get_minimizeIcon() {
		return _window_get_prop(w,2) != 0;
	}

	function set_minimizeIcon(b) {
		_window_set_prop(w,2,if( b ) 1 else 0);
		return b;
	}

	function get_width() {
		return _window_get_prop(w,3);
	}

	function get_height() {
		return _window_get_prop(w,4);
	}

	function get_left() {
		return _window_get_prop(w,5);
	}

	function get_top() {
		return _window_get_prop(w,6);
	}

	function set_width(i) {
		_window_set_prop(w,3,i);
		return i;
	}

	function set_height(i) {
		_window_set_prop(w,4,i);
		return i;
	}

	function set_left(i) {
		_window_set_prop(w,5,i);
		return i;
	}

	function set_top(i) {
		_window_set_prop(w,6,i);
		return i;
	}

	function get_fullscreen() {
		return _window_get_prop(w,7) != 0;
	}

	function set_fullscreen( b ) {
		_window_set_prop(w,7,if( b ) 1 else 0);
		return b;
	}

	function get_transparent() {
		return _window_get_prop(w,8) != 0;
	}


	function get_flashRunning() {
		return _window_get_prop(w,9) != 0;
	}

	function get_dropTarget() {
		return _window_get_prop(w,10) != 0;
	}

	function set_dropTarget( b ) {
		_window_set_prop(w,10,if( b ) 1 else 0);
		return b;
	}

	function set_title(t: String) : String {
		title = t;
		// set_title is called when initializing
		if( w != null ) _window_set_title(w,untyped t.__s);
		return t;
	}

	function get_plain() {
		return _window_get_prop(w,11) != 0;
	}

	function get_minimized() {
		return _window_get_prop(w,12) != 0;
	}

	function set_minimized( b ) {
		_window_set_prop(w,12,if( b ) 1 else 0);
		return b;
	}

	function get_maximized() {
		return _window_get_prop(w,13) != 0;
	}

	function set_maximized( b ) {
		_window_set_prop(w,13,if( b ) 1 else 0);
		return b;
	}

	function get_handle() {
		return _window_get_handle(w);
	}

	function set_visible(b) {
		if( w != null )
			_window_show(w,b);
		visible = b;
		return b;
	}

	static var _window_create = neko.Lib.load("swhx","window_create",4);
	static var _window_show = neko.Lib.load("swhx","window_show",2);
	static var _window_destroy : Dynamic -> Void = neko.Lib.load("swhx","window_destroy",1);
	static var _window_set_prop = neko.Lib.load("swhx","window_set_prop",3);
	static var _window_get_prop = neko.Lib.load("swhx","window_get_prop",2);
	static var _window_set_title = neko.Lib.load("swhx","window_set_title",2);
	static var _window_drag = neko.Lib.load("swhx","window_drag",1);
	static var _window_resize = neko.Lib.load("swhx","window_resize",2);
	static var _window_get_handle = neko.Lib.load("swhx", "window_get_handle", 1);
	static var _window_add_message_hook = neko.Lib.load("swhx", "window_add_message_hook", 3);
	static var _window_remove_message_hook = neko.Lib.load("swhx", "window_remove_message_hook", 2);

	static var _window_on_destroy = neko.Lib.load("swhx","window_on_destroy",2);
	static var _window_on_close = neko.Lib.load("swhx","window_on_close",2);
	static var _window_on_rightclick = neko.Lib.load("swhx","window_on_rightclick",2);
	static var _window_on_restore = neko.Lib.load("swhx","window_on_restore",2);
	static var _window_on_filesdropped = neko.Lib.load("swhx","window_on_filesdropped",2);
	static var _window_on_minimize = neko.Lib.load("swhx","window_on_minimize",2);
	static var _window_on_maximize = neko.Lib.load("swhx","window_on_maximize",2);
}

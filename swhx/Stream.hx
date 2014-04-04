/*
 * Copyright (c) 2006, Edwin van Rijkom, Nicolas Cannasse
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
	The abstract SWHX stream.
**/
enum StreamHandle {
}

/**
	A stream is bound to the Flash Player in order to deliver asynchronous data such
	as file downloads.
**/
class Stream extends haxe.io.Output {

	var s : StreamHandle;

	public function new(s) {
		this.s = s;
	}

	public override function writeByte(c : Int) {
		neko.vm.Ui.syncResult(stream_char.bind(s,c));
	}

	public override function writeBytes(buf : haxe.io.Bytes,pos : Int,len : Int) : Int {
		return neko.vm.Ui.syncResult(stream_bytes.bind(s,buf.getData(),pos,len));
	}

	public override function prepare( size : Int ) {
		neko.vm.Ui.syncResult(stream_size.bind(s,size));
	}

	public function reportError() {
		neko.vm.Ui.syncResult(stream_close.bind(s,false));
	}

	public override function close() {
		neko.vm.Ui.syncResult(stream_close.bind(s,true));
	}

	static var stream_size : StreamHandle -> Int -> Void = neko.Lib.load("swhx","stream_size",2);
	static var stream_char : StreamHandle -> Int -> Void = neko.Lib.load("swhx","stream_char",2);
	static var stream_bytes : StreamHandle -> Dynamic -> Int -> Int -> Int = neko.Lib.load("swhx","stream_bytes",4);
	static var stream_close : StreamHandle -> Bool -> Void = neko.Lib.load("swhx","stream_close",2);

}

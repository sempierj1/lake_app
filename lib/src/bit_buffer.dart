/*Copyright 2014, the Dart QR project authors. All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.
    * Neither the name of Google Inc. nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.*/

import 'dart:collection';

class QrBitBuffer extends Object with ListMixin<bool> {
  final List<int> _buffer;
  int _length = 0;

  QrBitBuffer() : _buffer = new List<int>();

  @override
  void operator []=(int index, bool value) =>
      throw new UnsupportedError('cannot change');

  @override
  bool operator [](int index) {
    final bufIndex = index ~/ 8;
    return ((_buffer[bufIndex] >> (7 - index % 8)) & 1) == 1;
  }

  @override
  int get length => _length;

  @override
  set length(int value) => throw new UnsupportedError('Cannot change');

  int getByte(int index) => _buffer[index];

  void put(int number, int length) {
    for (var i = 0; i < length; i++) {
      final bit = ((number >> (length - i - 1)) & 1) == 1;
      putBit(bit);
    }
  }

  void putBit(bool bit) {
    var bufIndex = _length ~/ 8;
    if (_buffer.length <= bufIndex) {
      _buffer.add(0);
    }

    if (bit) {
      _buffer[bufIndex] |= (0x80 >> (_length % 8));
    }

    _length++;
  }
}

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

import 'dart:typed_data';

final Uint8List _logTable = _createLogTable();
final Uint8List _expTable = _createExpTable();

Uint8List getByteList(int count) => new Uint8List(count);

int glog(int n) {
  if (n < 1) {
    throw 'glog($n)';
  }

  return _logTable[n];
}

int gexp(int n) {
  while (n < 0) {
    n += 255;
  }

  while (n >= 256) {
    n -= 255;
  }

  return _expTable[n];
}

Uint8List _createExpTable() {
  var list = getByteList(256);
  for (int i = 0; i < 8; i++) {
    list[i] = 1 << i;
  }
  for (int i = 8; i < 256; i++) {
    list[i] = list[i - 4] ^ list[i - 5] ^ list[i - 6] ^ list[i - 8];
  }
  return list;
}

Uint8List _createLogTable() {
  var list = getByteList(256);
  for (int i = 0; i < 255; i++) {
    list[_expTable[i]] = i;
  }
  return list;
}

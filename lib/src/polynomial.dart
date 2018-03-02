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

import 'math.dart' as qr_math;

class QrPolynomial {
  final Uint8List _myThings;

  factory QrPolynomial(List<int> thing, int shift) {
    var offset = 0;

    while (offset < thing.length && thing[offset] == 0) {
      offset++;
    }

    final List<int> values = qr_math.getByteList(thing.length - offset + shift);

    for (var i = 0; i < thing.length - offset; i++) {
      values[i] = thing[i + offset];
    }

    return new QrPolynomial._internal(values);
  }

  QrPolynomial._internal(this._myThings);

  int operator [](int index) => _myThings[index];

  int get length => _myThings.length;

  QrPolynomial multiply(QrPolynomial e) {
    final List<int> foo = qr_math.getByteList(length + e.length - 1);

    for (var i = 0; i < length; i++) {
      for (var j = 0; j < e.length; j++) {
        foo[i + j] ^= qr_math.gexp(qr_math.glog(this[i]) + qr_math.glog(e[j]));
      }
    }

    return new QrPolynomial(foo, 0);
  }

  QrPolynomial mod(QrPolynomial e) {
    if (length - e.length < 0) {
      return this;
    }

    var ratio = qr_math.glog(this[0]) - qr_math.glog(e[0]);

    var thing = qr_math.getByteList(length);

    for (int i = 0; i < length; i++) {
      thing[i] = this[i];
    }

    for (int i = 0; i < e.length; i++) {
      thing[i] ^= qr_math.gexp(qr_math.glog(e[i]) + ratio);
    }

    // recursive call
    return (new QrPolynomial(thing, 0)).mod(e);
  }
}

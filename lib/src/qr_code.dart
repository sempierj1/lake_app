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

import 'dart:math' as math;

import 'package:bot/bot.dart';

import 'bit_buffer.dart';
import 'byte.dart';
import 'error_correct_level.dart';
import 'input_too_long_exception.dart';
import 'math.dart' as qr_math;
import 'polynomial.dart';
import 'rs_block.dart';
import 'util.dart' as qr_util;

class QrCode {
  final int typeNumber;
  final int errorCorrectLevel;
  final int moduleCount;
  final List<List> _modules;
  List<int> _dataCache;
  final List<QrByte> _dataList = new List<QrByte>();

  QrCode(int typeNumber, this.errorCorrectLevel)
      : this.typeNumber = typeNumber,
        moduleCount = typeNumber * 4 + 17,
        _modules = new List<List<bool>>() {
    requireArgument(typeNumber > 0 && typeNumber < 41, 'typeNumber');
    requireArgument(QrErrorCorrectLevel.levels.indexOf(errorCorrectLevel) >= 0,
        'errorCorrectLevel');

    for (var row = 0; row < moduleCount; row++) {
      _modules.add(new List<bool>(moduleCount));
    }
  }

  bool isDark(int row, int col) {
    if (row < 0 || moduleCount <= row || col < 0 || moduleCount <= col) {
      throw '$row , $col';
    }
    return _modules[row][col];
  }

  void addData(String data) {
    var newData = new QrByte(data);
    _dataList.add(newData);
    _dataCache = null;
  }

  void make() {
    _makeImpl(false, _getBestMaskPattern());
  }

  void _setupPositionProbePattern(int row, int col) {
    for (var r = -1; r <= 7; r++) {
      if (row + r <= -1 || moduleCount <= row + r) continue;

      for (var c = -1; c <= 7; c++) {
        if (col + c <= -1 || moduleCount <= col + c) continue;

        if ((0 <= r && r <= 6 && (c == 0 || c == 6)) ||
            (0 <= c && c <= 6 && (r == 0 || r == 6)) ||
            (2 <= r && r <= 4 && 2 <= c && c <= 4)) {
          _modules[row + r][col + c] = true;
        } else {
          _modules[row + r][col + c] = false;
        }
      }
    }
  }

  int _getBestMaskPattern() {
    var minLostPoint = 0;
    var pattern = 0;

    for (var i = 0; i < 8; i++) {
      _makeImpl(true, i);

      var lostPoint = qr_util.getLostPoint(this);

      if (i == 0 || minLostPoint > lostPoint) {
        minLostPoint = lostPoint;
        pattern = i;
      }
    }

    return pattern;
  }

  void _setupTimingPattern() {
    for (var r = 8; r < moduleCount - 8; r++) {
      if (_modules[r][6] != null) {
        continue;
      }
      _modules[r][6] = (r % 2 == 0);
    }

    for (var c = 8; c < moduleCount - 8; c++) {
      if (_modules[6][c] != null) {
        continue;
      }
      _modules[6][c] = (c % 2 == 0);
    }
  }

  void _setupPositionAdjustPattern() {
    var pos = qr_util.getPatternPosition(typeNumber);

    for (var i = 0; i < pos.length; i++) {
      for (var j = 0; j < pos.length; j++) {
        var row = pos[i];
        var col = pos[j];

        if (_modules[row][col] != null) {
          continue;
        }

        for (var r = -2; r <= 2; r++) {
          for (var c = -2; c <= 2; c++) {
            if (r == -2 || r == 2 || c == -2 || c == 2 || (r == 0 && c == 0)) {
              _modules[row + r][col + c] = true;
            } else {
              _modules[row + r][col + c] = false;
            }
          }
        }
      }
    }
  }

  void _setupTypeNumber(bool test) {
    var bits = qr_util.getBCHTypeNumber(this.typeNumber);

    for (int i = 0; i < 18; i++) {
      final bool mod = (!test && ((bits >> i) & 1) == 1);
      _modules[i ~/ 3][i % 3 + moduleCount - 8 - 3] = mod;
    }

    for (int i = 0; i < 18; i++) {
      final bool mod = (!test && ((bits >> i) & 1) == 1);
      _modules[i % 3 + moduleCount - 8 - 3][i ~/ 3] = mod;
    }
  }

  void _setupTypeInfo(bool test, maskPattern) {
    var data = (this.errorCorrectLevel << 3) | maskPattern;
    var bits = qr_util.getBCHTypeInfo(data);

    var i, mod;

    // vertical
    for (i = 0; i < 15; i++) {
      mod = (!test && ((bits >> i) & 1) == 1);

      if (i < 6) {
        _modules[i][8] = mod;
      } else if (i < 8) {
        _modules[i + 1][8] = mod;
      } else {
        _modules[moduleCount - 15 + i][8] = mod;
      }
    }

    // horizontal
    for (i = 0; i < 15; i++) {
      mod = (!test && ((bits >> i) & 1) == 1);

      if (i < 8) {
        _modules[8][moduleCount - i - 1] = mod;
      } else if (i < 9) {
        _modules[8][15 - i - 1 + 1] = mod;
      } else {
        _modules[8][15 - i - 1] = mod;
      }
    }

    // fixed module
    _modules[moduleCount - 8][8] = (!test);
  }

  void _mapData(List<int> data, maskPattern) {
    var inc = -1;
    var row = moduleCount - 1;
    var bitIndex = 7;
    var byteIndex = 0;

    for (var col = moduleCount - 1; col > 0; col -= 2) {
      if (col == 6) col--;

      while (true) {
        for (var c = 0; c < 2; c++) {
          if (_modules[row][col - c] == null) {
            var dark = false;

            if (byteIndex < data.length) {
              dark = (((data[byteIndex] >> bitIndex) & 1) == 1);
            }

            var mask = qr_util.getMask(maskPattern, row, col - c);

            if (mask) {
              dark = !dark;
            }

            _modules[row][col - c] = dark;
            bitIndex--;

            if (bitIndex == -1) {
              byteIndex++;
              bitIndex = 7;
            }
          }
        }

        row += inc;

        if (row < 0 || moduleCount <= row) {
          row -= inc;
          inc = -inc;
          break;
        }
      }
    }
  }

  void _makeImpl(bool test, int maskPattern) {
    _setupPositionProbePattern(0, 0);
    _setupPositionProbePattern(moduleCount - 7, 0);
    _setupPositionProbePattern(0, moduleCount - 7);
    _setupPositionAdjustPattern();
    _setupTimingPattern();
    _setupTypeInfo(test, maskPattern);

    if (typeNumber >= 7) {
      _setupTypeNumber(test);
    }

    if (_dataCache == null) {
      _dataCache = _createData(typeNumber, errorCorrectLevel, _dataList);
    }

    _mapData(_dataCache, maskPattern);
  }
}

const int _pad0 = 0xEC;
const int _pad1 = 0x11;

List<int> _createData(
    int typeNumber, int errorCorrectLevel, List<QrByte> dataList) {
  var rsBlocks = QrRsBlock.getRSBlocks(typeNumber, errorCorrectLevel);

  final buffer = new QrBitBuffer();

  for (int i = 0; i < dataList.length; i++) {
    var data = dataList[i];
    buffer.put(data.mode, 4);
    buffer.put(data.length, qr_util.getLengthInBits(data.mode, typeNumber));
    data.write(buffer);
  }

  // HUH?
  // ç≈ëÂÉfÅ[É^êîÇåvéZ
  var totalDataCount = 0;
  for (int i = 0; i < rsBlocks.length; i++) {
    totalDataCount += rsBlocks[i].dataCount;
  }

  final totalByteCount = totalDataCount * 8;
  if (buffer.length > totalByteCount) {
    throw new InputTooLongException(buffer.length, totalByteCount);
  }

  // HUH?
  // èIí[ÉRÅ[Éh
  if (buffer.length + 4 <= totalByteCount) {
    buffer.put(0, 4);
  }

  // padding
  while (buffer.length % 8 != 0) {
    buffer.putBit(false);
  }

  // padding
  while (true) {
    if (buffer.length >= totalDataCount * 8) {
      break;
    }
    buffer.put(_pad0, 8);

    if (buffer.length >= totalDataCount * 8) {
      break;
    }
    buffer.put(_pad1, 8);
  }

  return _createBytes(buffer, rsBlocks);
}

List<int> _createBytes(QrBitBuffer buffer, rsBlocks) {
  var offset = 0;

  var maxDcCount = 0;
  var maxEcCount = 0;

  var dcdata = new List<List<int>>(rsBlocks.length);
  var ecdata = new List<List>(rsBlocks.length);

  for (int r = 0; r < rsBlocks.length; r++) {
    var dcCount = rsBlocks[r].dataCount;
    var ecCount = rsBlocks[r].totalCount - dcCount;

    maxDcCount = math.max(maxDcCount, dcCount);
    maxEcCount = math.max(maxEcCount, ecCount);

    dcdata[r] = qr_math.getByteList(dcCount);

    for (int i = 0; i < dcdata[r].length; i++) {
      dcdata[r][i] = 0xff & buffer.getByte(i + offset);
    }
    offset += dcCount;

    var rsPoly = qr_util.getErrorCorrectPolynomial(ecCount);
    var rawPoly = new QrPolynomial(dcdata[r], rsPoly.length - 1);

    var modPoly = rawPoly.mod(rsPoly);
    ecdata[r] = qr_math.getByteList(rsPoly.length - 1);

    for (int i = 0; i < ecdata[r].length; i++) {
      var modIndex = i + modPoly.length - ecdata[r].length;
      ecdata[r][i] = (modIndex >= 0) ? modPoly[modIndex] : 0;
    }
  }

  var data = <int>[];

  for (int i = 0; i < maxDcCount; i++) {
    for (int r = 0; r < rsBlocks.length; r++) {
      if (i < dcdata[r].length) {
        data.add(dcdata[r][i]);
      }
    }
  }

  for (int i = 0; i < maxEcCount; i++) {
    for (int r = 0; r < rsBlocks.length; r++) {
      if (i < ecdata[r].length) {
        data.add(ecdata[r][i]);
      }
    }
  }

  return data;
}
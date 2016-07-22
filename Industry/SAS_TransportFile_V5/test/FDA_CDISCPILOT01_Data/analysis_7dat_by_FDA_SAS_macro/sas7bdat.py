#!/usr/bin/env python
"""
This module will read sas7bdat files using pure Python (2.7+, 3+).
No SAS software required!
"""
from __future__ import division, absolute_import, print_function,\
    unicode_literals
import atexit
import csv
import logging
import math
import os
import platform
import struct
import sys
from datetime import datetime, timedelta

import six
xrange = six.moves.range

__all__ = ['SAS7BDAT']


def _debug(t, v, tb):
    if hasattr(sys, 'ps1') or not sys.stderr.isatty():
        sys.__excepthook__(t, v, tb)
    else:
        import pdb
        import traceback
        traceback.print_exception(t, v, tb)
        print()
        pdb.pm()
        os._exit(1)


def _get_color_emit(prefix, fn):
    # This doesn't work on Windows since Windows doesn't support
    # the ansi escape characters
    def _new(handler):
        levelno = handler.levelno
        if levelno >= logging.CRITICAL:
            color = '\x1b[31m'  # red
        elif levelno >= logging.ERROR:
            color = '\x1b[31m'  # red
        elif levelno >= logging.WARNING:
            color = '\x1b[33m'  # yellow
        elif levelno >= logging.INFO:
            color = '\x1b[32m'  # green or normal
        elif levelno >= logging.DEBUG:
            color = '\x1b[35m'  # pink
        else:
            color = '\x1b[0m'   # normal
        try:
            handler.msg = '%s[%s] %s%s' % (
                color, prefix, handler.msg, '\x1b[0m'
            )
        except UnicodeDecodeError:
            handler.msg = '%s[%s] %s%s' % (
                color, prefix, handler.msg.decode('utf-8'), '\x1b[0m'
            )
        return fn(handler)
    return _new


class ParseError(Exception):
    pass


class Decompressor(object):
    def __init__(self, parent):
        self.parent = parent

    def decompress_row(self, offset, length, result_length, page):
        raise NotImplementedError

    @staticmethod
    def to_ord(int_or_str):
        if isinstance(int_or_str, int):
            return int_or_str
        return ord(int_or_str)

    @staticmethod
    def to_chr(int_or_str):
        py2 = six.PY2
        if isinstance(int_or_str, (bytes, bytearray)):
            return int_or_str
        if py2:
            return chr(int_or_str)
        return bytes([int_or_str])


class RLEDecompressor(Decompressor):
    """
    Decompresses data using the Run Length Encoding algorithm
    """
    def decompress_row(self, offset, length, result_length, page):
        b = self.to_ord
        c = self.to_chr
        current_result_array_index = 0
        result = []
        i = 0
        for j in xrange(length):
            if i != j:
                continue
            control_byte = b(page[offset + i]) & 0xF0
            end_of_first_byte = b(page[offset + i]) & 0x0F
            if control_byte == 0x00:
                if i != (length - 1):
                    count_of_bytes_to_copy = (
                        (b(page[offset + i + 1]) & 0xFF) +
                        64 +
                        end_of_first_byte * 256
                    )
                    start = offset + i + 2
                    end = start + count_of_bytes_to_copy
                    result.append(c(page[start:end]))
                    i += count_of_bytes_to_copy + 1
                    current_result_array_index += count_of_bytes_to_copy
            elif control_byte == 0x40:
                copy_counter = (
                    end_of_first_byte * 16 +
                    (b(page[offset + i + 1]) & 0xFF)
                )
                for _ in xrange(copy_counter + 18):
                    result.append(c(page[offset + i + 2]))
                    current_result_array_index += 1
                i += 2
            elif control_byte == 0x60:
                for _ in xrange(end_of_first_byte * 256 +
                                (b(page[offset + i + 1]) & 0xFF) + 17):
                    result.append(c(0x20))
                    current_result_array_index += 1
                i += 1
            elif control_byte == 0x70:
                for _ in xrange((b(page[offset + i + 1]) & 0xFF) + 17):
                    result.append(c(0x00))
                    current_result_array_index += 1
                i += 1
            elif control_byte == 0x80:
                count_of_bytes_to_copy = min(end_of_first_byte + 1,
                                             length - (i + 1))
                start = offset + i + 1
                end = start + count_of_bytes_to_copy
                result.append(c(page[start:end]))
                i += count_of_bytes_to_copy
                current_result_array_index += count_of_bytes_to_copy
            elif control_byte == 0x90:
                count_of_bytes_to_copy = min(end_of_first_byte + 17,
                                             length - (i + 1))
                start = offset + i + 1
                end = start + count_of_bytes_to_copy
                result.append(c(page[start:end]))
                i += count_of_bytes_to_copy
                current_result_array_index += count_of_bytes_to_copy
            elif control_byte == 0xA0:
                count_of_bytes_to_copy = min(end_of_first_byte + 33,
                                             length - (i + 1))
                start = offset + i + 1
                end = start + count_of_bytes_to_copy
                result.append(c(page[start:end]))
                i += count_of_bytes_to_copy
                current_result_array_index += count_of_bytes_to_copy
            elif control_byte == 0xB0:
                count_of_bytes_to_copy = min(end_of_first_byte + 49,
                                             length - (i + 1))
                start = offset + i + 1
                end = start + count_of_bytes_to_copy
                result.append(c(page[start:end]))
                i += count_of_bytes_to_copy
                current_result_array_index += count_of_bytes_to_copy
            elif control_byte == 0xC0:
                for _ in xrange(end_of_first_byte + 3):
                    result.append(c(page[offset + i + 1]))
                    current_result_array_index += 1
                i += 1
            elif control_byte == 0xD0:
                for _ in xrange(end_of_first_byte + 2):
                    result.append(c(0x40))
                    current_result_array_index += 1
            elif control_byte == 0xE0:
                for _ in xrange(end_of_first_byte + 2):
                    result.append(c(0x20))
                    current_result_array_index += 1
            elif control_byte == 0xF0:
                for _ in xrange(end_of_first_byte + 2):
                    result.append(c(0x00))
                    current_result_array_index += 1
            else:
                self.parent.logger.error('unknown control byte: %s',
                                         control_byte)
            i += 1
        return b''.join(result)


class RDCDecompressor(Decompressor):
    """
    Decompresses data using the Ross Data Compression algorithm
    """
    def bytes_to_bits(self, src, offset, length):
        result = [0] * (length * 8)
        for i in xrange(length):
            b = src[offset + i]
            for bit in xrange(8):
                result[8 * i + (7 - bit)] = 0 if ((b & (1 << bit)) == 0) else 1
        return result

    def ensure_capacity(self, src, capacity):
        if capacity >= len(src):
            new_len = max(capacity, 2 * len(src))
            src.extend([0] * (new_len - len(src)))
        return src

    def is_short_rle(self, first_byte_of_cb):
        return first_byte_of_cb in set([0x00, 0x01, 0x02, 0x03, 0x04, 0x05])

    def is_single_byte_marker(self, first_byte_of_cb):
        return first_byte_of_cb in set([0x02, 0x04, 0x06, 0x08, 0x0A])

    def is_two_bytes_marker(self, double_bytes_cb):
        return len(double_bytes_cb) == 2 and\
            ((double_bytes_cb[0] >> 4) & 0xF) > 2

    def is_three_bytes_marker(self, three_byte_marker):
        flag = three_byte_marker[0] >> 4
        return len(three_byte_marker) == 3 and (flag & 0xF) in set([1, 2])

    def get_length_of_rle_pattern(self, first_byte_of_cb):
        if first_byte_of_cb <= 0x05:
            return first_byte_of_cb + 3
        return 0

    def get_length_of_one_byte_pattern(self, first_byte_of_cb):
        return first_byte_of_cb + 14\
            if self.is_single_byte_marker(first_byte_of_cb) else 0

    def get_length_of_two_bytes_pattern(self, double_bytes_cb):
        return (double_bytes_cb[0] >> 4) & 0xF

    def get_length_of_three_bytes_pattern(self, p_type, three_byte_marker):
        if p_type == 1:
            return 19 + (three_byte_marker[0] & 0xF) +\
                (three_byte_marker[1] * 16)
        elif p_type == 2:
            return three_byte_marker[2] + 16
        return 0

    def get_offset_for_one_byte_pattern(self, first_byte_of_cb):
        if first_byte_of_cb == 0x08:
            return 24
        elif first_byte_of_cb == 0x0A:
            return 40
        return 0

    def get_offset_for_two_bytes_pattern(self, double_bytes_cb):
        return 3 + (double_bytes_cb[0] & 0xF) + (double_bytes_cb[1] * 16)

    def get_offset_for_three_bytes_pattern(self, triple_bytes_cb):
        return 3 + (triple_bytes_cb[0] & 0xF) + (triple_bytes_cb[1] * 16)

    def clone_byte(self, b, length):
        return [b] * length

    def decompress_row(self, offset, length, result_length, page):
        b = self.to_ord
        c = self.to_chr
        src_row = [b(x) for x in page[offset:offset + length]]
        out_row = [0] * result_length
        src_offset = 0
        out_offset = 0
        while src_offset < (len(src_row) - 2):
            prefix_bits = self.bytes_to_bits(src_row, src_offset, 2)
            src_offset += 2
            for bit_index in xrange(16):
                if src_offset >= len(src_row):
                    break
                if prefix_bits[bit_index] == 0:
                    out_row = self.ensure_capacity(out_row, out_offset)
                    out_row[out_offset] = src_row[src_offset]
                    src_offset += 1
                    out_offset += 1
                    continue
                marker_byte = src_row[src_offset]
                try:
                    next_byte = src_row[src_offset + 1]
                except IndexError:
                    break
                if self.is_short_rle(marker_byte):
                    length = self.get_length_of_rle_pattern(marker_byte)
                    out_row = self.ensure_capacity(
                        out_row, out_offset + length
                    )
                    pattern = self.clone_byte(next_byte, length)
                    out_row[out_offset:out_offset + length] = pattern
                    out_offset += length
                    src_offset += 2
                    continue
                elif self.is_single_byte_marker(marker_byte) and not\
                        ((next_byte & 0xF0) == ((next_byte << 4) & 0xF0)):
                    length = self.get_length_of_one_byte_pattern(marker_byte)
                    out_row = self.ensure_capacity(
                        out_row, out_offset + length
                    )
                    back_offset = self.get_offset_for_one_byte_pattern(
                        marker_byte
                    )
                    start = out_offset - back_offset
                    end = start + length
                    out_row[out_offset:out_offset + length] =\
                        out_row[start:end]
                    src_offset += 1
                    out_offset += length
                    continue
                two_bytes_marker = src_row[src_offset:src_offset + 2]
                if self.is_two_bytes_marker(two_bytes_marker):
                    length = self.get_length_of_two_bytes_pattern(
                        two_bytes_marker
                    )
                    out_row = self.ensure_capacity(
                        out_row, out_offset + length
                    )
                    back_offset = self.get_offset_for_two_bytes_pattern(
                        two_bytes_marker
                    )
                    start = out_offset - back_offset
                    end = start + length
                    out_row[out_offset:out_offset + length] =\
                        out_row[start:end]
                    src_offset += 2
                    out_offset += length
                    continue
                three_bytes_marker = src_row[src_offset:src_offset + 3]
                if self.is_three_bytes_marker(three_bytes_marker):
                    p_type = (three_bytes_marker[0] >> 4) & 0x0F
                    back_offset = 0
                    if p_type == 2:
                        back_offset = self.get_offset_for_three_bytes_pattern(
                            three_bytes_marker
                        )
                    length = self.get_length_of_three_bytes_pattern(
                        p_type, three_bytes_marker
                    )
                    out_row = self.ensure_capacity(
                        out_row, out_offset + length
                    )
                    if p_type == 1:
                        pattern = self.clone_byte(
                            three_bytes_marker[2], length
                        )
                    else:
                        start = out_offset - back_offset
                        end = start + length
                        pattern = out_row[start:end]
                    out_row[out_offset:out_offset + length] = pattern
                    src_offset += 3
                    out_offset += length
                    continue
                else:
                    self.parent.logger.error(
                        'unknown marker %s at offset %s', src_row[src_offset],
                        src_offset
                    )
                    break
        return b''.join([c(x) for x in out_row])


class SAS7BDAT(object):
    """
    SAS7BDAT(path[, log_level[, extra_time_format_strings[, \
extra_date_time_format_strings[, extra_date_format_strings]]]]) -> \
SAS7BDAT object

    Open a SAS7BDAT file. The log level are standard logging levels
    (defaults to logging.INFO).

    If your sas7bdat file uses non-standard format strings for time, datetime,
    or date values, pass those strings into the constructor using the
    appropriate kwarg.
    """
    _open_files = []
    RLE_COMPRESSION = b'SASYZCRL'
    RDC_COMPRESSION = b'SASYZCR2'
    COMPRESSION_LITERALS = set([
        RLE_COMPRESSION, RDC_COMPRESSION
    ])
    DECOMPRESSORS = {
        RLE_COMPRESSION: RLEDecompressor,
        RDC_COMPRESSION: RDCDecompressor
    }
    TIME_FORMAT_STRINGS = set([
        'TIME'
    ])
    DATE_TIME_FORMAT_STRINGS = set([
        'DATETIME'
    ])
    DATE_FORMAT_STRINGS = set([
        'YYMMDD', 'MMDDYY', 'DDMMYY', 'DATE', 'JULIAN', 'MONYY'
    ])

    def __init__(self, path, log_level=logging.INFO,
                 extra_time_format_strings=None,
                 extra_date_time_format_strings=None,
                 extra_date_format_strings=None,
                 skip_header=False,
                 encoding='utf8',
                 encoding_errors='ignore',
                 align_correction=True):
        """
        x.__init__(...) initializes x; see help(type(x)) for signature
        """
        if log_level == logging.DEBUG:
            sys.excepthook = _debug
        self.path = path
        self.endianess = None
        self.u64 = False
        self.logger = self._make_logger(level=log_level)
        self._update_format_strings(
            self.TIME_FORMAT_STRINGS, extra_time_format_strings
        )
        self._update_format_strings(
            self.DATE_TIME_FORMAT_STRINGS, extra_date_time_format_strings
        )
        self._update_format_strings(
            self.DATE_FORMAT_STRINGS, extra_date_format_strings
        )
        self.skip_header = skip_header
        self.encoding = encoding
        self.encoding_errors = encoding_errors
        self.align_correction = align_correction
        self._file = open(self.path, 'rb')
        self._open_files.append(self._file)
        self.cached_page = None
        self.current_page_type = None
        self.current_page_block_count = None
        self.current_page_subheaders_count = None
        self.current_file_position = 0
        self.current_page_data_subheader_pointers = []
        self.current_row = []
        self.column_names_strings = []
        self.column_names = []
        self.column_types = []
        self.column_data_offsets = []
        self.column_data_lengths = []
        self.columns = []
        self.header = SASHeader(self)
        self.properties = self.header.properties
        self.header.parse_metadata()
        self.logger.debug('\n%s', str(self.header))
        self._iter = self.readlines()

    def __repr__(self):
        """
        x.__repr__() <==> repr(x)
        """
        return 'SAS7BDAT file: %s' % os.path.basename(self.path)

    def __enter__(self):
        """
        __enter__() -> self.
        """
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        """
        __exit__(*excinfo) -> None. Closes the file.
        """
        self.close()

    def __iter__(self):
        """
        x.__iter__() <==> iter(x)
        """
        return self.readlines()

    def _update_format_strings(self, var, format_strings):
        if format_strings is not None:
            if isinstance(format_strings, str):
                var.add(format_strings)
            elif isinstance(format_strings, (set, list, tuple)):
                var.update(set(format_strings))
            else:
                raise NotImplementedError

    def close(self):
        """
        close() -> None or (perhaps) an integer. Close the file.

        A closed file cannot be used for further I/O operations.
        close() may be called more than once without error.
        Some kinds of file objects (for example, opened by popen())
        may return an exit status upon closing.
        """
        return self._file.close()

    def _make_logger(self, level=logging.INFO):
        """
        Create a custom logger with the specified properties.
        """
        logger = logging.getLogger(self.path)
        logger.setLevel(level)
        fmt = '%(message)s'
        stream_handler = logging.StreamHandler()
        if platform.system() != 'Windows':
            stream_handler.emit = _get_color_emit(
                os.path.basename(self.path),
                stream_handler.emit
            )
        else:
            fmt = '[%s] %%(message)s' % os.path.basename(self.path)
        formatter = logging.Formatter(fmt, '%y-%m-%d %H:%M:%S')
        stream_handler.setFormatter(formatter)
        logger.addHandler(stream_handler)
        return logger

    def _read_bytes(self, offsets_to_lengths):
        result = {}
        if not self.cached_page:
            for offset, length in six.iteritems(offsets_to_lengths):
                skipped = 0
                while skipped < (offset - self.current_file_position):
                    seek = offset - self.current_file_position - skipped
                    skipped += seek
                    self._file.seek(seek, 0)
                tmp = self._file.read(length)
                if len(tmp) < length:
                    self.logger.error(
                        'failed to read %s bytes from sas7bdat file', length
                    )
                self.current_file_position = offset + length
                result[offset] = tmp
        else:
            for offset, length in six.iteritems(offsets_to_lengths):
                result[offset] = self.cached_page[offset:offset + length]
        return result

    def _read_val(self, fmt, raw_bytes, size):
        if fmt == 'i' and self.u64 and size == 8:
            fmt = 'q'
        newfmt = fmt
        if fmt == 's':
            newfmt = '%ds' % min(size, len(raw_bytes))
        elif fmt in set(['number', 'datetime', 'date', 'time']):
            newfmt = 'd'
            if len(raw_bytes) != size:
                size = len(raw_bytes)
            if size < 8:
                if self.endianess == 'little':
                    raw_bytes = b''.join([b'\x00' * (8 - size), raw_bytes])
                else:
                    raw_bytes += b'\x00' * (8 - size)
                size = 8
        if self.endianess == 'big':
            newfmt = '>%s' % newfmt
        else:
            newfmt = '<%s' % newfmt
        val = struct.unpack(str(newfmt), raw_bytes[:size])[0]
        if fmt == 's':
            val = val.strip(b'\x00').strip()
        elif math.isnan(val):
            val = None
        elif fmt == 'datetime':
            val = datetime(1960, 1, 1) + timedelta(seconds=val)
        elif fmt == 'time':
            val = (datetime(1960, 1, 1) + timedelta(seconds=val)).time()
        elif fmt == 'date':
            try:
                val = (datetime(1960, 1, 1) + timedelta(days=val)).date()
            except OverflowError:
                # Some data sets flagged with a date format are actually
                # stored as datetime values
                val = datetime(1960, 1, 1) + timedelta(seconds=val)
        return val

    def readlines(self):
        """
        readlines() -> generator which yields lists of values, each a line
        from the file.

        Possible values in the list are None, string, float, datetime.datetime,
        datetime.date, and datetime.time.
        """
        bit_offset = self.header.PAGE_BIT_OFFSET
        subheader_pointer_length = self.header.SUBHEADER_POINTER_LENGTH
        row_count = self.header.properties.row_count
        current_row_in_file_index = 0
        current_row_on_page_index = 0
        if not self.skip_header:
            yield [x.name.decode(self.encoding, self.encoding_errors)
                   for x in self.columns]
        if not self.cached_page:
            self._file.seek(self.properties.header_length)
            self._read_next_page()
        while current_row_in_file_index < row_count:
            current_row_in_file_index += 1
            current_page_type = self.current_page_type
            if current_page_type == self.header.PAGE_META_TYPE:
                try:
                    current_subheader_pointer =\
                        self.current_page_data_subheader_pointers[
                            current_row_on_page_index
                        ]
                except IndexError:
                    self._read_next_page()
                    current_row_on_page_index = 0
                else:
                    current_row_on_page_index += 1
                    cls = self.header.SUBHEADER_INDEX_TO_CLASS.get(
                        self.header.DATA_SUBHEADER_INDEX
                    )
                    if cls is None:
                        raise NotImplementedError
                    cls(self).process_subheader(
                        current_subheader_pointer.offset,
                        current_subheader_pointer.length
                    )
                    if current_row_on_page_index ==\
                            len(self.current_page_data_subheader_pointers):
                        self._read_next_page()
                        current_row_on_page_index = 0
            elif current_page_type in self.header.PAGE_MIX_TYPE:
                if self.align_correction:
                    align_correction = (
                        bit_offset + self.header.SUBHEADER_POINTERS_OFFSET +
                        self.current_page_subheaders_count *
                        subheader_pointer_length
                    ) % 8
                else:
                    align_correction = 0
                offset = (
                    bit_offset + self.header.SUBHEADER_POINTERS_OFFSET +
                    align_correction + self.current_page_subheaders_count *
                    subheader_pointer_length + current_row_on_page_index *
                    self.properties.row_length
                )
                try:
                    self.current_row = self._process_byte_array_with_data(
                        offset,
                        self.properties.row_length
                    )
                except:
                    self.logger.exception(
                        'failed to process data (you might want to try '
                        'passing align_correction=%s to the SAS7BDAT '
                        'constructor)' % (not self.align_correction)
                    )
                    raise
                current_row_on_page_index += 1
                if current_row_on_page_index == min(
                    self.properties.row_count,
                    self.properties.mix_page_row_count
                ):
                    self._read_next_page()
                    current_row_on_page_index = 0
            elif current_page_type == self.header.PAGE_DATA_TYPE:
                self.current_row = self._process_byte_array_with_data(
                    bit_offset + self.header.SUBHEADER_POINTERS_OFFSET +
                    current_row_on_page_index *
                    self.properties.row_length,
                    self.properties.row_length
                )
                current_row_on_page_index += 1
                if current_row_on_page_index == self.current_page_block_count:
                    self._read_next_page()
                    current_row_on_page_index = 0
            else:
                self.logger.error('unknown page type: %s', current_page_type)
            yield self.current_row

    def _read_next_page(self):
        self.current_page_data_subheader_pointers = []
        self.cached_page = self._file.read(self.properties.page_length)
        if len(self.cached_page) <= 0:
            return

        if len(self.cached_page) != self.properties.page_length:
            self.logger.error(
                'failed to read complete page from file (read %s of %s bytes)',
                len(self.cached_page), self.properties.page_length
            )
        self.header.read_page_header()
        if self.current_page_type == self.header.PAGE_META_TYPE:
            self.header.process_page_metadata()
        if self.current_page_type not in [
            self.header.PAGE_META_TYPE,
            self.header.PAGE_DATA_TYPE
        ] + self.header.PAGE_MIX_TYPE:
            self._read_next_page()

    def _process_byte_array_with_data(self, offset, length):
        row_elements = []
        if self.properties.compression and length < self.properties.row_length:
            decompressor = self.DECOMPRESSORS.get(
                self.properties.compression
            )
            source = decompressor(self).decompress_row(
                offset, length, self.properties.row_length,
                self.cached_page
            )
            offset = 0
        else:
            source = self.cached_page
        for i in xrange(self.properties.column_count):
            length = self.column_data_lengths[i]
            if length == 0:
                break
            start = offset + self.column_data_offsets[i]
            end = offset + self.column_data_offsets[i] + length
            temp = source[start:end]
            if self.columns[i].type == 'number':
                if self.column_data_lengths[i] <= 2:
                    row_elements.append(self._read_val(
                        'h', temp, length
                    ))
                else:
                    fmt = self.columns[i].format
                    if not fmt:
                        row_elements.append(self._read_val(
                            'number', temp, length
                        ))
                    elif fmt in self.TIME_FORMAT_STRINGS:
                        row_elements.append(self._read_val(
                            'time', temp, length
                        ))
                    elif fmt in self.DATE_TIME_FORMAT_STRINGS:
                        row_elements.append(self._read_val(
                            'datetime', temp, length
                        ))
                    elif fmt in self.DATE_FORMAT_STRINGS:
                        row_elements.append(self._read_val(
                            'date', temp, length
                        ))
                    else:
                        row_elements.append(self._read_val(
                            'number', temp, length
                        ))
            else:  # string
                row_elements.append(self._read_val(
                    's', temp, length
                ).decode(self.encoding, self.encoding_errors))
        return row_elements

    def convert_file(self, out_file, delimiter=',', step_size=100000):
        """
        convert_file(out_file[, delimiter[, step_size]]) -> None

        A convenience method to convert a SAS7BDAT file into a delimited
        text file. Defaults to comma separated. The step_size parameter
        is uses to show progress on longer running conversions.
        """
        delimiter = str(delimiter)
        self.logger.debug('saving as: %s', out_file)
        out_f = None
        success = True
        try:
            if out_file == '-':
                out_f = sys.stdout
            else:
                out_f = open(out_file, 'w')
            out = csv.writer(out_f, lineterminator='\n', delimiter=delimiter)
            i = 0
            for i, line in enumerate(self, 1):
                if len(line) != (self.properties.column_count or 0):
                    msg = 'parsed line into %s columns but was ' \
                          'expecting %s.\n%s' %\
                          (len(line), self.properties.column_count, line)
                    self.logger.error(msg)
                    success = False
                    if self.logger.level == logging.DEBUG:
                        raise ParseError(msg)
                    break
                if not i % step_size:
                    self.logger.info(
                        '%.1f%% complete',
                        float(i) / self.properties.row_count * 100.0
                    )
                try:
                    out.writerow(line)
                except IOError:
                    self.logger.warn('wrote %s lines before interruption', i)
                    break
            self.logger.info('\u27f6 [%s] wrote %s of %s lines',
                             os.path.basename(out_file), i - 1,
                             self.properties.row_count or 0)
        finally:
            if out_f is not None:
                out_f.close()
        return success

    def to_data_frame(self):
        """
        to_data_frame() -> pandas.DataFrame object

        A convenience method to convert a SAS7BDAT file into a pandas
        DataFrame.
        """
        import pandas as pd
        data = list(self.readlines())
        return pd.DataFrame(data[1:], columns=data[0])


class Column(object):
    def __init__(self, col_id, name, label, col_format, col_type, length):
        self.col_id = col_id
        self.name = name
        self.label = label
        self.format = col_format.decode("utf-8")
        self.type = col_type
        self.length = length

    def __repr__(self):
        return self.name


class SubheaderPointer(object):
    def __init__(self, offset=None, length=None, compression=None,
                 p_type=None):
        self.offset = offset
        self.length = length
        self.compression = compression
        self.type = p_type


class ProcessingSubheader(object):
    TEXT_BLOCK_SIZE_LENGTH = 2
    ROW_LENGTH_OFFSET_MULTIPLIER = 5
    ROW_COUNT_OFFSET_MULTIPLIER = 6
    COL_COUNT_P1_MULTIPLIER = 9
    COL_COUNT_P2_MULTIPLIER = 10
    ROW_COUNT_ON_MIX_PAGE_OFFSET_MULTIPLIER = 15  # rowcountfp
    COLUMN_NAME_POINTER_LENGTH = 8
    COLUMN_NAME_TEXT_SUBHEADER_OFFSET = 0
    COLUMN_NAME_TEXT_SUBHEADER_LENGTH = 2
    COLUMN_NAME_OFFSET_OFFSET = 2
    COLUMN_NAME_OFFSET_LENGTH = 2
    COLUMN_NAME_LENGTH_OFFSET = 4
    COLUMN_NAME_LENGTH_LENGTH = 2
    COLUMN_DATA_OFFSET_OFFSET = 8
    COLUMN_DATA_LENGTH_OFFSET = 8
    COLUMN_DATA_LENGTH_LENGTH = 4
    COLUMN_TYPE_OFFSET = 14
    COLUMN_TYPE_LENGTH = 1
    COLUMN_FORMAT_TEXT_SUBHEADER_INDEX_OFFSET = 22
    COLUMN_FORMAT_TEXT_SUBHEADER_INDEX_LENGTH = 2
    COLUMN_FORMAT_OFFSET_OFFSET = 24
    COLUMN_FORMAT_OFFSET_LENGTH = 2
    COLUMN_FORMAT_LENGTH_OFFSET = 26
    COLUMN_FORMAT_LENGTH_LENGTH = 2
    COLUMN_LABEL_TEXT_SUBHEADER_INDEX_OFFSET = 28
    COLUMN_LABEL_TEXT_SUBHEADER_INDEX_LENGTH = 2
    COLUMN_LABEL_OFFSET_OFFSET = 30
    COLUMN_LABEL_OFFSET_LENGTH = 2
    COLUMN_LABEL_LENGTH_OFFSET = 32
    COLUMN_LABEL_LENGTH_LENGTH = 2

    def __init__(self, parent):
        self.parent = parent
        self.logger = parent.logger
        self.properties = parent.header.properties
        self.int_length = 8 if self.properties.u64 else 4

    def process_subheader(self, offset, length):
        raise NotImplementedError


class RowSizeSubheader(ProcessingSubheader):
    def process_subheader(self, offset, length):
        int_len = self.int_length
        lcs = offset + (682 if self.properties.u64 else 354)
        lcp = offset + (706 if self.properties.u64 else 378)
        vals = self.parent._read_bytes({
            offset + self.ROW_LENGTH_OFFSET_MULTIPLIER * int_len: int_len,
            offset + self.ROW_COUNT_OFFSET_MULTIPLIER * int_len: int_len,
            offset + self.ROW_COUNT_ON_MIX_PAGE_OFFSET_MULTIPLIER * int_len:
                int_len,
            offset + self.COL_COUNT_P1_MULTIPLIER * int_len: int_len,
            offset + self.COL_COUNT_P2_MULTIPLIER * int_len: int_len,
            lcs: 2,
            lcp: 2,
        })
        if self.properties.row_length is not None:
            self.logger.error('found more than one row length subheader')
        if self.properties.row_count is not None:
            self.logger.error('found more than one row count subheader')
        if self.properties.col_count_p1 is not None:
            self.logger.error('found more than one col count p1 subheader')
        if self.properties.col_count_p2 is not None:
            self.logger.error('found more than one col count p2 subheader')
        if self.properties.mix_page_row_count is not None:
            self.logger.error('found more than one mix page row count '
                              'subheader')
        self.properties.row_length = self.parent._read_val(
            'i',
            vals[offset + self.ROW_LENGTH_OFFSET_MULTIPLIER * int_len],
            int_len
        )
        self.properties.row_count = self.parent._read_val(
            'i',
            vals[offset + self.ROW_COUNT_OFFSET_MULTIPLIER * int_len],
            int_len
        )
        self.properties.col_count_p1 = self.parent._read_val(
            'i',
            vals[offset + self.COL_COUNT_P1_MULTIPLIER * int_len],
            int_len
        )
        self.properties.col_count_p2 = self.parent._read_val(
            'i',
            vals[offset + self.COL_COUNT_P2_MULTIPLIER * int_len],
            int_len
        )
        self.properties.mix_page_row_count = self.parent._read_val(
            'i',
            vals[offset + self.ROW_COUNT_ON_MIX_PAGE_OFFSET_MULTIPLIER *
                 int_len],
            int_len
        )
        self.properties.lcs = self.parent._read_val('h', vals[lcs], 2)
        self.properties.lcp = self.parent._read_val('h', vals[lcp], 2)


class ColumnSizeSubheader(ProcessingSubheader):
    def process_subheader(self, offset, length):
        offset += self.int_length
        vals = self.parent._read_bytes({
            offset: self.int_length
        })
        if self.properties.column_count is not None:
            self.logger.error('found more than one column count subheader')
        self.properties.column_count = self.parent._read_val(
            'i', vals[offset], self.int_length
        )
        if self.properties.col_count_p1 + self.properties.col_count_p2 !=\
                self.properties.column_count:
            self.logger.warning('column count mismatch')


class SubheaderCountsSubheader(ProcessingSubheader):
    def process_subheader(self, offset, length):
        pass  # Not sure what to do here yet


class ColumnTextSubheader(ProcessingSubheader):
    def process_subheader(self, offset, length):
        offset += self.int_length
        vals = self.parent._read_bytes({
            offset: self.TEXT_BLOCK_SIZE_LENGTH
        })
        text_block_size = self.parent._read_val(
            'h', vals[offset], self.TEXT_BLOCK_SIZE_LENGTH
        )

        vals = self.parent._read_bytes({
            offset: text_block_size
        })
        self.parent.column_names_strings.append(vals[offset])
        if len(self.parent.column_names_strings) == 1:
            column_name = self.parent.column_names_strings[0]
            compression_literal = None
            for cl in SAS7BDAT.COMPRESSION_LITERALS:
                if cl in column_name:
                    compression_literal = cl
                    break
            self.properties.compression = compression_literal
            offset -= self.int_length
            vals = self.parent._read_bytes({
                offset + (20 if self.properties.u64 else 16): 8
            })
            compression_literal = self.parent._read_val(
                's',
                vals[offset + (20 if self.properties.u64 else 16)],
                8
            ).strip()
            if compression_literal == '':
                self.properties.lcs = 0
                vals = self.parent._read_bytes({
                    offset + 16 + (20 if self.properties.u64 else 16):
                        self.properties.lcp
                })
                creatorproc = self.parent._read_val(
                    's',
                    vals[offset + 16 + (20 if self.properties.u64 else 16)],
                    self.properties.lcp
                )
                self.properties.creator_proc = creatorproc
            elif compression_literal == SAS7BDAT.RLE_COMPRESSION:
                vals = self.parent._read_bytes({
                    offset + 24 + (20 if self.properties.u64 else 16):
                        self.properties.lcp
                })
                creatorproc = self.parent._read_val(
                    's',
                    vals[offset + 24 + (20 if self.properties.u64 else 16)],
                    self.properties.lcp
                )
                self.properties.creator_proc = creatorproc
            elif self.properties.lcs > 0:
                self.properties.lcp = 0
                vals = self.parent._read_bytes({
                    offset + (20 if self.properties.u64 else 16):
                        self.properties.lcs
                })
                creator = self.parent._read_val(
                    's',
                    vals[offset + (20 if self.properties.u64 else 16)],
                    self.properties.lcs
                )
                self.properties.creator = creator


class ColumnNameSubheader(ProcessingSubheader):
    def process_subheader(self, offset, length):
        offset += self.int_length
        column_name_pointers_count = (length - 2 * self.int_length - 12) // 8
        for i in xrange(column_name_pointers_count):
            text_subheader = (
                offset + self.COLUMN_NAME_POINTER_LENGTH * (i + 1) +
                self.COLUMN_NAME_TEXT_SUBHEADER_OFFSET
            )
            col_name_offset = (
                offset + self.COLUMN_NAME_POINTER_LENGTH * (i + 1) +
                self.COLUMN_NAME_OFFSET_OFFSET
            )
            col_name_length = (
                offset + self.COLUMN_NAME_POINTER_LENGTH * (i + 1) +
                self.COLUMN_NAME_LENGTH_OFFSET
            )
            vals = self.parent._read_bytes({
                text_subheader: self.COLUMN_NAME_TEXT_SUBHEADER_LENGTH,
                col_name_offset: self.COLUMN_NAME_OFFSET_LENGTH,
                col_name_length: self.COLUMN_NAME_LENGTH_LENGTH,
            })

            idx = self.parent._read_val(
                'h', vals[text_subheader],
                self.COLUMN_NAME_TEXT_SUBHEADER_LENGTH
            )
            col_offset = self.parent._read_val(
                'h', vals[col_name_offset],
                self.COLUMN_NAME_OFFSET_LENGTH
            )
            col_len = self.parent._read_val(
                'h', vals[col_name_length],
                self.COLUMN_NAME_LENGTH_LENGTH
            )
            name_str = self.parent.column_names_strings[idx]
            self.parent.column_names.append(
                name_str[col_offset:col_offset + col_len]
            )


class ColumnAttributesSubheader(ProcessingSubheader):
    def process_subheader(self, offset, length):
        int_len = self.int_length
        column_attributes_vectors_count = (
            (length - 2 * int_len - 12) // (int_len + 8)
        )
        for i in xrange(column_attributes_vectors_count):
            col_data_offset = (
                offset + int_len + self.COLUMN_DATA_OFFSET_OFFSET + i *
                (int_len + 8)
            )
            col_data_len = (
                offset + 2 * int_len + self.COLUMN_DATA_LENGTH_OFFSET + i *
                (int_len + 8)
            )
            col_types = (
                offset + 2 * int_len + self.COLUMN_TYPE_OFFSET + i *
                (int_len + 8)
            )
            vals = self.parent._read_bytes({
                col_data_offset: int_len,
                col_data_len: self.COLUMN_DATA_LENGTH_LENGTH,
                col_types: self.COLUMN_TYPE_LENGTH,
            })
            self.parent.column_data_offsets.append(self.parent._read_val(
                'i', vals[col_data_offset], int_len
            ))
            self.parent.column_data_lengths.append(self.parent._read_val(
                'i', vals[col_data_len], self.COLUMN_DATA_LENGTH_LENGTH
            ))
            ctype = self.parent._read_val(
                'b', vals[col_types], self.COLUMN_TYPE_LENGTH
            )
            self.parent.column_types.append(
                'number' if ctype == 1 else 'string'
            )


class FormatAndLabelSubheader(ProcessingSubheader):
    def process_subheader(self, offset, length):
        int_len = self.int_length
        text_subheader_format = (
            offset + self.COLUMN_FORMAT_TEXT_SUBHEADER_INDEX_OFFSET + 3 *
            int_len
        )
        col_format_offset = (
            offset + self.COLUMN_FORMAT_OFFSET_OFFSET + 3 * int_len
        )
        col_format_len = (
            offset + self.COLUMN_FORMAT_LENGTH_OFFSET + 3 * int_len
        )
        text_subheader_label = (
            offset + self.COLUMN_LABEL_TEXT_SUBHEADER_INDEX_OFFSET + 3 *
            int_len
        )
        col_label_offset = (
            offset + self.COLUMN_LABEL_OFFSET_OFFSET + 3 * int_len
        )
        col_label_len = (
            offset + self.COLUMN_LABEL_LENGTH_OFFSET + 3 * int_len
        )
        vals = self.parent._read_bytes({
            text_subheader_format:
                self.COLUMN_FORMAT_TEXT_SUBHEADER_INDEX_LENGTH,
            col_format_offset: self.COLUMN_FORMAT_OFFSET_LENGTH,
            col_format_len: self.COLUMN_FORMAT_LENGTH_LENGTH,
            text_subheader_label:
                self.COLUMN_LABEL_TEXT_SUBHEADER_INDEX_LENGTH,
            col_label_offset: self.COLUMN_LABEL_OFFSET_LENGTH,
            col_label_len: self.COLUMN_LABEL_LENGTH_LENGTH,
        })

        # min used to prevent incorrect data which appear in some files
        format_idx = min(
            self.parent._read_val(
                'h', vals[text_subheader_format],
                self.COLUMN_FORMAT_TEXT_SUBHEADER_INDEX_LENGTH
            ),
            len(self.parent.column_names_strings) - 1
        )
        format_start = self.parent._read_val(
            'h', vals[col_format_offset],
            self.COLUMN_FORMAT_OFFSET_LENGTH
        )
        format_len = self.parent._read_val(
            'h', vals[col_format_len],
            self.COLUMN_FORMAT_LENGTH_LENGTH
        )
        # min used to prevent incorrect data which appear in some files
        label_idx = min(
            self.parent._read_val(
                'h', vals[text_subheader_label],
                self.COLUMN_LABEL_TEXT_SUBHEADER_INDEX_LENGTH,
            ),
            len(self.parent.column_names_strings) - 1
        )
        label_start = self.parent._read_val(
            'h', vals[col_label_offset],
            self.COLUMN_LABEL_OFFSET_LENGTH
        )
        label_len = self.parent._read_val(
            'h', vals[col_label_len],
            self.COLUMN_LABEL_LENGTH_LENGTH
        )

        label_names = self.parent.column_names_strings[label_idx]
        column_label = label_names[label_start:label_start + label_len]
        format_names = self.parent.column_names_strings[format_idx]
        column_format = format_names[format_start:format_start + format_len]
        current_column_number = len(self.parent.columns)
        self.parent.columns.append(
            Column(current_column_number,
                   self.parent.column_names[current_column_number],
                   column_label,
                   column_format,
                   self.parent.column_types[current_column_number],
                   self.parent.column_data_lengths[current_column_number])
        )


class ColumnListSubheader(ProcessingSubheader):
    def process_subheader(self, offset, length):
        pass  # Not sure what to do with this yet


class DataSubheader(ProcessingSubheader):
    def process_subheader(self, offset, length):
        self.parent.current_row = self.parent._process_byte_array_with_data(
            offset, length
        )


class SASProperties(object):
    def __init__(self):
        self.u64 = False
        self.endianess = None
        self.platform = None
        self.name = None
        self.file_type = None
        self.date_created = None
        self.date_modified = None
        self.header_length = None
        self.page_length = None
        self.page_count = None
        self.sas_release = None
        self.server_type = None
        self.os_type = None
        self.os_name = None
        self.compression = None
        self.row_length = None
        self.row_count = None
        self.col_count_p1 = None
        self.col_count_p2 = None
        self.mix_page_row_count = None
        self.lcs = None
        self.lcp = None
        self.creator = None
        self.creator_proc = None
        self.column_count = None
        self.filename = None


class SASHeader(object):
    MAGIC = b'\x00\x00\x00\x00\x00\x00\x00\x00' \
            b'\x00\x00\x00\x00\xc2\xea\x81\x60' \
            b'\xb3\x14\x11\xcf\xbd\x92\x08\x00' \
            b'\x09\xc7\x31\x8c\x18\x1f\x10\x11'
    ROW_SIZE_SUBHEADER_INDEX = 'row_size'
    COLUMN_SIZE_SUBHEADER_INDEX = 'column_size'
    SUBHEADER_COUNTS_SUBHEADER_INDEX = 'subheader_counts'
    COLUMN_TEXT_SUBHEADER_INDEX = 'column_text'
    COLUMN_NAME_SUBHEADER_INDEX = 'column_name'
    COLUMN_ATTRIBUTES_SUBHEADER_INDEX = 'column_attributes'
    FORMAT_AND_LABEL_SUBHEADER_INDEX = 'format_and_label'
    COLUMN_LIST_SUBHEADER_INDEX = 'column_list'
    DATA_SUBHEADER_INDEX = 'data'
    # Subheader signatures, 32 and 64 bit, little and big endian
    SUBHEADER_SIGNATURE_TO_INDEX = {
        b'\xF7\xF7\xF7\xF7': ROW_SIZE_SUBHEADER_INDEX,
        b'\x00\x00\x00\x00\xF7\xF7\xF7\xF7': ROW_SIZE_SUBHEADER_INDEX,
        b'\xF7\xF7\xF7\xF7\x00\x00\x00\x00': ROW_SIZE_SUBHEADER_INDEX,
        b'\xF6\xF6\xF6\xF6': COLUMN_SIZE_SUBHEADER_INDEX,
        b'\x00\x00\x00\x00\xF6\xF6\xF6\xF6': COLUMN_SIZE_SUBHEADER_INDEX,
        b'\xF6\xF6\xF6\xF6\x00\x00\x00\x00': COLUMN_SIZE_SUBHEADER_INDEX,
        b'\x00\xFC\xFF\xFF': SUBHEADER_COUNTS_SUBHEADER_INDEX,
        b'\xFF\xFF\xFC\x00': SUBHEADER_COUNTS_SUBHEADER_INDEX,
        b'\x00\xFC\xFF\xFF\xFF\xFF\xFF\xFF': SUBHEADER_COUNTS_SUBHEADER_INDEX,
        b'\xFF\xFF\xFF\xFF\xFF\xFF\xFC\x00': SUBHEADER_COUNTS_SUBHEADER_INDEX,
        b'\xFD\xFF\xFF\xFF': COLUMN_TEXT_SUBHEADER_INDEX,
        b'\xFF\xFF\xFF\xFD': COLUMN_TEXT_SUBHEADER_INDEX,
        b'\xFD\xFF\xFF\xFF\xFF\xFF\xFF\xFF': COLUMN_TEXT_SUBHEADER_INDEX,
        b'\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFD': COLUMN_TEXT_SUBHEADER_INDEX,
        b'\xFF\xFF\xFF\xFF': COLUMN_NAME_SUBHEADER_INDEX,
        b'\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF': COLUMN_NAME_SUBHEADER_INDEX,
        b'\xFC\xFF\xFF\xFF': COLUMN_ATTRIBUTES_SUBHEADER_INDEX,
        b'\xFF\xFF\xFF\xFC': COLUMN_ATTRIBUTES_SUBHEADER_INDEX,
        b'\xFC\xFF\xFF\xFF\xFF\xFF\xFF\xFF': COLUMN_ATTRIBUTES_SUBHEADER_INDEX,
        b'\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFC': COLUMN_ATTRIBUTES_SUBHEADER_INDEX,
        b'\xFE\xFB\xFF\xFF': FORMAT_AND_LABEL_SUBHEADER_INDEX,
        b'\xFF\xFF\xFB\xFE': FORMAT_AND_LABEL_SUBHEADER_INDEX,
        b'\xFE\xFB\xFF\xFF\xFF\xFF\xFF\xFF': FORMAT_AND_LABEL_SUBHEADER_INDEX,
        b'\xFF\xFF\xFF\xFF\xFF\xFF\xFB\xFE': FORMAT_AND_LABEL_SUBHEADER_INDEX,
        b'\xFE\xFF\xFF\xFF': COLUMN_LIST_SUBHEADER_INDEX,
        b'\xFF\xFF\xFF\xFE': COLUMN_LIST_SUBHEADER_INDEX,
        b'\xFE\xFF\xFF\xFF\xFF\xFF\xFF\xFF': COLUMN_LIST_SUBHEADER_INDEX,
        b'\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFE': COLUMN_LIST_SUBHEADER_INDEX,
    }
    SUBHEADER_INDEX_TO_CLASS = {
        ROW_SIZE_SUBHEADER_INDEX: RowSizeSubheader,
        COLUMN_SIZE_SUBHEADER_INDEX: ColumnSizeSubheader,
        SUBHEADER_COUNTS_SUBHEADER_INDEX: SubheaderCountsSubheader,
        COLUMN_TEXT_SUBHEADER_INDEX: ColumnTextSubheader,
        COLUMN_NAME_SUBHEADER_INDEX: ColumnNameSubheader,
        COLUMN_ATTRIBUTES_SUBHEADER_INDEX: ColumnAttributesSubheader,
        FORMAT_AND_LABEL_SUBHEADER_INDEX: FormatAndLabelSubheader,
        COLUMN_LIST_SUBHEADER_INDEX: ColumnListSubheader,
        DATA_SUBHEADER_INDEX: DataSubheader,
    }
    ALIGN_1_CHECKER_VALUE = b'3'
    ALIGN_1_OFFSET = 32
    ALIGN_1_LENGTH = 1
    ALIGN_1_VALUE = 4
    U64_BYTE_CHECKER_VALUE = b'3'
    ALIGN_2_OFFSET = 35
    ALIGN_2_LENGTH = 1
    ALIGN_2_VALUE = 4
    ENDIANNESS_OFFSET = 37
    ENDIANNESS_LENGTH = 1
    PLATFORM_OFFSET = 39
    PLATFORM_LENGTH = 1
    DATASET_OFFSET = 92
    DATASET_LENGTH = 64
    FILE_TYPE_OFFSET = 156
    FILE_TYPE_LENGTH = 8
    DATE_CREATED_OFFSET = 164
    DATE_CREATED_LENGTH = 8
    DATE_MODIFIED_OFFSET = 172
    DATE_MODIFIED_LENGTH = 8
    HEADER_SIZE_OFFSET = 196
    HEADER_SIZE_LENGTH = 4
    PAGE_SIZE_OFFSET = 200
    PAGE_SIZE_LENGTH = 4
    PAGE_COUNT_OFFSET = 204
    PAGE_COUNT_LENGTH = 4
    SAS_RELEASE_OFFSET = 216
    SAS_RELEASE_LENGTH = 8
    SAS_SERVER_TYPE_OFFSET = 224
    SAS_SERVER_TYPE_LENGTH = 16
    OS_VERSION_NUMBER_OFFSET = 240
    OS_VERSION_NUMBER_LENGTH = 16
    OS_MAKER_OFFSET = 256
    OS_MAKER_LENGTH = 16
    OS_NAME_OFFSET = 272
    OS_NAME_LENGTH = 16
    PAGE_BIT_OFFSET_X86 = 16
    PAGE_BIT_OFFSET_X64 = 32
    SUBHEADER_POINTER_LENGTH_X86 = 12
    SUBHEADER_POINTER_LENGTH_X64 = 24
    PAGE_TYPE_OFFSET = 0
    PAGE_TYPE_LENGTH = 2
    BLOCK_COUNT_OFFSET = 2
    BLOCK_COUNT_LENGTH = 2
    SUBHEADER_COUNT_OFFSET = 4
    SUBHEADER_COUNT_LENGTH = 2
    PAGE_META_TYPE = 0
    PAGE_DATA_TYPE = 256
    PAGE_MIX_TYPE = [512, 640]
    PAGE_AMD_TYPE = 1024
    PAGE_METC_TYPE = 16384
    PAGE_COMP_TYPE = -28672
    PAGE_MIX_DATA_TYPE = PAGE_MIX_TYPE + [PAGE_DATA_TYPE]
    PAGE_META_MIX_AMD = [PAGE_META_TYPE] + PAGE_MIX_TYPE + [PAGE_AMD_TYPE]
    PAGE_ANY = PAGE_META_MIX_AMD +\
        [PAGE_DATA_TYPE, PAGE_METC_TYPE, PAGE_COMP_TYPE]
    SUBHEADER_POINTERS_OFFSET = 8
    TRUNCATED_SUBHEADER_ID = 1
    COMPRESSED_SUBHEADER_ID = 4
    COMPRESSED_SUBHEADER_TYPE = 1

    def __init__(self, parent):
        self.parent = parent
        self.properties = SASProperties()
        self.properties.filename = os.path.basename(parent.path)
        # Check magic number
        h = parent.cached_page = parent._file.read(288)
        if len(h) < 288:
            parent.logger.error('header too short (not a sas7bdat file?)')
            return
        if not self.check_magic_number(h):
            parent.logger.error('magic number mismatch')
            return
        align1 = 0
        align2 = 0
        offsets_and_lengths = {
            self.ALIGN_1_OFFSET: self.ALIGN_1_LENGTH,
            self.ALIGN_2_OFFSET: self.ALIGN_2_LENGTH,
        }
        align_vals = parent._read_bytes(offsets_and_lengths)
        if align_vals[self.ALIGN_1_OFFSET] == self.U64_BYTE_CHECKER_VALUE:
            align2 = self.ALIGN_2_VALUE
            self.properties.u64 = True
        if align_vals[self.ALIGN_2_OFFSET] == self.ALIGN_1_CHECKER_VALUE:
            align1 = self.ALIGN_1_VALUE
        total_align = align1 + align2
        offsets_and_lengths = {
            self.ENDIANNESS_OFFSET: self.ENDIANNESS_LENGTH,
            self.PLATFORM_OFFSET: self.PLATFORM_LENGTH,
            self.DATASET_OFFSET: self.DATASET_LENGTH,
            self.FILE_TYPE_OFFSET: self.FILE_TYPE_LENGTH,
            self.DATE_CREATED_OFFSET + align1: self.DATE_CREATED_LENGTH,
            self.DATE_MODIFIED_OFFSET + align1: self.DATE_MODIFIED_LENGTH,
            self.HEADER_SIZE_OFFSET + align1: self.HEADER_SIZE_LENGTH,
            self.PAGE_SIZE_OFFSET + align1: self.PAGE_SIZE_LENGTH,
            self.PAGE_COUNT_OFFSET + align1: self.PAGE_COUNT_LENGTH + align2,
            self.SAS_RELEASE_OFFSET + total_align: self.SAS_RELEASE_LENGTH,
            self.SAS_SERVER_TYPE_OFFSET + total_align:
                self.SAS_SERVER_TYPE_LENGTH,
            self.OS_VERSION_NUMBER_OFFSET + total_align:
                self.OS_VERSION_NUMBER_LENGTH,
            self.OS_MAKER_OFFSET + total_align: self.OS_MAKER_LENGTH,
            self.OS_NAME_OFFSET + total_align: self.OS_NAME_LENGTH,
        }
        vals = parent._read_bytes(offsets_and_lengths)
        self.properties.endianess = 'little'\
            if vals[self.ENDIANNESS_OFFSET] == b'\x01' else 'big'
        parent.endianess = self.properties.endianess
        if vals[self.PLATFORM_OFFSET] == b'1':
            self.properties.platform = 'unix'
        elif vals[self.PLATFORM_OFFSET] == b'2':
            self.properties.platform = 'windows'
        else:
            self.properties.platform = 'unknown'
        self.properties.name = parent._read_val(
            's', vals[self.DATASET_OFFSET], self.DATASET_LENGTH
        )
        self.properties.file_type = parent._read_val(
            's', vals[self.FILE_TYPE_OFFSET], self.FILE_TYPE_LENGTH
        )

        # Timestamp is epoch 01/01/1960
        try:
            self.properties.date_created = datetime(1960, 1, 1) + timedelta(
                seconds=parent._read_val(
                    'd', vals[self.DATE_CREATED_OFFSET + align1],
                    self.DATE_CREATED_LENGTH
                )
            )
        except:
            pass
        try:
            self.properties.date_modified = datetime(1960, 1, 1) + timedelta(
                seconds=parent._read_val(
                    'd', vals[self.DATE_MODIFIED_OFFSET + align1],
                    self.DATE_MODIFIED_LENGTH
                )
            )
        except:
            pass

        self.properties.header_length = parent._read_val(
            'i', vals[self.HEADER_SIZE_OFFSET + align1],
            self.HEADER_SIZE_LENGTH
        )
        if self.properties.u64 and self.properties.header_length != 8192:
            parent.logger.warning('header length %s != 8192',
                                  self.properties.header_length)
        parent.cached_page += parent._file.read(
            self.properties.header_length - 288
        )
        h = parent.cached_page
        if len(h) != self.properties.header_length:
            parent.logger.error('header too short (not a sas7bdat file?)')
            return
        self.properties.page_length = parent._read_val(
            'i', vals[self.PAGE_SIZE_OFFSET + align1],
            self.PAGE_SIZE_LENGTH
        )
        self.properties.page_count = parent._read_val(
            'i', vals[self.PAGE_COUNT_OFFSET + align1],
            self.PAGE_COUNT_LENGTH
        )
        self.properties.sas_release = parent._read_val(
            's', vals[self.SAS_RELEASE_OFFSET + total_align],
            self.SAS_RELEASE_LENGTH
        )
        self.properties.server_type = parent._read_val(
            's', vals[self.SAS_SERVER_TYPE_OFFSET + total_align],
            self.SAS_SERVER_TYPE_LENGTH
        )
        self.properties.os_type = parent._read_val(
            's', vals[self.OS_VERSION_NUMBER_OFFSET + total_align],
            self.OS_VERSION_NUMBER_LENGTH
        )
        if vals[self.OS_NAME_OFFSET + total_align] != 0:
            self.properties.os_name = parent._read_val(
                's', vals[self.OS_NAME_OFFSET + total_align],
                self.OS_NAME_LENGTH
            )
        else:
            self.properties.os_name = parent._read_val(
                's', vals[self.OS_MAKER_OFFSET + total_align],
                self.OS_MAKER_LENGTH
            )
        parent.u64 = self.properties.u64

    def __repr__(self):
        cols = [['Num', 'Name', 'Type', 'Length', 'Format', 'Label']]
        align = ['>', '<', '<', '>', '<', '<']
        col_width = [len(x) for x in cols[0]]
        for i, col in enumerate(self.parent.columns, 1):
            tmp = [i, col.name, col.type, col.length,
                   col.format, col.label]
            cols.append(tmp)
            for j, val in enumerate(tmp):
                col_width[j] = max(col_width[j], len(str(val)))
        rows = [' '.join('{0:{1}}'.format(x, col_width[i])
                         for i, x in enumerate(cols[0])),
                ' '.join('-' * col_width[i]
                         for i in xrange(len(align)))]
        for row in cols[1:]:
            rows.append(' '.join(
                '{0:{1}{2}}'.format(x.decode(self.parent.encoding,
                                             self.parent.encoding_errors)
                                    if isinstance(x, bytes) else x,
                                    align[i], col_width[i])
                for i, x in enumerate(row))
            )
        cols = '\n'.join(rows)
        hdr = 'Header:\n%s' % '\n'.join(
            ['\t%s: %s' % (k, v.decode(self.parent.encoding,
                                       self.parent.encoding_errors)
                              if isinstance(v, bytes) else v)
             for k, v in sorted(six.iteritems(self.properties.__dict__))]
        )
        return '%s\n\nContents of dataset "%s":\n%s\n' % (
            hdr,
            self.properties.name.decode(self.parent.encoding,
                                        self.parent.encoding_errors),
            cols
        )

    def _page_bit_offset(self):
        return self.PAGE_BIT_OFFSET_X64 if self.properties.u64 else\
            self.PAGE_BIT_OFFSET_X86
    PAGE_BIT_OFFSET = property(_page_bit_offset)

    def _subheader_pointer_length(self):
        return self.SUBHEADER_POINTER_LENGTH_X64 if self.properties.u64 else\
            self.SUBHEADER_POINTER_LENGTH_X86
    SUBHEADER_POINTER_LENGTH = property(_subheader_pointer_length)

    def check_magic_number(self, header):
        return header[:len(self.MAGIC)] == self.MAGIC

    def parse_metadata(self):
        done = False
        while not done:
            self.parent.cached_page = self.parent._file.read(
                self.properties.page_length
            )
            if len(self.parent.cached_page) <= 0:
                break
            if len(self.parent.cached_page) != self.properties.page_length:
                self.parent.logger.error(
                    'Failed to read a meta data page from file'
                )
            done = self.process_page_meta()

    def read_page_header(self):
        bit_offset = self.PAGE_BIT_OFFSET
        vals = self.parent._read_bytes({
            self.PAGE_TYPE_OFFSET + bit_offset: self.PAGE_TYPE_LENGTH,
            self.BLOCK_COUNT_OFFSET + bit_offset: self.BLOCK_COUNT_LENGTH,
            self.SUBHEADER_COUNT_OFFSET + bit_offset:
                self.SUBHEADER_COUNT_LENGTH
        })

        self.parent.current_page_type = self.parent._read_val(
            'h', vals[self.PAGE_TYPE_OFFSET + bit_offset],
            self.PAGE_TYPE_LENGTH
        )
        self.parent.current_page_block_count = self.parent._read_val(
            'h', vals[self.BLOCK_COUNT_OFFSET + bit_offset],
            self.BLOCK_COUNT_LENGTH
        )
        self.parent.current_page_subheaders_count = self.parent._read_val(
            'h', vals[self.SUBHEADER_COUNT_OFFSET + bit_offset],
            self.SUBHEADER_COUNT_LENGTH
        )

    def process_page_meta(self):
        self.read_page_header()
        if self.parent.current_page_type in self.PAGE_META_MIX_AMD:
            self.process_page_metadata()
        return self.parent.current_page_type in self.PAGE_MIX_DATA_TYPE or \
            self.parent.current_page_data_subheader_pointers

    def process_page_metadata(self):
        parent = self.parent
        bit_offset = self.PAGE_BIT_OFFSET
        for i in xrange(parent.current_page_subheaders_count):
            pointer = self.process_subheader_pointers(
                self.SUBHEADER_POINTERS_OFFSET + bit_offset, i
            )
            if not pointer.length:
                continue
            if pointer.compression != self.TRUNCATED_SUBHEADER_ID:
                subheader_signature = self.read_subheader_signature(
                    pointer.offset
                )
                subheader_index = self.get_subheader_class(
                    subheader_signature,
                    pointer.compression,
                    pointer.type
                )
                if subheader_index is not None:
                    if subheader_index != self.DATA_SUBHEADER_INDEX:
                        cls = self.SUBHEADER_INDEX_TO_CLASS.get(
                            subheader_index
                        )
                        if cls is None:
                            raise NotImplementedError
                        cls(parent).process_subheader(
                            pointer.offset,
                            pointer.length
                        )
                    else:
                        parent.current_page_data_subheader_pointers.append(
                            pointer
                        )
                else:
                    parent.logger.debug('unknown subheader signature')

    def read_subheader_signature(self, offset):
        length = 8 if self.properties.u64 else 4
        return self.parent._read_bytes({offset: length})[offset]

    def get_subheader_class(self, signature, compression, type):
        index = self.SUBHEADER_SIGNATURE_TO_INDEX.get(signature)
        if self.properties.compression is not None and index is None and\
                (compression == self.COMPRESSED_SUBHEADER_ID or
                 compression == 0) and type == self.COMPRESSED_SUBHEADER_TYPE:
            index = self.DATA_SUBHEADER_INDEX
        return index

    def process_subheader_pointers(self, offset, subheader_pointer_index):
        length = 8 if self.properties.u64 else 4
        subheader_pointer_length = self.SUBHEADER_POINTER_LENGTH
        total_offset = (
            offset + subheader_pointer_length * subheader_pointer_index
        )
        vals = self.parent._read_bytes({
            total_offset: length,
            total_offset + length: length,
            total_offset + 2 * length: 1,
            total_offset + 2 * length + 1: 1,
        })

        subheader_offset = self.parent._read_val(
            'i', vals[total_offset], length
        )
        subheader_length = self.parent._read_val(
            'i', vals[total_offset + length], length
        )
        subheader_compression = self.parent._read_val(
            'b', vals[total_offset + 2 * length], 1
        )
        subheader_type = self.parent._read_val(
            'b', vals[total_offset + 2 * length + 1], 1
        )

        return SubheaderPointer(subheader_offset, subheader_length,
                                subheader_compression, subheader_type)


@atexit.register
def _close_files():
    for f in SAS7BDAT._open_files:
        f.close()


if __name__ == '__main__':
    pass  # TODO: write some unit tests

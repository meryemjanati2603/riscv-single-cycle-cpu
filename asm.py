#!/usr/bin/env python3
"""Mini assembleur RISC-V : add, sub, and, or, addi, lw, sw, beq.
Usage : python3 asm.py program.asm program.hex
Ecrit une instruction par ligne en hexadecimal (format lu par $readmemh)."""
import re, sys

def reg(t):
    return int(t.strip().lstrip('x'))

def r_type(f7, rs2, rs1, f3, rd, op):
    return (f7 << 25) | (rs2 << 20) | (rs1 << 15) | (f3 << 12) | (rd << 7) | op

def i_type(imm, rs1, f3, rd, op):
    return ((imm & 0xFFF) << 20) | (rs1 << 15) | (f3 << 12) | (rd << 7) | op

def s_type(imm, rs2, rs1, f3, op):
    imm &= 0xFFF
    return ((imm >> 5) << 25) | (rs2 << 20) | (rs1 << 15) | (f3 << 12) | ((imm & 0x1F) << 7) | op

def b_type(imm, rs2, rs1, f3, op):
    imm &= 0x1FFF
    return (((imm >> 12) & 1) << 31) | (((imm >> 5) & 0x3F) << 25) | (rs2 << 20) | (rs1 << 15) \
        | (f3 << 12) | (((imm >> 1) & 0xF) << 8) | (((imm >> 11) & 1) << 7) | op

def assemble(line):
    m, args = line.split(None, 1)
    a = [x.strip() for x in args.split(',')]
    if m in ('add', 'sub', 'and', 'or'):
        f7 = 0b0100000 if m == 'sub' else 0
        f3 = {'add': 0, 'sub': 0, 'or': 0b110, 'and': 0b111}[m]
        return r_type(f7, reg(a[2]), reg(a[1]), f3, reg(a[0]), 0b0110011)
    if m == 'addi':
        return i_type(int(a[2]), reg(a[1]), 0, reg(a[0]), 0b0010011)
    if m in ('lw', 'sw'):
        imm, base = re.match(r'(-?\d+)\((x\d+)\)', a[1]).groups()
        if m == 'lw':
            return i_type(int(imm), reg(base), 0b010, reg(a[0]), 0b0000011)
        return s_type(int(imm), reg(a[0]), reg(base), 0b010, 0b0100011)
    if m == 'beq':
        return b_type(int(a[2]), reg(a[1]), reg(a[0]), 0, 0b1100011)
    raise ValueError('instruction inconnue : ' + line)

if __name__ == '__main__':
    src, dst = sys.argv[1], sys.argv[2]
    out = []
    for n, line in enumerate(open(src)):
        line = line.split('#')[0].strip()
        if line:
            out.append('%08x // 0x%02x: %s' % (assemble(line), 4 * len(out), line))
    open(dst, 'w').write('\n'.join(out) + '\n')
    print(len(out), 'instructions ecrites dans', dst)
